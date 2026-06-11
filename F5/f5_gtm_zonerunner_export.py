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

  # Limit to one view and one zone, with diagnostics:
  python3 f5_gtm_zonerunner_export.py --host 10.0.0.1 --user admin \\
      --view external --zone example.com. --debug

Credentials are resolved from --user/--password, then the F5_USER/F5_PASS
environment variables, then an interactive prompt for the password.

Requires: bigsuds  (pip install bigsuds)
"""

import argparse
import csv
import getpass
import logging
import os
import socket
import sys

# Silence suds' chatter (e.g. "(ViewZone) not-found" while the WSDL schema is
# being resolved); it is harmless and would otherwise pollute the output.
logging.getLogger("suds").setLevel(logging.CRITICAL)

# Record types we care about for the export.
WANTED_TYPES = {"A", "CNAME"}

# DNS class tokens that may appear in a zone-file record line.
DNS_CLASSES = {"IN", "CH", "HS", "CS"}

CSV_COLUMNS = ["view", "zone", "name", "type", "ttl", "value"]


class ZoneRunnerError(Exception):
    """Raised when a ZoneRunner SOAP call fails."""


def connect(host, username, password, verify=False, debug=False):
    """Open an iControl SOAP session, returning a bigsuds.BIGIP instance.

    Note: we intentionally do NOT pass bigsuds' own `debug` flag. On some
    bigsuds/Python 3 combinations enabling it triggers a bytes/str TypeError
    during WSDL discovery (get_wsdls). This script does its own debug logging
    instead, so bigsuds debug is unnecessary.
    """
    try:
        import bigsuds
    except ImportError:
        raise ZoneRunnerError(
            "the 'bigsuds' library is required. Install it with: pip install bigsuds"
        )
    kwargs = dict(hostname=host, username=username, password=password)
    try:
        # Newer bigsuds supports a verify kwarg; older versions do not.
        return bigsuds.BIGIP(verify=verify, **kwargs)
    except TypeError as exc:
        if "verify" not in str(exc):
            raise ZoneRunnerError(f"failed to connect to {host}: {exc}") from exc
        return bigsuds.BIGIP(**kwargs)
    except Exception as exc:  # bigsuds raises various connection errors
        raise ZoneRunnerError(f"failed to connect to {host}: {exc}") from exc


def _find_suds_client(obj, seen=None, depth=0):
    """Walk a bigsuds interface proxy's attributes to find its suds Client."""
    try:
        from suds.client import Client as SudsClient
    except ImportError:
        return None
    if isinstance(obj, SudsClient):
        return obj
    if obj is None or depth > 4:
        return None
    seen = seen if seen is not None else set()
    if id(obj) in seen:
        return None
    seen.add(id(obj))
    try:
        members = vars(obj)
    except TypeError:
        return None
    for value in members.values():
        if isinstance(value, SudsClient):
            return value
    for value in members.values():
        found = _find_suds_client(value, seen, depth + 1)
        if found is not None:
            return found
    return None


def get_type_factory(bigip, interface):
    """Return a suds type factory for building typed structs on an interface.

    Passing a plain dict for a typed SOAP struct (e.g. ViewZone) fails with
    'Type not found'; the struct must be created through the WSDL's factory so
    it carries its type. Returns None if no factory can be located.
    """
    namespace, name = interface.split(".", 1)
    proxy = getattr(getattr(bigip, namespace), name)
    # bigsuds proxies treat unknown attribute access as a SOAP method call, so
    # only read the real `_client` attribute (set in __init__); never getattr a
    # guessed name. Fall back to a recursive search if the layout differs.
    client = proxy.__dict__.get("_client") or _find_suds_client(proxy)
    return client.factory if client is not None else None


def make_view_zone(factory, view, zone):
    """Build a ViewZone for get_rrs, as a typed struct if possible, else a dict."""
    if factory is not None:
        try:
            vz = factory.create("ViewZone")
            vz.view_name = view
            vz.zone_name = zone
            return vz
        except Exception:  # noqa: BLE001 - fall back to a plain dict
            pass
    return {"view_name": view, "zone_name": zone}


