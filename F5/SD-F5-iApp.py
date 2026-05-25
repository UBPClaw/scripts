#!/usr/bin/env python3
"""
F5 VIP Deployment Script
Mirrors the SD-F5-iApp.tmpl iApp template using the F5 iControl REST API.

Usage examples:
  # Production deployment on port 443 with SSL and HTTPS redirect:
  python3 SD-F5-iApp.py --host 192.168.1.1 --password secret --app-name MyApp \\
      --vip-att 12.20.179.10 --vip-cox 72.194.40.10 --vip-internal 172.21.111.10 \\
      --snat Yes --redirect Yes --backend-servers 10.14.128.5 10.14.128.6 \\
      --ports 443:Yes:https:my-client-ssl 80:Yes::

  # Staged deployment:
  python3 SD-F5-iApp.py --host 192.168.1.1 --password secret --app-name MyApp \\
      --stage Yes --vip-internal 172.21.111.10 \\
      --backend-servers 10.14.128.5 --ports 443:Yes:https:my-client-ssl

  Port format: port:allowall:monitor:sslprofile
    e.g.  443:Yes:https:my-ssl-profile
          80:Yes::
          21:No::
"""

import argparse
import sys

import requests
from urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


class F5Client:
    def __init__(self, host, username, password):
        self.base_url = f"https://{host}/mgmt/tm"
        self.session = requests.Session()
        self.session.verify = False
        self.session.auth = (username, password)
        self.session.headers.update({"Content-Type": "application/json"})

    def create(self, endpoint, payload):
        url = f"{self.base_url}/{endpoint}"
        resp = self.session.post(url, json=payload)
        resp.raise_for_status()
        return resp.json()


