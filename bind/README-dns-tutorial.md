# BIND9 Docker + macOS Troubleshooting & Quick Reference

This short guide documents the local BIND9 docker setup used in this repo and the steps we used to debug and fix common issues, especially when macOS clients use VPNs that override DNS.

It assumes your project root is the repository containing the `bind9/` folder and docker-compose setup.

## Goals
- Run a local authoritative and recursive BIND9 inside Docker
- Expose it on the LAN so other clients can use it
- Fix macOS name resolution when VPNs (Tailscale, Twingate, Surfshark, WireGuard) are present
- Quick checks and commands to validate DNS and networking

---

## Files and mounts (what this repo contains)
- `bind9/docker-compose.yml` — compose service mapping `./config` → `/etc/bind` and ports (example maps `53:53`)
- `bind9/config/named.conf` — main named config (includes zones)
 - `bind9/config/zones/db.vishal.home` — example zone file for `vishal.home`

---

## Quick local checks
- Is the container running?
  - docker compose ps
 - Are logs OK and is the zone loaded?
  - docker compose logs bind9 | grep vishal.home
 - Validate zone syntax on host (requires bind9-utils):
  - named-checkzone vishal.home /path/to/config/zones/db.vishal.home
- Validate named.conf:
  - named-checkconf /path/to/config/named.conf

---

## Expose BIND to the LAN
Two approaches:
1. Map container to host port 53 (recommended for normal LAN use):
   - In `docker-compose.yml` ports section:
     - "53:53/udp"
     - "53:53/tcp"
   - Ensure nothing else (systemd-resolved, dnsmasq) is bound to port 53.

2. Keep container on port 5353 and redirect incoming 53 → 5353 with iptables/nftables (advanced).


## macOS: common problems with VPNs
macOS uses resolver order; VPNs commonly create `utun` resolvers that have higher priority than your Wi‑Fi resolver. If your VPN pushes its own DNS, system tools (ping, browser) will use it.

### Fast and safe fix: per-domain resolver (macOS)
Create `/etc/resolver/<domain>` so macOS sends queries for that domain to your authoritative BIND server running on the host's Tailscale IP (example: `100.112.87.55`). Note: use the actual Tailscale IP of your BIND host.

```bash
sudo mkdir -p /etc/resolver
sudo tee /etc/resolver/vishal.home >/dev/null <<EOF
nameserver 100.112.87.55
EOF
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

Why this is different from `dig`:
- macOS system calls (ping, curl, browsers, apps) use the per-domain resolver files and will send queries for `vishal.home` to the nameserver above.
- `dig` is a diagnostic tool that by default queries the system/global resolvers (and not macOS per-domain resolver plumbing). Use `dig @100.112.87.55 ...` when you want an authoritative check.

Verify the resolver is active:
```bash
scutil --dns | grep -A6 'vishal.home'
ping srv-prod-1.vishal.home
```

To remove later:
```bash
sudo rm -f /etc/resolver/vishal.home
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

### Alternative: Allow LAN access in VPN
- Tailscale: Preferences → Allow LAN access (or exit node/ACL settings)
- Surfshark / other clients: check settings for "Allow LAN" or "Use system DNS" or split-DNS

After toggling, flush caches and test.

---

## If DNS resolves but packets don't reach the host
If the name resolves but pings time out or say "No route to host":
1. Check route and ARP from macOS:
   - route get 192.168.1.172
   - arp -n 192.168.1.172
2. If packets go through VPN by default, add a local route on macOS to force traffic to the LAN gateway (temporary):
  ```bash
  sudo route -n add -host 192.168.1.172 192.168.1.1
  ```
  Replace `192.168.1.1` with your LAN gateway.
3. Make route persistent: create a launchd plist under `/Library/LaunchDaemons` that runs the route add at boot.

---

## Useful iptables / nftables snippets (if you redirect 53→5353)
### iptables
```bash
sudo iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5353
sudo iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 5353
# remove rules
sudo iptables -t nat -D PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5353
sudo iptables -t nat -D PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 5353
```

### nftables
```bash
sudo nft add table inet nat || true
sudo nft 'add chain inet nat prerouting { type nat hook prerouting priority 0 ; }' 2>/dev/null || true
sudo nft add rule inet nat prerouting udp dport 53 redirect to 5353
sudo nft add rule inet nat prerouting tcp dport 53 redirect to 5353
```

---

## Security notes
- Avoid exposing your resolver to untrusted networks; use `allow-query` and `allow-recursion` to restrict clients.
- If you must open to the internet, enable rate-limiting and monitoring.

---

## Troubleshooting checklist
1. Zone file correct and serial bumped? Run:
```bash
named-checkzone vishal.home /home/vishal/docker-compose-projects/bind/bind9/config/zones/db.vishal.home
```
2. Container logs show `zone vishal.home loaded serial XXXX`? Check:
```bash
docker compose logs --tail=80 bind9 | grep 'vishal.home'
```
3. Authoritative check (always test against the authoritative server during debugging):
```bash
dig @100.112.87.55 srv-prod-1.vishal.home +short
dig @100.112.87.55 srv-prod1.vishal.home +short
```
4. On macOS: use `/etc/resolver` for real client tests (ping, curl). `dig` without `@` may query another resolver.
5. If ping resolves IP but connection fails: check route/arp, add local static route or enable LAN access in VPN, or give the target a Tailscale IP and use that in DNS.

---

If you want, I can:
- Add this file into the repo (done), or also create a short `scripts/` folder with helper scripts to create/remove `/etc/resolver` and to set up a persistent route.
- Generate a sample `LaunchDaemon` plist to persist a route on macOS.

Saved file: `README-dns-tutorial.md` in project root.
