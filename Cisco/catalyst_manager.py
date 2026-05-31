#!/usr/bin/env python3
"""
Cisco Catalyst Switch Manager
Manages Catalyst (IOS/IOS-XE) switches via RESTCONF (IOS-XE 16.6+) or SSH fallback.

Usage:
    python catalyst_manager.py --host 10.0.0.1 --user admin info
    python catalyst_manager.py --host 10.0.0.1 interfaces
    python catalyst_manager.py --host 10.0.0.1 vlans
    python catalyst_manager.py --host 10.0.0.1 vlan-add 100 --name MGMT
    python catalyst_manager.py --host 10.0.0.1 vlan-remove 100
    python catalyst_manager.py --host 10.0.0.1 neighbors
    python catalyst_manager.py --host 10.0.0.1 routing
    python catalyst_manager.py --host 10.0.0.1 spanning-tree
    python catalyst_manager.py --host 10.0.0.1 mac-table
    python catalyst_manager.py --host 10.0.0.1 run-cmd "show version"
    python catalyst_manager.py --host 10.0.0.1 save
    python catalyst_manager.py --host 10.0.0.1 --ssh interfaces
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

RESTCONF_HEADERS = {
    "Accept": "application/yang-data+json",
    "Content-Type": "application/yang-data+json",
}


# ---------------------------------------------------------------------------
# RESTCONF client
# ---------------------------------------------------------------------------

class RestconfError(Exception):
    pass


class RestconfClient:
    """Talks to an IOS-XE switch via RESTCONF (RFC 8040)."""

    def __init__(self, host: str, user: str, password: str,
                 port: int = 443, verify: bool = False):
        self.base = f"https://{host}:{port}/restconf/data"
        self.auth = (user, password)
        self.verify = verify
        self.session = requests.Session()
        self.session.auth = self.auth
        self.session.verify = self.verify
        self.session.headers.update(RESTCONF_HEADERS)

    def get(self, path: str) -> dict:
        url = f"{self.base}/{path.lstrip('/')}"
        try:
            r = self.session.get(url, timeout=15)
            if r.status_code == 404:
                return {}
            r.raise_for_status()
        except requests.RequestException as exc:
            raise RestconfError(f"GET {url} failed: {exc}") from exc
        try:
            return r.json()
        except ValueError:
            return {"_raw": r.text}

    def put(self, path: str, data: dict) -> None:
        url = f"{self.base}/{path.lstrip('/')}"
        try:
            r = self.session.put(url, json=data, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise RestconfError(f"PUT {url} failed: {exc}") from exc

    def patch(self, path: str, data: dict) -> None:
        url = f"{self.base}/{path.lstrip('/')}"
        try:
            r = self.session.patch(url, json=data, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise RestconfError(f"PATCH {url} failed: {exc}") from exc

    def delete(self, path: str) -> None:
        url = f"{self.base}/{path.lstrip('/')}"
        try:
            r = self.session.delete(url, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise RestconfError(f"DELETE {url} failed: {exc}") from exc

    def post_rpc(self, path: str, data: dict) -> dict:
        """Call a RESTCONF RPC (e.g., save-config)."""
        base_host = self.base.split("/restconf")[0].replace("https://", "")
        url = f"https://{base_host}/restconf/operations/{path.lstrip('/')}"
        try:
            r = self.session.post(url, json=data, timeout=15)
            r.raise_for_status()
        except requests.RequestException as exc:
            raise RestconfError(f"RPC {url} failed: {exc}") from exc
        try:
            return r.json()
        except ValueError:
            return {}


# ---------------------------------------------------------------------------
# SSH client
# ---------------------------------------------------------------------------

class SshClient:
    """SSH client using Paramiko for IOS/IOS-XE switches."""

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

def hr(char: str = "-", width: int = 72) -> None:
    print(char * width)


def header(title: str) -> None:
    hr("=")
    print(f"  {title}")
    hr("=")


def table(rows: list[list[Any]], columns: list[str]) -> None:
    if not rows:
        return
    widths = [max(len(str(r[i])) for r in ([columns] + rows)) for i in range(len(columns))]
    fmt = "  ".join(f"{{:<{w}}}" for w in widths)
    print(fmt.format(*columns))
    hr("-", sum(widths) + 2 * (len(widths) - 1))
    for row in rows:
        print(fmt.format(*[str(c) for c in row]))


# ---------------------------------------------------------------------------
# RESTCONF commands
# ---------------------------------------------------------------------------

def cmd_info(client: RestconfClient) -> None:
    header("System Information")
    data = client.get("Cisco-IOS-XE-native:native")
    native = data.get("Cisco-IOS-XE-native:native", data)

    hostname = native.get("hostname", "N/A")
    version  = native.get("version", "N/A")
    print(f"  {'Hostname':<20}: {hostname}")
    print(f"  {'IOS-XE Version':<20}: {version}")

    # Platform / hardware details
    hw = client.get("Cisco-IOS-XE-device-hardware-oper:device-hardware-data"
                    "/device-hardware/device-inventory")
    inv = hw.get(
        "Cisco-IOS-XE-device-hardware-oper:device-inventory", []
    )
    if isinstance(inv, dict):
        inv = [inv]
    for item in inv:
        if item.get("hw-type") == "hw-type-chassis":
            print(f"  {'Platform':<20}: {item.get('part-number', 'N/A')}")
            print(f"  {'Serial Number':<20}: {item.get('serial-number', 'N/A')}")
            print(f"  {'Description':<20}: {item.get('hw-description', 'N/A')}")
            break


def cmd_interfaces(client: RestconfClient) -> None:
    header("Interfaces")
    data = client.get("ietf-interfaces:interfaces")
    ifaces = data.get("ietf-interfaces:interfaces", {}).get("interface", [])
    if isinstance(ifaces, dict):
        ifaces = [ifaces]

    # Operational state
    ops = client.get("ietf-interfaces:interfaces-state")
    op_state: dict[str, dict] = {}
    for iface in ops.get("ietf-interfaces:interfaces-state", {}).get("interface", []):
        op_state[iface.get("name", "")] = iface

    rows = []
    for iface in ifaces:
        name    = iface.get("name", "N/A")
        enabled = "up" if iface.get("enabled", True) else "admin-down"
        itype   = iface.get("type", "N/A").split(":")[-1]
        desc    = iface.get("description", "")
        op      = op_state.get(name, {})
        oper    = op.get("oper-status", "N/A")
        speed   = op.get("speed", "N/A")
        rows.append([name, itype, enabled, oper, speed, desc])

    if rows:
        table(rows, ["Interface", "Type", "Admin", "Oper", "Speed", "Description"])
    else:
        print("  No interface data returned.")


def cmd_vlans(client: RestconfClient) -> None:
    header("VLANs")
    data = client.get("Cisco-IOS-XE-native:native/vlan")
    vlan_cfg = data.get("Cisco-IOS-XE-native:vlan", {})
    entries  = vlan_cfg.get("Cisco-IOS-XE-vlan:vlan-list", [])
    if isinstance(entries, dict):
        entries = [entries]

    rows = [[str(e.get("id", "N/A")), e.get("name", ""), e.get("state", "active")]
            for e in entries]
    if rows:
        table(rows, ["VLAN ID", "Name", "State"])
    else:
        print("  No VLAN data returned (or no VLANs configured).")


def cmd_vlan_add(client: RestconfClient, vlan_id: int, name: str | None) -> None:
    entry: dict[str, Any] = {"id": vlan_id}
    if name:
        entry["name"] = name
    payload = {"Cisco-IOS-XE-vlan:vlan-list": [entry]}
    client.patch("Cisco-IOS-XE-native:native/vlan", payload)
    label = f" ({name})" if name else ""
    print(f"  VLAN {vlan_id}{label} configured successfully.")


def cmd_vlan_remove(client: RestconfClient, vlan_id: int) -> None:
    client.delete(f"Cisco-IOS-XE-native:native/vlan/Cisco-IOS-XE-vlan:vlan-list={vlan_id}")
    print(f"  VLAN {vlan_id} removed.")


def cmd_neighbors(client: RestconfClient) -> None:
    header("CDP Neighbors")
    data = client.get("Cisco-IOS-XE-cdp-oper:cdp-neighbor-details")
    entries = data.get(
        "Cisco-IOS-XE-cdp-oper:cdp-neighbor-details", {}
    ).get("cdp-neighbor-detail", [])
    if isinstance(entries, dict):
        entries = [entries]

    rows = [[e.get("local-intf-name",  "N/A"),
             e.get("device-name",      "N/A"),
             e.get("port-id",          "N/A"),
             e.get("platform-name",    "N/A"),
             str(e.get("version", "N/A"))[:40]]
            for e in entries]

    if rows:
        table(rows, ["Local Intf", "Device ID", "Remote Port", "Platform", "Version"])
    else:
        print("  No CDP neighbor data returned.")


def cmd_routing(client: RestconfClient) -> None:
    header("IP Routing Table")
    data = client.get("Cisco-IOS-XE-ip-oper:ip-route-table")
    vrfs = data.get("Cisco-IOS-XE-ip-oper:ip-route-table", {}).get("vrf", [])
    if isinstance(vrfs, dict):
        vrfs = [vrfs]

    for vrf in vrfs:
        vrf_name = vrf.get("name", "default")
        print(f"\n  VRF: {vrf_name}")
        routes = vrf.get("ip-route", [])
        if isinstance(routes, dict):
            routes = [routes]
        rows = [[r.get("prefix",    "N/A"),
                 r.get("mask",      "N/A"),
                 r.get("next-hop",  "N/A"),
                 r.get("source-protocol", "N/A"),
                 r.get("metric",    "N/A")]
                for r in routes]
        if rows:
            table(rows, ["Prefix", "Mask", "Next-Hop", "Protocol", "Metric"])


def cmd_spanning_tree(client: RestconfClient) -> None:
    header("Spanning Tree")
    data = client.get("Cisco-IOS-XE-spanning-tree-oper:stp-details")
    instances = data.get(
        "Cisco-IOS-XE-spanning-tree-oper:stp-details", {}
    ).get("stp-detail", [])
    if isinstance(instances, dict):
        instances = [instances]

    for inst in instances:
        vlan = inst.get("instance", "N/A")
        mode = inst.get("mode", "N/A")
        root_id    = inst.get("root-bridge-id",    "N/A")
        bridge_id  = inst.get("bridge-id",         "N/A")
        root_cost  = inst.get("root-path-cost",    "N/A")
        hello_time = inst.get("hello-time",        "N/A")
        print(f"\n  Instance: {vlan}  Mode: {mode}")
        print(f"    {'Root Bridge ID':<20}: {root_id}")
        print(f"    {'This Bridge ID':<20}: {bridge_id}")
        print(f"    {'Root Path Cost':<20}: {root_cost}")
        print(f"    {'Hello Time':<20}: {hello_time}")

        ports = inst.get("stp-port", [])
        if isinstance(ports, dict):
            ports = [ports]
        rows = [[p.get("name",       "N/A"),
                 p.get("role",       "N/A"),
                 p.get("state",      "N/A"),
                 p.get("cost",       "N/A"),
                 p.get("priority",   "N/A")]
                for p in ports]
        if rows:
            print()
            table(rows, ["Port", "Role", "State", "Cost", "Priority"])


def cmd_mac_table(client: RestconfClient) -> None:
    header("MAC Address Table")
    data = client.get("Cisco-IOS-XE-matm-oper:matm-oper-data/matm-table")
    entries = data.get(
        "Cisco-IOS-XE-matm-oper:matm-table", []
    )
    if isinstance(entries, dict):
        entries = [entries]

    rows = []
    for e in entries:
        vlan    = e.get("vlan-id",    "N/A")
        mac     = e.get("mac-address","N/A")
        iface   = e.get("interface",  "N/A")
        mtype   = e.get("attr",       "N/A")
        rows.append([str(vlan), mac, iface, mtype])

    if rows:
        table(rows, ["VLAN", "MAC Address", "Interface", "Type"])
    else:
        print("  No MAC table data returned.")


def cmd_run(client: RestconfClient, command: str) -> None:
    """RESTCONF does not support arbitrary CLI — use SSH mode for raw commands."""
    print(f"  NOTE: RESTCONF does not support arbitrary CLI commands.")
    print(f"  Re-run with --ssh to execute: {command}")


def cmd_save(client: RestconfClient) -> None:
    print("  Saving configuration via RESTCONF RPC...")
    try:
        client.post_rpc("cisco-ia:save-config", {})
        print("  Configuration saved.")
    except RestconfError as first_exc:
        # IOS-XE older firmware may use a different RPC namespace
        try:
            client.post_rpc("Cisco-IOS-XE-rpc:save-config", {})
            print("  Configuration saved.")
        except RestconfError as exc:
            raise RestconfError(
                f"Save failed with both RPC namespaces. "
                f"First: {first_exc}. Second: {exc}"
            ) from exc


# ---------------------------------------------------------------------------
# SSH commands
# ---------------------------------------------------------------------------

SSH_MAP = {
    "info":         "show version",
    "interfaces":   "show interfaces status",
    "vlans":        "show vlan brief",
    "neighbors":    "show cdp neighbors",
    "routing":      "show ip route",
    "spanning-tree":"show spanning-tree summary",
    "mac-table":    "show mac address-table",
    "save":         "write memory",
}


def cmd_ssh_run(ssh: SshClient, command: str) -> None:
    header(f"SSH Command: {command}")
    print(ssh.run(command))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Cisco Catalyst Switch Manager (IOS / IOS-XE)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    p.add_argument("--host",     required=True, help="Switch IP or hostname")
    p.add_argument("--user",     default=os.environ.get("CATALYST_USER", "admin"),
                   help="Username (default: $CATALYST_USER or 'admin')")
    p.add_argument("--password", default=os.environ.get("CATALYST_PASS"),
                   help="Password (default: $CATALYST_PASS; prompted if omitted)")
    p.add_argument("--port",     type=int, default=None,
                   help="Port override (default: 443 RESTCONF, 22 SSH)")
    p.add_argument("--no-verify", action="store_true",
                   help="Disable TLS certificate verification")
    p.add_argument("--no-verify-host", action="store_true",
                   help="Disable SSH host key verification (insecure, use only in labs)")
    p.add_argument("--ssh",      action="store_true",
                   help="Force SSH mode instead of RESTCONF")

    sub = p.add_subparsers(dest="command", metavar="COMMAND")
    sub.required = True

    sub.add_parser("info",          help="Show system/version info")
    sub.add_parser("interfaces",    help="Show interface status")
    sub.add_parser("vlans",         help="List VLANs")
    sub.add_parser("neighbors",     help="Show CDP neighbors")
    sub.add_parser("routing",       help="Show IP routing table")
    sub.add_parser("spanning-tree", help="Show spanning-tree state")
    sub.add_parser("mac-table",     help="Show MAC address table")
    sub.add_parser("save",          help="Save running-config to startup-config")

    va = sub.add_parser("vlan-add",    help="Add or update a VLAN")
    va.add_argument("vlan_id", type=int)
    va.add_argument("--name",  help="VLAN name")

    vr = sub.add_parser("vlan-remove", help="Remove a VLAN")
    vr.add_argument("vlan_id", type=int)

    rc = sub.add_parser("run-cmd",     help="Run a raw IOS command (SSH mode only)")
    rc.add_argument("cmd", help="IOS command to execute")

    return p.parse_args()


def main() -> None:
    args = parse_args()

    password = args.password
    if not password:
        password = getpass.getpass(f"Password for {args.user}@{args.host}: ")

    if args.no_verify:
        print("WARNING: TLS certificate verification is disabled.", file=sys.stderr)

    # SSH mode
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
        try:
            if args.command == "run-cmd":
                cmd_ssh_run(ssh, args.cmd)
            elif args.command in SSH_MAP:
                cmd_ssh_run(ssh, SSH_MAP[args.command])
            elif args.command in ("vlan-add", "vlan-remove"):
                print("  VLAN configuration via SSH is not supported in this script.",
                      file=sys.stderr)
                print("  Use RESTCONF mode (drop --ssh) or run-cmd with manual IOS commands.",
                      file=sys.stderr)
            else:
                print(f"  Unknown command: {args.command}", file=sys.stderr)
        finally:
            ssh.close()
        return

    # RESTCONF mode
    if not HAS_REQUESTS:
        print("ERROR: RESTCONF mode requires requests — pip install requests", file=sys.stderr)
        sys.exit(1)

    verify = not args.no_verify
    port   = args.port or 443
    client = RestconfClient(args.host, args.user, password, port=port, verify=verify)

    try:
        dispatch = {
            "info":          lambda: cmd_info(client),
            "interfaces":    lambda: cmd_interfaces(client),
            "vlans":         lambda: cmd_vlans(client),
            "vlan-add":      lambda: cmd_vlan_add(client, args.vlan_id,
                                                   getattr(args, "name", None)),
            "vlan-remove":   lambda: cmd_vlan_remove(client, args.vlan_id),
            "neighbors":     lambda: cmd_neighbors(client),
            "routing":       lambda: cmd_routing(client),
            "spanning-tree": lambda: cmd_spanning_tree(client),
            "mac-table":     lambda: cmd_mac_table(client),
            "run-cmd":       lambda: cmd_run(client, args.cmd),
            "save":          lambda: cmd_save(client),
        }
        dispatch[args.command]()
    except RestconfError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted.", file=sys.stderr)
        sys.exit(130)


if __name__ == "__main__":
    main()
