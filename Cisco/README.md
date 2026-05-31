# Cisco Switch Management Scripts

Python scripts for managing Cisco network switches via REST APIs and SSH.

---

## Scripts

| Script | Target Platform | Primary Protocol |
|---|---|---|
| `nexus_manager.py` | Cisco Nexus (NX-OS) | NX-API (JSON-RPC over HTTPS) |
| `catalyst_manager.py` | Cisco Catalyst (IOS / IOS-XE) | RESTCONF (RFC 8040 over HTTPS) |

---

## Requirements

```bash
pip install requests paramiko
```

- `requests` — required for NX-API and RESTCONF modes
- `paramiko` — required for SSH mode only

Python 3.10+ is required (uses `X | Y` union type hints).

---

## nexus_manager.py

Manages Cisco Nexus switches running NX-OS via NX-API. NX-API must be enabled on the switch:

```
feature nxapi
```

### Connection options

| Flag | Default | Description |
|---|---|---|
| `--host` | *(required)* | Switch IP or hostname |
| `--user` | `$NEXUS_USER` or `admin` | Login username |
| `--password` | `$NEXUS_PASS` | Login password (prompted if omitted) |
| `--port` | `443` (HTTPS) / `80` (HTTP) | Override API port |
| `--no-ssl` | off | Use HTTP instead of HTTPS |
| `--ssh` | off | Force SSH mode (requires paramiko) |

### Commands

| Command | Description |
|---|---|
| `info` | Hostname, NX-OS version, uptime, memory |
| `interfaces` | Interface brief — state, speed, VLAN, mode |
| `vlans` | VLAN ID, name, state, MTU |
| `vlan-add <id> [--name NAME]` | Create or rename a VLAN |
| `vlan-remove <id>` | Delete a VLAN |
| `neighbors` | CDP neighbor table |
| `routing` | IP route summary per VRF |
| `bgp` | BGP peer state and prefix counts |
| `inventory` | Hardware inventory — PID and serial numbers |
| `run-cmd "CMD"` | Run any NX-OS show or config command |
| `save` | Copy running-config to startup-config |

### Examples

```bash
# System info
python nexus_manager.py --host 10.0.0.1 info

# List VLANs
python nexus_manager.py --host 10.0.0.1 --user admin vlans

# Add a VLAN
python nexus_manager.py --host 10.0.0.1 vlan-add 200 --name SERVERS

# Remove a VLAN
python nexus_manager.py --host 10.0.0.1 vlan-remove 200

# Run an arbitrary command
python nexus_manager.py --host 10.0.0.1 run-cmd "show bgp summary"

# Use SSH instead of NX-API
python nexus_manager.py --host 10.0.0.1 --ssh interfaces

# Use environment variables for credentials
export NEXUS_USER=admin
export NEXUS_PASS=secret
python nexus_manager.py --host 10.0.0.1 info
```

---

## catalyst_manager.py

Manages Cisco Catalyst switches running IOS-XE via RESTCONF. RESTCONF must be enabled on the switch:

```
restconf
ip http secure-server
```

Falls back to SSH for older IOS switches or raw CLI output.

### Connection options

| Flag | Default | Description |
|---|---|---|
| `--host` | *(required)* | Switch IP or hostname |
| `--user` | `$CATALYST_USER` or `admin` | Login username |
| `--password` | `$CATALYST_PASS` | Login password (prompted if omitted) |
| `--port` | `443` | Override RESTCONF/SSH port |
| `--no-verify` | off | Disable TLS certificate verification |
| `--ssh` | off | Force SSH mode (requires paramiko) |

### Commands

| Command | Description |
|---|---|
| `info` | Hostname, IOS-XE version, platform, serial number |
| `interfaces` | Admin/oper state, speed, description |
| `vlans` | VLAN ID, name, state |
| `vlan-add <id> [--name NAME]` | Create or rename a VLAN |
| `vlan-remove <id>` | Delete a VLAN |
| `neighbors` | CDP neighbor table |
| `routing` | IP routing table per VRF |
| `spanning-tree` | STP instance details and per-port role/state |
| `mac-table` | MAC address table — VLAN, MAC, interface, type |
| `run-cmd "CMD"` | Run a raw IOS command (SSH mode only) |
| `save` | Save running-config to startup-config |

### Examples

```bash
# System info
python catalyst_manager.py --host 10.0.0.2 info

# Show spanning-tree
python catalyst_manager.py --host 10.0.0.2 spanning-tree

# Show MAC address table
python catalyst_manager.py --host 10.0.0.2 mac-table

# Add a VLAN
python catalyst_manager.py --host 10.0.0.2 vlan-add 100 --name MGMT

# SSH mode — useful for older IOS or raw output
python catalyst_manager.py --host 10.0.0.2 --ssh interfaces
python catalyst_manager.py --host 10.0.0.2 --ssh run-cmd "show spanning-tree"

# Disable TLS verification for self-signed certs
python catalyst_manager.py --host 10.0.0.2 --no-verify vlans

# Use environment variables for credentials
export CATALYST_USER=admin
export CATALYST_PASS=secret
python catalyst_manager.py --host 10.0.0.2 info
```

---

## Enabling APIs on the switch

### Nexus — NX-API

```
switch# configure terminal
switch(config)# feature nxapi
switch(config)# nxapi https port 443
switch(config)# end
switch# copy running-config startup-config
```

### Catalyst — RESTCONF (IOS-XE 16.6+)

```
switch# configure terminal
switch(config)# aaa new-model
switch(config)# aaa authentication login default local
switch(config)# aaa authorization exec default local
switch(config)# ip http secure-server
switch(config)# restconf
switch(config)# end
switch# write memory
```

---

## Notes

- Both scripts suppress TLS certificate warnings for self-signed switch certificates. Use a proper CA-signed certificate in production or remove the `urllib3.disable_warnings` call.
- SSH mode uses `AutoAddPolicy` for host key verification — acceptable for closed lab networks; tighten for production by loading known host keys instead.
- `run-cmd` over RESTCONF is not supported; use `--ssh run-cmd` for arbitrary CLI output.