class VIPDeployer:
    def __init__(self, client, config):
        self.client = client
        self.cfg = config
        self.app_name = config["app_name"]

    def _create_firewall_policy(self):
        self.client.create(
            "security/firewall/policy",
            {
                "name": f"{self.app_name}-fw-po",
                "partition": "Common",
                "rules": [{"name": "allow-all", "action": "accept"}],
            },
        )
        print(f"  Created firewall policy: {self.app_name}-fw-po")

    def _create_asm_l7_policy(self, virtual_name, asm_policy):
        policy_name = f"asm_auto_l7_policy__{virtual_name}"
        self.client.create(
            "ltm/policy",
            {
                "name": policy_name,
                "partition": "Common",
                "legacy": True,
                "controls": ["asm"],
                "requires": ["http"],
                "strategy": "first-match",
                "rules": [
                    {
                        "name": "default",
                        "ordinal": 1,
                        "actions": [
                            {
                                "name": "1",
                                "asm": True,
                                "enable": True,
                                "policy": {"name": asm_policy},
                            }
                        ],
                    }
                ],
            },
        )
        print(f"  Created ASM L7 policy: {policy_name}")
        return policy_name

    def _build_profiles(self, port, ssl_profile):
        profiles = [{"name": "tcp", "context": "all"}]
        if port == "80":
            profiles.append({"name": "http", "context": "all"})
        elif port == "443":
            if ssl_profile:
                profiles.append({"name": ssl_profile, "context": "clientside"})
            profiles.append({"name": "http", "context": "all"})
            profiles.append({"name": "serverssl-insecure-compatible", "context": "serverside"})
        elif port == "21":
            profiles.append({"name": "ftp", "context": "all"})
        return profiles

    def _add_asm_profiles(self, profiles):
        names = {p["name"] for p in profiles}
        if "http" not in names:
            profiles.append({"name": "http", "context": "all"})
        if "websecurity" not in names:
            profiles.append({"name": "websecurity", "context": "all"})
        return profiles

    def _create_pool(self, port, members, monitor):
        pool_name = f"{self.app_name}-{port}"
        payload = {
            "name": pool_name,
            "partition": "Common",
            "members": [{"name": f"{ip}:{port}", "address": ip} for ip in members],
        }
        payload["monitor"] = monitor.strip() if monitor and monitor.strip() else "none"
        self.client.create("ltm/pool", payload)
        print(f"  Created pool: {pool_name}")
        return pool_name

    def _create_virtual(self, name, destination, port, profiles, pool_name,
                        snat, irules, asm_policy_name, has_ruleset, source_port_change=False):
        payload = {
            "name": name,
            "partition": "Common",
            "destination": f"/Common/{destination}:{port}",
            "ipProtocol": "tcp",
            "mask": "255.255.255.255",
            "profiles": profiles,
            "translateAddress": "enabled",
            "translatePort": "enabled",
            "vlansDisabled": True,
            "securityLogProfiles": ["/Common/m1-base-logging"],
        }

        if pool_name:
            payload["pool"] = f"/Common/{pool_name}"

        if snat == "automap":
            payload["sourceAddressTranslation"] = {"type": "automap"}
        else:
            payload["sourceAddressTranslation"] = {"type": "none"}

        if irules:
            payload["rules"] = [f"/Common/{r}" for r in irules if r.strip()]

        if asm_policy_name:
            payload["policies"] = [f"/Common/{asm_policy_name}"]

        if has_ruleset:
            payload["fwEnforcedPolicy"] = f"/Common/{self.app_name}-fw-po"

        if source_port_change:
            payload["sourcePort"] = "change"

        self.client.create("ltm/virtual", payload)
        print(f"  Created virtual server: {name}")

    def _create_redirect_virtual(self, name, destination, has_ruleset):
        payload = {
            "name": name,
            "partition": "Common",
            "destination": f"/Common/{destination}:80",
            "ipProtocol": "tcp",
            "mask": "255.255.255.255",
            "profiles": [
                {"name": "http", "context": "all"},
                {"name": "tcp", "context": "all"},
            ],
            "rules": ["/Common/_sys_https_redirect"],
            "vlansDisabled": True,
            "securityLogProfiles": ["/Common/m1-base-logging"],
        }
        if has_ruleset:
            payload["fwEnforcedPolicy"] = f"/Common/{self.app_name}-fw-po"
        self.client.create("ltm/virtual", payload)
        print(f"  Created redirect virtual: {name}")

    def deploy(self):
        cfg = self.cfg
        snat = "automap" if cfg["snat"] == "Yes" else "none"
        has_asm = bool(cfg.get("asmpolicy", "").strip())
        members = [s["backendip"] for s in cfg["backendservers"]]
        irules = [r for r in cfg.get("irules", []) if r.strip()]

        for portcfg in cfg["ports"]:
            port = portcfg["port"]
            allow_all = portcfg.get("allowall", "No") == "Yes"
            ssl_profile = portcfg.get("sslprofile", "").strip()
            monitor = portcfg.get("monitor", "").strip() if cfg["monitoryesno"] == "Yes" else None

            print(f"\nProcessing port {port}...")

            has_ruleset = False
            if allow_all:
                self._create_firewall_policy()
                has_ruleset = True

            profiles = self._build_profiles(port, ssl_profile)
            source_port_change = port == "21"

            if has_asm:
                profiles = self._add_asm_profiles(profiles)

            pool_name = self._create_pool(port, members, monitor)

            if cfg["stagedeployment"] == "No":
                # Production: create VIPs for each defined address
                vip_targets = [
                    ("vipaddress_att", "att"),
                    ("vipaddress_cox_10g", "cox-10g"),
                    ("vipaddress_internal", "internal"),
                ]
                for vip_key, vip_suffix in vip_targets:
                    vip_addr = cfg.get(vip_key, "").strip()
                    if not vip_addr:
                        continue

                    virt_name = f"{self.app_name}-{vip_suffix}-{port}"
                    asm_policy_name = ""
                    if has_asm:
                        asm_policy_name = self._create_asm_l7_policy(virt_name, cfg["asmpolicy"])

                    if cfg["redirect"] == "Yes" and port == "443":
                        self._create_virtual(
                            virt_name, vip_addr, port, profiles, pool_name,
                            snat, irules, asm_policy_name, has_ruleset, source_port_change,
                        )
                        self._create_redirect_virtual(
                            f"{self.app_name}-{vip_suffix}-80-redir", vip_addr, has_ruleset
                        )
                    else:
                        self._create_virtual(
                            virt_name, vip_addr, port, profiles, pool_name,
                            snat, irules, asm_policy_name, has_ruleset, source_port_change,
                        )

            else:
                # Staged: derive temp IP from last octet of internal address
                vip_internal = cfg.get("vipaddress_internal", "").strip()
                if not vip_internal:
                    print("  Staged deployment requires --vip-internal; skipping.", file=sys.stderr)
                    continue

                d = vip_internal.split(".")[-1]
                temp_ip = f"172.21.64.{d}"
                virt_name = f"{self.app_name}-{port}"
                asm_policy_name = ""
                if has_asm:
                    asm_policy_name = self._create_asm_l7_policy(virt_name, cfg["asmpolicy"])

                if cfg["redirect"] == "Yes" and port == "443":
                    self._create_virtual(
                        virt_name, temp_ip, port, profiles, pool_name,
                        "automap", irules, asm_policy_name, has_ruleset, source_port_change,
                    )
                    self._create_redirect_virtual(
                        f"{self.app_name}-80-redir", temp_ip, has_ruleset
                    )
                else:
                    self._create_virtual(
                        virt_name, temp_ip, port, profiles, pool_name,
                        "automap", irules, asm_policy_name, has_ruleset, source_port_change,
                    )


