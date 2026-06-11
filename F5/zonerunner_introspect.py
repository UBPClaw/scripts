#!/usr/bin/env python3
"""
Diagnostic helper: list the iControl SOAP operations actually exposed by the
ZoneRunner-related interfaces on a given BIG-IP. Use this to discover the real
method names (e.g. how to enumerate zones/views) so f5_gtm_zonerunner_export.py
can call them correctly.

This goes through `bigsuds` (which already applies the SOAP-encoding ImportDoctor
fix the iControl WSDLs need) and reaches into the underlying suds client to read
the method list, rather than parsing the WSDL with raw suds.

Usage:
  python3 zonerunner_introspect.py --host <BIG-IP> --user admin
  python3 zonerunner_introspect.py --host <BIG-IP> --user admin --interface Management.Zone

Requires: bigsuds  (pip install bigsuds)
"""

import argparse
import getpass
import os
import sys

# ZoneRunner / DNS related SOAP interfaces to introspect by default.
DEFAULT_INTERFACES = [
    "Management.Zone",
    "Management.ResourceRecord",
    "Management.View",
    "Management.Named",
]


def connect(host, user, password, debug=False):
    import bigsuds
    kwargs = dict(hostname=host, username=user, password=password, debug=debug)
    try:
        return bigsuds.BIGIP(verify=False, **kwargs)
    except TypeError:
        return bigsuds.BIGIP(**kwargs)


def _find_suds_client(obj, seen=None, depth=0):
    """Walk a bigsuds interface proxy's attributes to find the suds Client."""
    from suds.client import Client as SudsClient
    if isinstance(obj, SudsClient):
        return obj
    if depth > 4 or obj is None:
        return None
    seen = seen if seen is not None else set()
    if id(obj) in seen:
        return None
    seen.add(id(obj))
    try:
        members = vars(obj)
    except TypeError:
        return None
    # Direct hit first.
    for value in members.values():
        if isinstance(value, SudsClient):
            return value
    # Then recurse.
    for value in members.values():
        found = _find_suds_client(value, seen, depth + 1)
        if found is not None:
            return found
    return None


def list_methods(bigip, interface):
    namespace, name = interface.split(".", 1)
    iface_obj = getattr(getattr(bigip, namespace), name)
    client = _find_suds_client(iface_obj)
    if client is None:
        raise RuntimeError("could not locate suds client on the bigsuds proxy")

    from suds.servicedefinition import ServiceDefinition
    signatures = []
    for service in client.wsdl.services:
        sd = ServiceDefinition(client.wsdl, service)
        for _port, methods in sd.ports:
            for mname, params in methods:
                sig = ", ".join("%s %s" % (ptype, pname) for pname, ptype in params)
                signatures.append("%s(%s)" % (mname, sig))
    return sorted(set(signatures))


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", default=os.environ.get("F5_USER", "admin"))
    parser.add_argument("--password", default=os.environ.get("F5_PASS"))
    parser.add_argument("--interface", action="append",
                        help="SOAP interface to introspect (repeatable). "
                             "Default: the ZoneRunner/DNS interfaces.")
    parser.add_argument("--debug", action="store_true",
                        help="Print raw SOAP traffic to stderr")
    args = parser.parse_args()

    password = args.password or getpass.getpass(
        f"Password for {args.user}@{args.host}: ")
    interfaces = args.interface or DEFAULT_INTERFACES

    bigip = connect(args.host, args.user, password, debug=args.debug)

    for interface in interfaces:
        print("=" * 72)
        print(interface)
        print("-" * 72)
        try:
            for name in list_methods(bigip, interface):
                print(f"  {name}")
        except Exception as exc:  # noqa: BLE001 - report and continue
            print(f"  ERROR: {exc}")
        print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