def _vz_attr(view_zone, attr):
    """Read view_name/zone_name from a ViewZone object or dict."""
    if isinstance(view_zone, dict):
        return view_zone.get(attr)
    return getattr(view_zone, attr, None)


def _view_name(item):
    """Normalize a Management.View.get_list() entry to a plain view name."""
    if isinstance(item, str):
        return item
    if isinstance(item, dict):
        return item.get("view_name") or item.get("name")
    return getattr(item, "view_name", None) or getattr(item, "name", None)


def _zone_names(raw):
    """Yield zone-name strings from a get_zone_name() result of unknown shape.

    The SOAP result may be a flat list of strings, a nested String[][], a list
    of ZoneName structs (dict/suds objects exposing `zone_name`), or a suds
    array object exposing its elements under `.item`. Normalize all of these to
    plain zone-name strings.
    """
    if raw is None:
        return
    if isinstance(raw, str):
        s = raw.strip()
        if s:
            yield s
        return
    if isinstance(raw, dict):
        if raw.get("zone_name") or raw.get("name"):
            yield from _zone_names(raw.get("zone_name") or raw.get("name"))
        elif "item" in raw:
            yield from _zone_names(raw["item"])
        return
    # suds struct exposing a zone_name / name attribute
    attr = getattr(raw, "zone_name", None) or getattr(raw, "name", None)
    if isinstance(attr, str):
        yield from _zone_names(attr)
        return
    # suds array object exposes its elements under .item
    item = getattr(raw, "item", None)
    if item is not None:
        yield from _zone_names(item)
        return
    # generic iterable (list / tuple / suds array)
    try:
        iterator = iter(raw)
    except TypeError:
        return
    for element in iterator:
        yield from _zone_names(element)


def list_view_zones(bigip, view_filter=None, zone_filter=None, debug=False):
    """Return a list of {view_name, zone_name} dicts, optionally filtered.

    ZoneRunner has no "list all zones" SOAP method, so we enumerate views with
    Management.View.get_list() and then the zones in each view with
    Management.Zone.get_zone_name(). Querying one view at a time keeps the
    returned zone list unambiguously associated with its view.
    """
    try:
        raw_views = bigip.Management.View.get_list()
    except Exception as exc:
        raise ZoneRunnerError(
            f"Management.View.get_list() failed: {exc}") from exc

    views = [v for v in (_view_name(x) for x in raw_views) if v]
    if view_filter:
        views = [v for v in views if v == view_filter]

    # Compare zone names without the trailing dot so --zone works either way.
    zone_target = zone_filter.rstrip(".") if zone_filter else None

    view_zones = []
    for view in views:
        try:
            raw_zones = bigip.Management.Zone.get_zone_name(view_names=[view])
        except Exception as exc:
            print(f"WARNING: get_zone_name failed for view {view}: {exc}",
                  file=sys.stderr)
            continue
        if debug:
            print(f"--- DEBUG get_zone_name(view={view}) -> "
                  f"{type(raw_zones).__name__}: {repr(raw_zones)[:400]}",
                  file=sys.stderr)
        for zone in _zone_names(raw_zones):
            if zone_target and zone.rstrip(".") != zone_target:
                continue
            view_zones.append({"view_name": view, "zone_name": zone})
    return view_zones


def get_zone_rrs(bigip, view, zone, factory=None):
    """Return the raw resource-record strings for one (view, zone) pair."""
    view_zone = make_view_zone(factory, view, zone)
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
    view_zones = list_view_zones(bigip, view_filter, zone_filter, debug=debug)
    if not view_zones:
        print("WARNING: no matching zones found.", file=sys.stderr)

    factory = get_type_factory(bigip, "Management.ResourceRecord")

    rows = []
    for vz in view_zones:
        view = _vz_attr(vz, "view_name") or ""
        zone = _vz_attr(vz, "zone_name") or ""
        try:
            rr_lines = get_zone_rrs(bigip, view, zone, factory)
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
                        help="Print the raw get_zone_name result shape to stderr")
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