def parse_ports(port_strings):
    ports = []
    for ps in port_strings:
        parts = ps.split(":")
        ports.append(
            {
                "port": parts[0],
                "allowall": parts[1] if len(parts) > 1 else "Yes",
                "monitor": parts[2] if len(parts) > 2 else "",
                "sslprofile": parts[3] if len(parts) > 3 else "",
            }
        )
    return ports


def main():
    parser = argparse.ArgumentParser(
        description="F5 VIP Deployment — equivalent to SD-F5-iApp.tmpl"
    )
    parser.add_argument("--host", required=True, help="F5 BIG-IP hostname or IP")
    parser.add_argument("--username", default="admin", help="BIG-IP username (default: admin)")
    parser.add_argument("--password", required=True, help="BIG-IP password")
    parser.add_argument("--app-name", required=True, help="Application/iApp name")
    parser.add_argument("--stage", choices=["Yes", "No"], default="No",
                        help="Stage deployment using temp IPs (default: No)")
    parser.add_argument("--snat", choices=["Yes", "No"], default="No",
                        help="Enable SNAT automap (default: No)")
    parser.add_argument("--redirect", choices=["Yes", "No"], default="No",
                        help="Create HTTP→HTTPS redirect virtual for port 443 (default: No)")
    parser.add_argument("--vip-att", default="", help="ATT VIP address")
    parser.add_argument("--vip-cox", default="", help="Cox 10G VIP address")
    parser.add_argument("--vip-internal", default="", help="Internal VIP address")
    parser.add_argument("--monitor", choices=["Yes", "No"], default="Yes",
                        help="Apply health monitor to pool (default: Yes)")
    parser.add_argument("--asm-policy", default="", help="ASM policy name to apply")
    parser.add_argument("--irules", nargs="*", default=[], help="iRule name(s) to apply")
    parser.add_argument("--backend-servers", nargs="+", required=True,
                        help="Backend pool member IPs")
    parser.add_argument(
        "--ports", nargs="+", required=True,
        help="Port definitions: port:allowall:monitor:sslprofile  "
             "(e.g. '443:Yes:https:my-ssl'  '80:Yes::'  '21:No::')",
    )
    args = parser.parse_args()

    config = {
        "app_name": args.app_name,
        "stagedeployment": args.stage,
        "snat": args.snat,
        "redirect": args.redirect,
        "vipaddress_att": args.vip_att,
        "vipaddress_cox_10g": args.vip_cox,
        "vipaddress_internal": args.vip_internal,
        "monitoryesno": args.monitor,
        "asmpolicy": args.asm_policy,
        "irules": args.irules,
        "backendservers": [{"backendip": ip} for ip in args.backend_servers],
        "ports": parse_ports(args.ports),
    }

    client = F5Client(args.host, args.username, args.password)
    deployer = VIPDeployer(client, config)

    print(f"Deploying {args.app_name} to {args.host}...")
    try:
        deployer.deploy()
        print("\nDeployment completed successfully.")
    except requests.HTTPError as exc:
        print(f"\nHTTP error: {exc}", file=sys.stderr)
        print(f"Response body: {exc.response.text}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
