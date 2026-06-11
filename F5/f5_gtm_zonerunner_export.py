#!/usr/bin/env python3
"""
F5 GTM (BIG-IP DNS) ZoneRunner A/CNAME Export

Extracts every A and CNAME resource record from the BIG-IP's ZoneRunner DNS
zones via the iControl REST API and writes them as CSV. ZoneRunner manages the
raw DNS zones served by the BIG-IP's named/BIND instance, so this captures
records that are NOT Wide IPs (which the /mgmt/tm/gtm/wideip/* APIs would miss).

By default the script auto-discovers all DNS views and all zones, then pulls the
records for each. Use --view / --zone to narrow the scope.

Usage examples:
  # Export every A/CNAME record from all views/zones to a file:
  python3 f5_gtm_zonerunner_export.py --host bigip.example.com \\
      --user admin --output records.csv

  # Prompt for password (omit --password) and print CSV to stdout:
  python3 f5_gtm_zonerunner_export.py --host 10.0.0.1 --user admin

  # Limit to one view and one zone, with raw-JSON debugging:
  python3 f5_gtm_zonerunner_export.py --host 10.0.0.1 --user admin \\
      --view external --zone example.com. --debug

Credentials are resolved from --user/--password, then the F5_USER/F5_PASS
environment variables, then an interactive prompt for the password.

Requires: requests  (pip install requests)
"""

import argparse
import csv
import getpass
import json
import os
import sys

import requests
from urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# Record types we care about for the export.
WANTED_TYPES = {"A", "CNAME"}

CSV_COLUMNS = ["view", "zone", "name", "type", "ttl", "value"]


class ZoneRunnerError(Exception):
    """Raised when a ZoneRunner iControl REST call fails."""


class F5ZoneRunnerClient:
    """Thin wrapper around the iControl REST ZoneRunner workspace."""

    def __init__(self, host, username, password, verify=False, timeout=15,
                 debug=False):
        self.base_url = f"https://{host}/mgmt/tm/zonerunner"
        self.timeout = timeout
        self.debug = debug
        self.session = requests.Session()
        self.session.verify = verify
        self.session.auth = (username, password)
        self.session.headers.update({"Content-Type": "application/json"})

    def _get(self, endpoint, params=None):
        url = f"{self.base_url}/{endpoint}"
        try:
            resp = self.session.get(url, params=params, timeout=self.timeout)
        except requests.exceptions.RequestException as exc:
            raise ZoneRunnerError(f"GET {url} failed: {exc}") from exc
        if resp.status_code != 200:
            raise ZoneRunnerError(
                f"GET {resp.url} returned {resp.status_code}: {resp.text}"
            )
        try:
            data = resp.json()
        except ValueError as exc:
            raise ZoneRunnerError(
                f"GET {resp.url} returned non-JSON body: {resp.text[:200]}"
            ) from exc
        if self.debug:
            print(f"--- DEBUG {resp.url}\n{json.dumps(data, indent=2)}\n",
                  file=sys.stderr)
        return data

    def get_views(self):
        """Return a list of DNS view names."""
        data = self._get("view")
        return [item["name"] for item in data.get("items", []) if "name" in item]

    def get_zones(self, view=None):
        """Return a list of {name, view} dicts for all (or one view's) zones."""
        data = self._get("zone")
        zones = []
        for item in data.get("items", []):
            name = item.get("name")
            if not name:
                continue
            zone_view = item.get("viewName") or item.get("view")
            if view and zone_view and zone_view != view:
                continue
            zones.append({"name": name, "view": zone_view or view})
        return zones

    def get_resource_records(self, view, zone):
        """Return the raw resource-record items for a single zone/view.

        The ZoneRunner resource-record endpoint is scoped to a zone (and view)
        via the tmsh-style `options` query parameter. The accepted option shape
        varies slightly by TMOS version, so we try the documented form first and
        fall back to an unscoped query (filtered client-side) if that is
        rejected.
        """
        option_str = f"zone-name {zone} view-name {view}"
        try:
            data = self._get("resource-record", params={"options": option_str})
        except ZoneRunnerError:
            # Fallback: unscoped fetch, filter by zone client-side below.
            data = self._get("resource-record")
        items = data.get("items", [])
        # When the unscoped fallback is used, keep only this zone's records.
        return [it for it in items if _record_in_zone(it, zone)]


