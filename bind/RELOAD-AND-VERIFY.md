Reload bind9 zone and verify DNS

1) Copy updated zone file into running bind9 container (replace <bind-container> with container name):

```bash
# copy the updated zone file into the container
docker cp bind/bind9/config/zones/db.vishal.home <bind-container>:/etc/bind/zones/db.vishal.home

# inside the container: validate the zone file
docker exec -it <bind-container> named-checkzone vishal.home /etc/bind/zones/db.vishal.home

# reload named
docker exec -it <bind-container> rndc reload
```

2) Verify DNS from a machine that uses the bind9 server (or from the host if it's authoritative):

```bash
# ask the bind server directly (replace <bind-server-ip>)
dig @<bind-server-ip> teable.vishal.home A

# or locally if /etc/resolv.conf points at the bind server:
dig teable.vishal.home A

# check HTTP endpoint once DNS resolves:
curl -v http://teable.vishal.home:3000/health
```

Notes:
- If your bind9 service is provided by a Docker container managed in this repo, the container name is likely `bind9` or similar. Use `docker ps` to find it.
- If bind is running on the host (not containerized), just run `named-checkzone` and `rndc reload` locally (you may need sudo).
