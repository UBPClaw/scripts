# SD-F5-iApp.py — Mitchell 1 VIP Deployment Script

Python replacement for the `SD-F5-iApp.tmpl` F5 iApp template. Deploys LTM pools, virtual servers, firewall policies, and ASM L7 policies to a BIG-IP via the iControl REST API.

---

## Requirements

- Python 3.7+
- `requests` library

```bash
pip install requests
```

---

## Usage

```
python3 SD-F5-iApp.py --host <BIG-IP> --password <password> --app-name <name> \
    [--username <user>] \
    [--stage Yes|No] \
    [--snat Yes|No] \
    [--redirect Yes|No] \
    [--vip-att <ip>] \
    [--vip-cox <ip>] \
    [--vip-internal <ip>] \
    [--monitor Yes|No] \
    [--asm-policy <policy-name>] \
    [--irules <rule1> <rule2> ...] \
    --backend-servers <ip1> [<ip2> ...] \
    --ports <port-def> [<port-def> ...]
```

---

## Arguments

| Argument | Required | Default | Description |
|---|---|---|---|
| `--host` | Yes | — | BIG-IP hostname or IP address |
| `--password` | Yes | — | BIG-IP password |
| `--app-name` | Yes | — | Name prefix for all created objects |
| `--username` | No | `admin` | BIG-IP username |
| `--backend-servers` | Yes | — | One or more pool member IP addresses |
| `--ports` | Yes | — | One or more port definitions (see below) |
| `--stage` | No | `No` | Use temporary staging IPs instead of production VIPs |
| `--snat` | No | `No` | Enable SNAT automap on virtual servers |
| `--redirect` | No | `No` | Create an HTTP→HTTPS redirect virtual when port 443 is defined |
| `--vip-att` | No | — | ATT VIP address |
| `--vip-cox` | No | — | Cox 10G VIP address |
| `--vip-internal` | No | — | Internal VIP address (required for staged deployment) |
| `--monitor` | No | `Yes` | Attach a health monitor to the pool |
| `--asm-policy` | No | — | ASM policy name to apply to virtual servers |
| `--irules` | No | — | One or more iRule names to attach |

---

## Port Definition Format

Each `--ports` value uses a colon-separated format:

```
port:allowall:monitor:sslprofile
```

| Field | Description |
|---|---|
| `port` | TCP port number (e.g. `80`, `443`, `21`) |
| `allowall` | `Yes` to create an accept-all firewall policy, `No` to skip |
| `monitor` | Health monitor name (e.g. `http`, `https`, `tcp`). Leave blank for none |
| `sslprofile` | Client-SSL profile name for port 443. Leave blank if not needed |

Leave trailing fields blank but keep the colons as placeholders:

```
443:Yes:https:my-ssl-profile    # HTTPS with SSL profile and monitor
80:Yes::                        # HTTP, no monitor, no SSL
21:No::                         # FTP, no firewall policy
```

---

## What Gets Created

For each port, the script creates:

1. **Firewall policy** (`<app-name>-fw-po`) — only when `allowall` is `Yes`
2. **LTM pool** (`<app-name>-<port>`) — with all backend servers as members
3. **Virtual servers** — one per VIP address provided, named:
   - `<app-name>-att-<port>`
   - `<app-name>-cox-10g-<port>`
   - `<app-name>-internal-<port>`
4. **HTTP redirect virtual** (`<app-name>-<suffix>-80-redir`) — when `--redirect Yes` and port is `443`
5. **ASM L7 policy** (`asm_auto_l7_policy__<virtual-name>`) — when `--asm-policy` is set

### Profile assignment by port

| Port | Profiles applied |
|---|---|
| `80` | `http`, `tcp` |
| `443` | `<ssl-profile>` (clientside), `http`, `serverssl-insecure-compatible` (serverside), `tcp` |
| `21` | `ftp`, `tcp` (with `source-port change`) |
| Other | `tcp` |

When `--asm-policy` is set, `http` and `websecurity` profiles are also added to all virtuals.

All virtual servers are created with:
- `vlans-disabled`
- `translate-address enabled`
- `translate-port enabled`
- Security log profile: `/Common/m1-base-logging`

---

## Staged Deployment

When `--stage Yes` is used, the script skips ATT and Cox VIPs and instead derives a temporary IP from the last octet of `--vip-internal`:

```
172.21.64.<last-octet-of-vip-internal>
```

For example, `--vip-internal 172.21.111.42` → temp IP `172.21.64.42`.

All staged virtuals use SNAT automap regardless of the `--snat` flag.

---

## Examples

### HTTPS site with redirect (production)

```bash
python3 SD-F5-iApp.py \
  --host 192.168.1.1 \
  --password mypassword \
  --app-name MyApp \
  --snat Yes \
  --redirect Yes \
  --vip-att 12.20.179.10 \
  --vip-cox 72.194.40.10 \
  --vip-internal 172.21.111.10 \
  --backend-servers 10.14.128.5 10.14.128.6 \
  --ports 443:Yes:https:my-client-ssl 80:Yes::
```

Creates for each VIP address:
- `MyApp-att-443`, `MyApp-cox-10g-443`, `MyApp-internal-443`
- `MyApp-att-80-redir`, `MyApp-cox-10g-80-redir`, `MyApp-internal-80-redir`
- `MyApp-att-80`, `MyApp-cox-10g-80`, `MyApp-internal-80`
- Pool: `MyApp-443`, `MyApp-80`

### HTTP-only site

```bash
python3 SD-F5-iApp.py \
  --host 192.168.1.1 \
  --password mypassword \
  --app-name MyApp \
  --vip-internal 172.21.111.20 \
  --backend-servers 10.14.128.10 \
  --ports 80:Yes:http:
```

### FTP site

```bash
python3 SD-F5-iApp.py \
  --host 192.168.1.1 \
  --password mypassword \
  --app-name MyFTP \
  --vip-internal 172.21.111.30 \
  --backend-servers 10.14.128.20 \
  --monitor No \
  --ports 21:No::
```

### Staged deployment

```bash
python3 SD-F5-iApp.py \
  --host 192.168.1.1 \
  --password mypassword \
  --app-name MyApp \
  --stage Yes \
  --vip-internal 172.21.111.42 \
  --backend-servers 10.14.128.5 \
  --ports 443:Yes:https:my-client-ssl
```

Deploys virtual `MyApp-443` at `172.21.64.42:443`.

### With ASM policy and iRules

```bash
python3 SD-F5-iApp.py \
  --host 192.168.1.1 \
  --password mypassword \
  --app-name MyApp \
  --vip-internal 172.21.111.50 \
  --backend-servers 10.14.128.5 \
  --asm-policy /Common/my-asm-policy \
  --irules my-irule-1 my-irule-2 \
  --ports 443:Yes:https:my-client-ssl
```

---

## Notes

- The script connects over HTTPS and **disables SSL certificate verification** — intended for use on internal/lab BIG-IP devices.
- Objects are created in the `/Common` partition.
- The script does not check for existing objects before creating them. Re-running against an existing app name will result in errors from the BIG-IP. Remove existing objects first if redeploying.
- Credentials are passed as a CLI argument. To avoid exposing the password in shell history, consider setting it via an environment variable and passing it with `--password "$F5_PASS"`.
