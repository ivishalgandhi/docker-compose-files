# Bind9 + Reverse Proxy Pattern for Local Domains

This guide documents a reusable pattern to expose self-hosted services on friendly local domains (like `teable.vishal.home`) using:
- Bind9 as the authoritative DNS for your private zone (e.g., `vishal.home`)
- A lightweight reverse proxy (Nginx) on port 80 forwarding to the app's internal port
- Optional Tailscale Split DNS so tailnet devices resolve the private zone

Use this playbook for future services by repeating the same steps and swapping only service-specific names/ports.

---

## Overview

- You own a private zone (e.g., `vishal.home`) served by Bind9 on your homelab host.
- Each service (e.g., Teable) gets a record like `teable.vishal.home` pointing to the host IP you want clients to hit:
  - Tailnet devices: Tailscale IP (e.g., `100.112.87.55`)
  - LAN devices: LAN IP (e.g., `192.168.1.167`)
- A reverse proxy listens on host port 80 and routes requests for that hostname to the app container on its internal port (e.g., 3000).

This keeps your app simple (listen on 3000) while clients use standard HTTP 80 on a friendly name.

---

## 1) Bind9: zone and record

Files in this repo:
- `bind/bind9/config/named.conf` — includes the zone `vishal.home` and allows queries from LAN and Tailscale ranges.
- `bind/bind9/config/zones/db.vishal.home` — zone data with your records.

Example minimal zone snippet for `teable`:

```
$TTL    604800
@   IN  SOA  ns1.vishal.home. admin.vishal.home. (
        2025092805 ; serial
        3600       ; refresh
        1800       ; retry
        604800     ; expire
        86400 )    ; minimum
;
@       IN  NS   ns1.vishal.home.
ns1     IN  A    192.168.1.167

; App record (choose one IP style depending on clients)
; Tailscale (tailnet-wide access)
teable  IN  A    100.112.87.55
; or LAN (local-only access)
; teable  IN  A  192.168.1.167
```

Important:
- Bump the `serial` every time you change the zone.
- Ensure SOA MNAME matches your NS (e.g., `ns1.vishal.home.`).

Validate and reload:
- Inside the bind container or host: `named-checkzone vishal.home /etc/bind/zones/db.vishal.home`
- Restart bind: `docker restart bind9`
- Confirm in logs: `zone vishal.home/IN: loaded serial <new-serial>`

---

## 2) Reverse proxy on port 80 (per service)

Add a small Nginx proxy in the service’s compose directory. Example for Teable:

File: `teable/docker-compose.yaml` (relevant parts)

```yaml
services:
  teable:
    image: ghcr.io/teableio/teable:latest
    restart: always
    network_mode: "host"   # app listens on 3000
    environment:
      - SERVER_HOST=0.0.0.0
      - SERVER_PORT=3000
      - PUBLIC_ORIGIN=http://teable.vishal.home
    # ...

  teable-proxy:
    image: nginx:1.27-alpine
    restart: always
    network_mode: "host"    # bind directly to host port 80
    depends_on:
      - teable
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
```

Create config `teable/nginx/conf.d/teable.conf`:

```
server {
    listen 80;
    listen [::]:80;
    server_name teable.vishal.home;

    location = /health {
        proxy_pass http://127.0.0.1:3000/health;
        access_log off;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
        proxy_pass http://127.0.0.1:3000;
    }
}
```

Bring it up (from the `teable/` directory):
- `docker compose up -d teable teable-proxy`
- Test locally: `curl -I -H 'Host: teable.vishal.home' http://127.0.0.1` → should return 200/307

Why reverse proxy?
- Users hit `http://teable.vishal.home` (defaults to port 80).
- The proxy routes to the app on 3000. You don’t need to expose 3000 or teach users a port.

---

## 3) Make clients resolve your private zone

You have two common client groups:

1) Tailscale devices (anywhere)
   - Use Tailscale Split DNS so `vishal.home` queries go to your Bind9 (the host’s Tailscale IP):
     - Tailscale admin → DNS → add Custom DNS (e.g., `100.112.87.55`).
     - Add Split DNS domain: `vishal.home` → use that nameserver.
   - Verify from a Tailscale client:
     - `dig teable.vishal.home`
     - `curl -I http://teable.vishal.home`

2) LAN devices (home network)
   - Configure router/DHCP to hand out your Bind9 (e.g., `192.168.1.167`) as DNS.
   - Or add a conditional forwarder for `vishal.home` to Bind9.
   - Verify from a LAN client:
     - `dig teable.vishal.home @192.168.1.167`
     - `curl -I http://teable.vishal.home`

Tip: You can create both a Tailscale and a LAN record if you want distinct paths:
- `teable-ts.vishal.home` → 100.112.87.55
- `teable-lan.vishal.home` → 192.168.1.167

---

## 4) Health, logs, and troubleshooting

- Nginx health: `curl -I -H 'Host: teable.vishal.home' http://127.0.0.1/health`
- App health: `curl -I http://127.0.0.1:3000/health`
- Bind9 logs: `docker logs --tail 200 bind9 | less`
- Confirm zone loaded: look for `zone vishal.home/IN: loaded serial ...`
- Quick DNS check against your server: `dig @100.112.87.55 teable.vishal.home +short`

Common issues:
- “Could not resolve host”: Client is not using your DNS. Configure Split DNS or DHCP.
- HTTP connects on 3000 but not on 80: Proxy not running/bound; ensure `network_mode: host` and no other service is using port 80.
- Zone edits ignored: Forgot to bump SOA serial; restart Bind9 or `rndc reload`.

---

## 5) Reusing this pattern for a new service

For a new app “myapp” on port 8080:
1. Add DNS: in `db.vishal.home`, add `myapp IN A <host-ip>` and bump serial.
2. Create `myapp/nginx/conf.d/myapp.conf` with `server_name myapp.vishal.home` and `proxy_pass http://127.0.0.1:8080;`
3. Add `myapp-proxy` in `myapp/docker-compose.yaml` (host networking, mount the conf.d directory).
4. Ensure the app listens on the right host/port and is reachable locally.
5. Start both containers and test with curl.

Optional improvements:
- HTTPS termination: add certs and `listen 443 ssl;` with Let’s Encrypt (for public domains) or Tailscale Serve for encrypted tailnet access.
- Access control: Basic auth in Nginx for sensitive services.
- Observability: add `access_log off;` for health, leave for main locations, or ship logs to your stack.

---

## Appendix: snippets you can copy

Minimal Nginx server for a service on port 8080:

```
server {
  listen 80;
  server_name myapp.vishal.home;
  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_pass http://127.0.0.1:8080;
  }
}
```

Health location block:

```
location = /health { proxy_pass http://127.0.0.1:8080/health; access_log off; }
```

Bind9 allowlist for LAN and Tailscale (inside `options {}`):

```
listen-on { any; };
listen-on-v6 { any; };
allow-query {
  127.0.0.1;
  192.168.1.0/24;
  100.64.0.0/10;
};
```

---

That’s it. Repeat the steps, change the names/ports, and you’ll have consistent, human‑readable URLs for all your homelab services.
