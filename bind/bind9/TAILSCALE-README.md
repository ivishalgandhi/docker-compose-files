Tailscale + Bind9 (docker) — usage notes

Overview

This document explains how to expose your Bind9 Docker container to your Tailscale network so you can use it from outside your home network. The Compose file has been switched to `network_mode: "host"` so the container binds directly to the host interfaces (including `tailscale0`).

Summary of steps

1. Install and auth Tailscale on the host
2. Start theBind container with host networking
3. Allow DNS (TCP/UDP 53) on `tailscale0` (firewall)
4. Test from a remote Tailscale client with `dig`
5. Configure macOS clients to use the Tailscale IP (and optionally `/etc/resolver` for domain-specific lookup)

Install Tailscale on the host

- Generic script (works on most Linux distros):

```bash
sudo apt update
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
# complete authentication using the URL printed by `tailscale up`
```

- Verify the tail scale IP:

```bash
tailscale ip
# or
tailscale status
```

Start Bind (docker)

From the `bind9` directory:

```bash
# uses the docker-compose.yml in this folder
docker compose up -d
```

Because `network_mode: "host"` is set, Bind will bind to the host ports directly.

Firewall rules (allow DNS on tailscale0)

- UFW example:

```bash
sudo ufw allow in on tailscale0 to any port 53 proto udp
sudo ufw allow in on tailscale0 to any port 53 proto tcp
```

- iptables example:

```bash
sudo iptables -I INPUT -i tailscale0 -p udp --dport 53 -j ACCEPT
sudo iptables -I INPUT -i tailscale0 -p tcp --dport 53 -j ACCEPT
```

Verify Bind is listening

```bash
sudo ss -ulpn | grep :53
# or
sudo lsof -i :53
```

You should see `named`/`bind` listening on 0.0.0.0:53 (host namespace), which includes the tailscale0 interface.

Testing from a remote Tailscale client

- Use dig against your host tailscale IP:

```bash
dig @<HOST_TAILSCALE_IP> test.docker.lan
```

- Example:

```bash
dig @100.101.102.103 test.docker.lan
```

If you get the expected answer, DNS over Tailscale is working.

macOS — using your Bind server for a specific domain

Option A — set your macOS DNS to the Tailscale IP (system-wide)

- System Settings -> Network -> choose Tailscale or the active adapter -> DNS -> add the host Tailscale IP as the DNS server.
- Or via command-line (macOS 12+ using `networksetup`):

```bash
sudo networksetup -setdnsservers "Wi-Fi" 100.101.102.103
```

Option B — use `/etc/resolver` for domain-specific resolution (recommended for private domains)

- Create `/etc/resolver/vishal.home` with contents:

```
nameserver 100.101.102.103
```
- macOS will direct queries for `vishal.home` to that nameserver and use system DNS for everything else.

Notes about `/etc/resolver`:
- The resolver directory only works for exact domain matches — not wildcards (unless you add nested files for subdomains).
- Ensure file is owned by root and readable by the system.

Should you change the local IPs in `vishal.home` zone?

- If the records in `vishal.home` use private LAN IPs (e.g., `192.168.1.x`), that's fine if:
  - Those services are only meant to be reached when the client is also on your LAN or connected via Tailscale to your LAN/VPN.
  - Remote clients over Tailscale expect to reach the same private IPs (Tailscale provides routing), or the services are reachable via the private IPs when on the Tailscale network.

- If your remote clients should reach the services through different IPs when off-LAN (for example, via a public IP or NAT), then you'll need separate records or split-horizon DNS.

- Since `dig` works from your remote machine, your current setup appears to be serving the expected records; you can proceed to configure macOS to use the Tailscale IP as its DNS or add a resolver file.

Security and best-practice recommendations

- Use specific Tailscale peer IPs in the `internal` ACL instead of the entire 100.64.0.0/10 range if you want tighter control.
- If you advertise your nameserver via the Tailscale admin panel, only do so for devices you trust.
- Keep zone files up-to-date and avoid leaking sensitive hostnames publicly.

Would you like me to:
- Add a `vishal.home` specific `/etc/resolver` example file pre-filled with your current tailscale IP?
- Replace the broad `100.64.0.0/10` ACL entry with a list of the actual Tailscale peer IPs found in `tailscale status` (I can read them if you give permission to run commands or paste `tailscale status` output).