def _record_in_zone(item, zone):
    """Best-effort check that a record item belongs to the given zone."""
    rec_zone = item.get("zoneName") or item.get("zone")
    if rec_zone:
        return rec_zone == zone
    # No zone field present (scoped query) -> assume it belongs.
    return True


def _extract_value(item):
    """Pull the human-meaningful value out of a record item across TMOS shapes."""
    for key in ("rdata", "ipAddress", "host", "cname", "address", "value"):
        val = item.get(key)
        if val:
            return val
    return ""


def collect_records(client, view_filter=None, zone_filter=None):
    """Walk views/zones and return normalized A/CNAME rows."""
    views = [view_filter] if view_filter else client.get_views()
    if not views:
        print("WARNING: no DNS views found.", file=sys.stderr)

    rows = []
    for view in views:
        zones = client.get_zones(view=view)
        if zone_filter:
            zones = [z for z in zones if z["name"] == zone_filter]
        for zone in zones:
            zone_name = zone["name"]
            try:
                records = client.get_resource_records(view, zone_name)
            except ZoneRunnerError as exc:
                print(f"WARNING: skipping zone {zone_name} (view {view}): {exc}",
                      file=sys.stderr)
                continue
            for rec in records:
                rec_type = (rec.get("type") or "").upper()
                if rec_type not in WANTED_TYPES:
                    continue
                rows.append({
                    "view": view,
                    "zone": zone_name,
                    "name": rec.get("name", ""),
                    "type": rec_type,
                    "ttl": rec.get("ttl", ""),
                    "value": _extract_value(rec),
                })
    return rows


def write_csv(rows, output=None):
    """Write rows as CSV to a file path or stdout."""
    handle = open(output, "w", newline="") if output else sys.stdout
    try:
        writer = csv.DictWriter(handle, fieldnames=CSV_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)
    finally:
        if output:
            handle.close()


def parse_args():
    parser = argparse.ArgumentParser(
        description="Export all A and CNAME records from F5 GTM ZoneRunner as CSV.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--host", required=True,
                        help="BIG-IP DNS (GTM) hostname or IP address")
    parser.add_argument("--user", default=os.environ.get("F5_USER", "admin"),
                        help="Username (default: $F5_USER or 'admin')")
    parser.add_argument("--password", default=os.environ.get("F5_PASS"),
                        help="Password (default: $F5_PASS, else prompted)")
    parser.add_argument("--view", help="Limit to a single DNS view")
    parser.add_argument("--zone",
                        help="Limit to a single zone (FQDN with trailing dot)")
    parser.add_argument("--output",
                        help="CSV output file path (default: stdout)")
    parser.add_argument("--timeout", type=int, default=15,
                        help="Per-request timeout in seconds (default: 15)")
    parser.add_argument("--verify", action="store_true",
                        help="Verify the BIG-IP TLS certificate (default: off)")
    parser.add_argument("--debug", action="store_true",
                        help="Dump raw JSON responses to stderr")
    return parser.parse_args()


def main():
    args = parse_args()

    password = args.password
    if not password:
        password = getpass.getpass(f"Password for {args.user}@{args.host}: ")

    client = F5ZoneRunnerClient(
        host=args.host,
        username=args.user,
        password=password,
        verify=args.verify,
        timeout=args.timeout,
        debug=args.debug,
    )

    try:
        rows = collect_records(client, view_filter=args.view,
                               zone_filter=args.zone)
    except ZoneRunnerError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    write_csv(rows, output=args.output)

    dest = args.output or "stdout"
    print(f"Exported {len(rows)} A/CNAME record(s) to {dest}.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
