#!/usr/bin/env python3
"""
F5 GTM (BIG-IP DNS) ZoneRunner A/CNAME Export

Extracts every A and CNAME resource record from the BIG-IP's ZoneRunner DNS
zones and writes them as CSV. ZoneRunner manages the raw DNS zones served by the
BIG-IP's named/BIND instance, so this captures records that are NOT Wide IPs
(which the GTM wide-IP APIs would miss).

ZoneRunner is NOT exposed through the iControl REST (/mgmt/tm) namespace, so this
script uses the iControl SOAP interfaces via the official `bigsuds` library:
  * Management.Zone.get_list()            -> all (view, zone) pairs
  * Management.ResourceRecord.get_rrs()   -> records per zone (zone-file format)

By default the script auto-discovers all DNS views and all zones, then pulls the
records for each. Use --view / --zone to narrow the scope.

Usage examples:
  # Export every A/CNAME record from all views/zones to a file:
  python3 f5_gtm_zonerunner_export.py --host bigip.example.com \\
      --user admin --output records.csv

  # Prompt for password (omit --password) and print CSV to stdout:
  python3 f5_gtm_zonerunner_export.py --host 10.0.0.1 --user admin

  # Limit to one view and one zone, with SOAP debugging:
  python3 f5_gtm_zonerunner_export.py --host 10.0.0.1 --user admin \\
      --view external --zone example.com. --debug

Credentials are resolved from --user/--password, then the F5_USER/F5_PASS
environment variables, then an interactive prompt for the password.

Requires: bigsuds  (pip install bigsuds)
"""

import argparse
import csv
import getpass
import os
import socket
import sys

# Record types we care about for the export.
WANTED_TYPES = {"A", "CNAME"}

# DNS class tokens that may appear in a zone-file record line.
DNS_CLASSES = {"IN", "CH", "HS", "CS"}

CSV_COLUMNS = ["view", "zone", "name", "type", "ttl", "value"]


class ZoneRunnerError(Exception):
    """Raised when a ZoneRunner SOAP call fails."""


def connect(host, username, password, verify=False, debug=False):
    """Open an iControl SOAP session, returning a bigsuds.BIGIP instance."""
    try:
        import bigsuds
    except ImportError:
        raise ZoneRunnerError(
            "the 'bigsuds' library is required. Install it with: pip install bigsuds"
        )
    kwargs = dict(hostname=host, username=username, password=password, debug=debug)
    try:
        # Newer bigsuds supports a verify kwarg; older versions do not.
        return bigsuds.BIGIP(verify=verify, **kwargs)
    except TypeError:
        return bigsuds.BIGIP(**kwargs)
    except Exception as exc:  # bigsuds raises various connection errors
        raise ZoneRunnerError(f"failed to connect to {host}: {exc}") from exc


def _vz_attr(view_zone, attr):
    """Read view_name/zone_name from a bigsuds ViewZone object or dict."""
    if isinstance(view_zone, dict):
        return view_zone.get(attr)
    return getattr(view_zone, attr, None)


def list_view_zones(bigip, view_filter=None, zone_filter=None):
    """Return the list of (view, zone) pairs, optionally filtered."""
    try:
        view_zones = bigip.Management.Zone.get_list()
    except Exception as exc:
        raise ZoneRunnerError(f"Management.Zone.get_list() failed: {exc}") from exc

    result = []
    for vz in view_zones:
        view = _vz_attr(vz, "view_name")
        zone = _vz_attr(vz, "zone_name")
        if not zone:
            continue
        if view_filter and view != view_filter:
            continue
        if zone_filter and zone != zone_filter:
            continue
        result.append(vz)
    return result


def get_zone_rrs(bigip, view_zone):
    """Return the raw resource-record strings for one (view, zone) pair."""
    try:
        rrs = bigip.Management.ResourceRecord.get_rrs(view_zones=[view_zone])
    except Exception as exc:
        raise ZoneRunnerError(f"get_rrs failed: {exc}") from exc
    # get_rrs returns a list-of-lists, one inner list per requested view_zone.
    return rrs[0] if rrs else []


def parse_rr_line(line, last_name):
    """Parse a zone-file record line into a dict, tracking the inherited owner.

    Returns (record_or_None, updated_last_name). Comment and directive lines
    yield None. Owner names that are omitted (blank/continuation lines) inherit
    from the previous record.
    """
    if not line or not line.strip():
        return None, last_name
    stripped = line.strip()
    if stripped.startswith(";") or stripped.startswith("$"):
        return None, last_name

    tokens = stripped.split()

    # Determine the owner name. If the line is indented, or the first token is a
    # TTL/class/type rather than a name, the owner is inherited.
    first = tokens[0]
    if line[0].isspace() or first.isdigit() or first.upper() in DNS_CLASSES:
        name = last_name
        rest = tokens
    else:
        name = first
        rest = tokens[1:]
        last_name = name

    idx = 0
    ttl = ""
    if idx < len(rest) and rest[idx].isdigit():
        ttl = rest[idx]
        idx += 1
    if idx < len(rest) and rest[idx].upper() in DNS_CLASSES:
        idx += 1
    if idx >= len(rest):
        return None, last_name

    rtype = rest[idx].upper()
    value = " ".join(rest[idx + 1:])
    return {"name": name, "ttl": ttl, "type": rtype, "value": value}, last_name


def collect_records(bigip, view_filter=None, zone_filter=None, debug=False):
    """Walk all matching zones and return normalized A/CNAME rows."""
    view_zones = list_view_zones(bigip, view_filter, zone_filter)
    if not view_zones:
        print("WARNING: no matching zones found.", file=sys.stderr)

    rows = []
    for vz in view_zones:
        view = _vz_attr(vz, "view_name") or ""
        zone = _vz_attr(vz, "zone_name") or ""
        try:
            rr_lines = get_zone_rrs(bigip, vz)
        except ZoneRunnerError as exc:
            print(f"WARNING: skipping zone {zone} (view {view}): {exc}",
                  file=sys.stderr)
            continue

        last_name = zone
        for line in rr_lines:
            rec, last_name = parse_rr_line(line, last_name)
            if not rec or rec["type"] not in WANTED_TYPES:
                continue
            rows.append({
                "view": view,
                "zone": zone,
                "name": rec["name"],
                "type": rec["type"],
                "ttl": rec["ttl"],
                "value": rec["value"],
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
                        help="Socket timeout in seconds (default: 15)")
    parser.add_argument("--verify", action="store_true",
                        help="Verify the BIG-IP TLS certificate (default: off)")
    parser.add_argument("--debug", action="store_true",
                        help="Print raw SOAP traffic to stderr")
    return parser.parse_args()


def main():
    args = parse_args()
    socket.setdefaulttimeout(args.timeout)

    password = args.password
    if not password:
        password = getpass.getpass(f"Password for {args.user}@{args.host}: ")

    try:
        bigip = connect(args.host, args.user, password,
                        verify=args.verify, debug=args.debug)
        rows = collect_records(bigip, view_filter=args.view,
                               zone_filter=args.zone, debug=args.debug)
    except ZoneRunnerError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    write_csv(rows, output=args.output)

    dest = args.output or "stdout"
    print(f"Exported {len(rows)} A/CNAME record(s) to {dest}.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
