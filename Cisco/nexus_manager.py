#!/usr/bin/env python3
"""
Cisco Nexus Switch Manager
Manages Nexus switches via NX-API (REST) and SSH (Paramiko fallback).

Usage:
    python nexus_manager.py --host 10.0.0.1 --user admin info
    python nexus_manager.py --host 10.0.0.1 interfaces
    python nexus_manager.py --host 10.0.0.1 vlans
    python nexus_manager.py --host 10.0.0.1 vlan-add 100 --name MGMT
    python nexus_manager.py --host 10.0.0.1 neighbors
    python nexus_manager.py --host 10.0.0.1 routing
    python nexus_manager.py --host 10.0.0.1 inventory
    python nexus_manager.py --host 10.0.0.1 run-cmd "show version"
    python nexus_manager.py --host 10.0.0.1 save
"""

import argparse
import getpass
import json
import os
import sys
from typing import Any

try:
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    HAS_URLLIB3 = True
except ImportError:
    HAS_URLLIB3 = False

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

try:
    import paramiko
    HAS_PARAMIKO = True
except ImportError:
    HAS_PARAMIKO = False


# ---------------------------------------------------------------------------
# NX-API client
# ---------------------------------------------------------------------------

class NxApiError(Exception):
    pass


class NxApiClient:
    """Communicates with a Nexus switch via NX-API (HTTP/S JSON-RPC)."""

    def __init__(self, host: str, user: str, password: str,
                 port: int = 443, use_ssl: bool = True, verify: bool = False):
        scheme = "https" if use_ssl else "http"
        self.base_url = f"{scheme}://{host}:{port}/ins"
        self.auth = (user, password)
        self.verify = verify
        self.session = requests.Session()
        self.session.auth = self.auth
        self.session.verify = self.verify
        self.session.headers.update({"Content-Type": "application/json"})

    def _payload(self, *cmds: str, version: str = "1.0") -> dict:
        return {
            "ins_api": {
                "version": version,
                "type": "cli_show",
                "chunk": "0",
                "sid": "1",
                "input": " ;; ".join(cmds),
                "output_format": "json",
            }
        }

    def _payload_conf(self, *cmds: str) -> dict:
        return {
            "ins_api": {
                "version": "1.0",
                "type": "cli_conf",
                "chunk": "0",
                "sid": "1",
                "input": " ;; ".join(cmds),
                "output_format": "json",
            }
        }

    def run(self, *cmds: str) -> list[dict]:
        """Run one or more show commands, return list of output bodies."""
        payload = self._payload(*cmds)
        try:
            r = self.session.post(self.base_url, json=payload, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise NxApiError(f"Request failed: {exc}") from exc

        data = r.json()
        outputs = data["ins_api"]["outputs"]["output"]
        if isinstance(outputs, dict):
            outputs = [outputs]

        results = []
        for out in outputs:
            if out.get("code") != "200":
                raise NxApiError(f"NX-API error [{out.get('code')}]: {out.get('msg')}")
            body = out.get("body", {})
            results.append(body)
        return results

    def configure(self, *cmds: str) -> list[dict]:
        """Run configuration commands."""
        payload = self._payload_conf(*cmds)
        try:
            r = self.session.post(self.base_url, json=payload, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise NxApiError(f"Request failed: {exc}") from exc

        data = r.json()
        outputs = data["ins_api"]["outputs"]["output"]
        if isinstance(outputs, dict):
            outputs = [outputs]

        results = []
        for out in outputs:
            if out.get("code") not in ("200", None):
                raise NxApiError(f"Config error [{out.get('code')}]: {out.get('msg')}")
            results.append(out)
        return results


# ---------------------------------------------------------------------------
# SSH fallback client
# ---------------------------------------------------------------------------

class SshClient:
    """Minimal SSH client using Paramiko for switches without NX-API."""

    def __init__(self, host: str, user: str, password: str, port: int = 22,
                 verify_host: bool = True):
        if not HAS_PARAMIKO:
            raise RuntimeError("paramiko is required for SSH mode: pip install paramiko")
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.verify_host = verify_host
        self._client: paramiko.SSHClient | None = None

    def connect(self):
        c = paramiko.SSHClient()
        if self.verify_host:
            known_hosts = os.path.expanduser("~/.ssh/known_hosts")
            if os.path.exists(known_hosts):
                c.load_host_keys(known_hosts)
            c.set_missing_host_key_policy(paramiko.RejectPolicy())
        else:
            c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        c.connect(self.host, port=self.port, username=self.user,
                  password=self.password, look_for_keys=False, allow_agent=False)
        self._client = c

    def run(self, cmd: str) -> str:
        if self._client is None:
            self.connect()
        _, stdout, stderr = self._client.exec_command(cmd)
        out = stdout.read().decode()
        err = stderr.read().decode()
        return out or err

    def close(self):
        if self._client:
            self._client.close()
            self._client = None


# ---------------------------------------------------------------------------
# Display helpers
# ---------------------------------------------------------------------------

def hr(char: str = "-", width: int = 70) -> None:
    print(char * width)


def header(title: str) -> None:
    hr("=")
    print(f"  {title}")
    hr("=")


def table(rows: list[list[str]], columns: list[str]) -> None:
    if not rows:
        return
    widths = [max(len(str(r[i])) for r in ([columns] + rows)) for i in range(len(columns))]
    fmt = "  ".join(f"{{:<{w}}}" for w in widths)
    print(fmt.format(*columns))
    hr("-", sum(widths) + 2 * (len(widths) - 1))
    for row in rows:
        print(fmt.format(*[str(c) for c in row]))


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

def cmd_info(client: NxApiClient) -> None:
    header("System Information")
    body = client.run("show version")[0]
    fields = [
        ("Hostname",        body.get("host_name", "N/A")),
        ("Chassis ID",      body.get("chassis_id", "N/A")),
        ("NX-OS Version",   body.get("nxos_ver_str", "N/A")),
        ("System uptime",   body.get("kern_uptm_str", "N/A")),
        ("Kickstart image", body.get("kickstart_file_name", "N/A")),
        ("System image",    body.get("sys_file_name", "N/A")),
        ("Memory (MB)",     body.get("mem_tot_mb", "N/A")),
    ]
    for label, value in fields:
        print(f"  {label:<20}: {value}")


def cmd_interfaces(client: NxApiClient) -> None:
    header("Interfaces")
    body = client.run("show interface brief")[0]
    rows = []

    for section in ("TABLE_interface", "TABLE_intf"):
        data = body.get(section, {})
        if not data:
            continue
        entries = data.get("ROW_interface") or data.get("ROW_intf", [])
        if isinstance(entries, dict):
            entries = [entries]
        for e in entries:
            rows.append([
                e.get("interface", e.get("intf_name", "N/A")),
                e.get("vlan", "N/A"),
                e.get("type", "N/A"),
                e.get("portmode", "N/A"),
                e.get("state", e.get("st", "N/A")),
                e.get("speed", e.get("bw", "N/A")),
                e.get("reason", ""),
            ])

    if rows:
        table(rows, ["Interface", "VLAN", "Type", "Mode", "State", "Speed", "Reason"])
    else:
        print("  No interface data returned.")


def cmd_vlans(client: NxApiClient) -> None:
    header("VLANs")
    body = client.run("show vlan brief")[0]
    entries = body.get("TABLE_vlanbrief", {}).get("ROW_vlanbrief", [])
    if isinstance(entries, dict):
        entries = [entries]
    rows = [[e.get("vlanshowbr-vlanid", "N/A"),
             e.get("vlanshowbr-vlanname", "N/A"),
             e.get("vlanshowbr-vlanstate", "N/A"),
             e.get("vlanshowbr-vlanmtu", "N/A")]
            for e in entries]
    if rows:
        table(rows, ["VLAN ID", "Name", "State", "MTU"])
    else:
        print("  No VLAN data returned.")


def cmd_vlan_add(client: NxApiClient, vlan_id: int, name: str | None) -> None:
    cmds = [f"vlan {vlan_id}"]
    if name:
        cmds.append(f"name {name}")
    client.configure(*cmds)
    label = f" ({name})" if name else ""
    print(f"  VLAN {vlan_id}{label} configured successfully.")


def cmd_vlan_remove(client: NxApiClient, vlan_id: int) -> None:
    client.configure(f"no vlan {vlan_id}")
    print(f"  VLAN {vlan_id} removed.")


def cmd_neighbors(client: NxApiClient) -> None:
    header("CDP Neighbors")
    body = client.run("show cdp neighbors")[0]
    entries = body.get("TABLE_cdp_neighbor_brief_info", {}).get(
        "ROW_cdp_neighbor_brief_info", [])
    if isinstance(entries, dict):
        entries = [entries]
    rows = [[e.get("intf_id", "N/A"),
             e.get("device_id", "N/A"),
             e.get("port_id", "N/A"),
             e.get("platform_id", "N/A"),
             e.get("capability", "N/A")]
            for e in entries]
    if rows:
        table(rows, ["Local Intf", "Device ID", "Remote Intf", "Platform", "Capability"])
    else:
        print("  No CDP neighbor data returned.")


def cmd_routing(client: NxApiClient) -> None:
    header("IP Route Summary")
    body = client.run("show ip route summary")[0]
    entries = body.get("TABLE_vrf", {}).get("ROW_vrf", [])
    if isinstance(entries, dict):
        entries = [entries]
    for vrf in entries:
        vrf_name = vrf.get("vrf-name-out", "default")
        print(f"\n  VRF: {vrf_name}")
        pfx = vrf.get("TABLE_prefix", {}).get("ROW_prefix", [])
        if isinstance(pfx, dict):
            pfx = [pfx]
        rows = [[p.get("prefix", "N/A"), p.get("path-count", "N/A")] for p in pfx]
        if rows:
            table(rows, ["Prefix", "Path Count"])


def cmd_bgp(client: NxApiClient) -> None:
    header("BGP Summary")
    try:
        body = client.run("show bgp summary")[0]
    except NxApiError as exc:
        print(f"  BGP not available: {exc}")
        return
    vrf_entries = body.get("TABLE_vrf", {}).get("ROW_vrf", [])
    if isinstance(vrf_entries, dict):
        vrf_entries = [vrf_entries]
    for vrf in vrf_entries:
        print(f"\n  VRF: {vrf.get('vrf-name-out', 'default')}")
        peers = vrf.get("TABLE_neighbor", {}).get("ROW_neighbor", [])
        if isinstance(peers, dict):
            peers = [peers]
        rows = [[p.get("neighborid", "N/A"),
                 p.get("neighboras", "N/A"),
                 p.get("state", "N/A"),
                 p.get("prefixreceived", "N/A")]
                for p in peers]
        if rows:
            table(rows, ["Neighbor", "AS", "State", "Prefixes Rx"])


def cmd_inventory(client: NxApiClient) -> None:
    header("Hardware Inventory")
    body = client.run("show inventory")[0]
    entries = body.get("TABLE_inv", {}).get("ROW_inv", [])
    if isinstance(entries, dict):
        entries = [entries]
    rows = [[e.get("name", "N/A"),
             e.get("desc", "N/A"),
             e.get("productid", "N/A"),
             e.get("serialnum", "N/A")]
            for e in entries]
    if rows:
        table(rows, ["Name", "Description", "PID", "Serial Number"])
    else:
        print("  No inventory data returned.")


def cmd_run(client: NxApiClient, command: str) -> None:
    header(f"Command: {command}")
    try:
        results = client.run(command)
        for result in results:
            if isinstance(result, str):
                print(result)
            else:
                print(json.dumps(result, indent=2))
    except NxApiError:
        # Retry as raw ASCII output
        payload = {
            "ins_api": {
                "version": "1.0",
                "type": "cli_show_ascii",
                "chunk": "0",
                "sid": "1",
                "input": command,
                "output_format": "json",
            }
        }
        try:
            r = client.session.post(client.base_url, json=payload, timeout=15)
            r.raise_for_status()
            out = r.json()["ins_api"]["outputs"]["output"]
            print(out.get("body", "No output.") if isinstance(out, dict) else out)
        except Exception as exc:
            raise NxApiError(f"Command failed (JSON and ASCII attempts): {exc}") from exc


def cmd_save(client: NxApiClient) -> None:
    print("  Saving running configuration to startup...")
    client.configure("copy running-config startup-config")
    print("  Configuration saved.")


def cmd_ssh_run(ssh: SshClient, command: str) -> None:
    header(f"SSH Command: {command}")
    print(ssh.run(command))


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Cisco Nexus Switch Manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    p.add_argument("--host",     required=True, help="Switch IP or hostname")
    p.add_argument("--user",     default=os.environ.get("NEXUS_USER", "admin"),
                   help="Username (default: $NEXUS_USER or 'admin')")
    p.add_argument("--password", default=os.environ.get("NEXUS_PASS"),
                   help="Password (default: $NEXUS_PASS; prompted if omitted)")
    p.add_argument("--port",     type=int, default=None,
                   help="Port override (default: 443 NX-API, 22 SSH)")
    p.add_argument("--no-ssl",        action="store_true",
                   help="Use HTTP instead of HTTPS for NX-API")
    p.add_argument("--no-verify",     action="store_true",
                   help="Disable TLS certificate verification")
    p.add_argument("--no-verify-host", action="store_true",
                   help="Disable SSH host key verification (insecure, use only in labs)")
    p.add_argument("--ssh",           action="store_true",
                   help="Force SSH mode instead of NX-API")

    sub = p.add_subparsers(dest="command", metavar="COMMAND")
    sub.required = True

    sub.add_parser("info",       help="Show system/version info")
    sub.add_parser("interfaces", help="Show interface brief")
    sub.add_parser("vlans",      help="List VLANs")
    sub.add_parser("neighbors",  help="Show CDP neighbors")
    sub.add_parser("routing",    help="Show IP route summary")
    sub.add_parser("bgp",        help="Show BGP summary")
    sub.add_parser("inventory",  help="Show hardware inventory")
    sub.add_parser("save",       help="Copy running-config to startup-config")

    va = sub.add_parser("vlan-add",    help="Add or update a VLAN")
    va.add_argument("vlan_id", type=int)
    va.add_argument("--name",  help="VLAN name")

    vr = sub.add_parser("vlan-remove", help="Remove a VLAN")
    vr.add_argument("vlan_id", type=int)

    rc = sub.add_parser("run-cmd", help="Run an arbitrary NX-OS command")
    rc.add_argument("cmd", help="Command string to execute")

    return p.parse_args()


def main() -> None:
    args = parse_args()

    password = args.password
    if not password:
        password = getpass.getpass(f"Password for {args.user}@{args.host}: ")

    if args.no_verify:
        print("WARNING: TLS certificate verification is disabled.", file=sys.stderr)

    if args.ssh:
        if not HAS_PARAMIKO:
            print("ERROR: SSH mode requires paramiko — pip install paramiko", file=sys.stderr)
            sys.exit(1)
        if args.no_verify_host:
            print("WARNING: SSH host key verification is disabled.", file=sys.stderr)
        ssh = SshClient(args.host, args.user, password, port=args.port or 22,
                        verify_host=not args.no_verify_host)
        try:
            ssh.connect()
        except Exception as exc:
            print(f"ERROR: SSH connection failed: {exc}", file=sys.stderr)
            sys.exit(1)
        ssh_map = {
            "info":       "show version",
            "interfaces": "show interface brief",
            "vlans":      "show vlan brief",
            "neighbors":  "show cdp neighbors",
            "routing":    "show ip route summary",
            "bgp":        "show bgp summary",
            "inventory":  "show inventory",
            "save":       "copy running-config startup-config",
        }
        try:
            if args.command == "run-cmd":
                cmd_ssh_run(ssh, args.cmd)
            elif args.command in ssh_map:
                cmd_ssh_run(ssh, ssh_map[args.command])
            else:
                print(f"  '{args.command}' requires NX-API mode (drop --ssh).", file=sys.stderr)
        finally:
            ssh.close()
        return

    # NX-API mode
    if not HAS_REQUESTS:
        print("ERROR: NX-API mode requires requests — pip install requests", file=sys.stderr)
        sys.exit(1)

    use_ssl = not args.no_ssl
    port = args.port or (443 if use_ssl else 80)
    verify = not args.no_verify
    client = NxApiClient(args.host, args.user, password, port=port, use_ssl=use_ssl,
                         verify=verify)

    try:
        dispatch = {
            "info":        lambda: cmd_info(client),
            "interfaces":  lambda: cmd_interfaces(client),
            "vlans":       lambda: cmd_vlans(client),
            "vlan-add":    lambda: cmd_vlan_add(client, args.vlan_id,
                                                getattr(args, "name", None)),
            "vlan-remove": lambda: cmd_vlan_remove(client, args.vlan_id),
            "neighbors":   lambda: cmd_neighbors(client),
            "routing":     lambda: cmd_routing(client),
            "bgp":         lambda: cmd_bgp(client),
            "inventory":   lambda: cmd_inventory(client),
            "run-cmd":     lambda: cmd_run(client, args.cmd),
            "save":        lambda: cmd_save(client),
        }
        dispatch[args.command]()
    except NxApiError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted.", file=sys.stderr)
        sys.exit(130)


if __name__ == "__main__":
    main()
