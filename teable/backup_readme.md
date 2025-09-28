# Docker Volumes Backup Guide (Generic)

Goal: Simple, reliable backups and restores for Docker volumes so container data isn’t lost.

Contents:
- Quick TL;DR (backup and restore now)
- Identify volumes to back up
- One-off backup/restore (tar in ephemeral container)
- Consistency for databases
- Automate with cron/systemd
- Verify, test restores, and retention
- Optional: encryption and offsite sync
- Troubleshooting and tips

---

## Quick TL;DR

- Backup a named volume to ./backups:
```
mkdir -p ./backups
VOL=my_volume_name
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c 'cd /src && tar -czf /dest/'"$VOL"'-$(date +%F-%H%M%S).tar.gz .'
```

- Restore that archive into an empty volume:
```
VOL=my_volume_name
ARCHIVE=backups/my_volume_name-YYYY-MM-DD-HHMMSS.tar.gz
# optional: wipe the volume contents first (DANGEROUS)
docker run --rm -v "$VOL":/dest alpine:3.20 sh -c 'rm -rf /dest/*'
docker run --rm \
  -v "$VOL":/dest \
  -v "$PWD":/src \
  alpine:3.20 sh -c 'cd /dest && tar -xzf /src/'"$ARCHIVE"
```

- For bind mounts, use tar directly on the host:
```
sudo tar -czf backups/appdata-$(date +%F-%H%M%S).tar.gz -C /path/to/bind/mount .
```

---

## Identify what to back up

- List all volumes:
```
docker volume ls
```

- See which volumes a service uses (replace SERVICE with your app service name):
```
docker compose ps -q SERVICE | xargs -r docker inspect --format '{{json .Mounts}}' | jq -r '.[].Name // empty' | sort -u
```
If jq is not installed, inspect by hand:
```
CID=$(docker compose ps -q SERVICE)
docker inspect "$CID" | less
```

- Compose-named volumes are usually project_volume (e.g., teable_db, teable_data).
- Also back up any bind-mounted directories that hold data.

---

## One-off backups (tar via ephemeral container)

Safer to snapshot when the app is idle. For databases, see “Consistency” below.

- Create destination:
```
mkdir -p ./backups
```

- Backup a named volume (gzip):
```
VOL=name_of_volume
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c 'cd /src && tar -czf /dest/'"$VOL"'-$(date +%F-%H%M%S).tar.gz .'
```

- Optional: use zstd (faster/better compression if you have tar with -I):
```
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c "apk add --no-cache zstd && cd /src && tar -I 'zstd -3' -cf /dest/${VOL}-$(date +%F-%H%M%S).tar.zst ."
```

- Backup a bind-mount path:
```
sudo tar -czf backups/pathname-$(date +%F-%H%M%S).tar.gz -C /absolute/path/to/mount .
```

---

## Restore

Warning: Restores overwrite the target volume contents.

- Stop the app to avoid writing during restore:
```
docker compose stop
```

- Restore into a named volume:
```
VOL=name_of_volume
ARCHIVE=backups/name_of_volume-YYYY-MM-DD-HHMMSS.tar.gz

# optional: wipe current contents (DANGEROUS)
docker run --rm -v "$VOL":/dest alpine:3.20 sh -c 'rm -rf /dest/*'

docker run --rm \
  -v "$VOL":/dest \
  -v "$PWD":/src \
  alpine:3.20 sh -c 'cd /dest && tar -xzf /src/'"$ARCHIVE"
```

- Restore into a bind-mount path:
```
sudo tar -xzf backups/pathname-YYYY-MM-DD-HHMMSS.tar.gz -C /absolute/path/to/mount
```

- Start the app:
```
docker compose up -d
```

---

## Consistency for databases (important)

To avoid corrupt/inconsistent backups:
- Prefer logical dumps (application-aware) over raw volume snapshots.
- PostgreSQL example:
```
# Set env appropriately or use your compose service name and user
CID=$(docker compose ps -q postgres)   # or your DB container
docker exec -t "$CID" pg_dumpall -U postgres > backups/pgdumpall-$(date +%F-%H%M%S).sql
```
- MySQL/MariaDB example:
```
CID=$(docker compose ps -q mariadb)
docker exec -t "$CID" sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > backups/mysqldump-$(date +%F-%H%M%S).sql
```
- If you must tar a live DB volume, at least stop the DB container during the snapshot:
```
docker compose stop postgres
# tar the DB volume(s) here
docker compose start postgres
```

---

## Automate (cron on Linux)

Example script to back up a list of volumes with retention:

```
#!/usr/bin/env bash
# save as ./backup.sh and chmod +x ./backup.sh
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-$PWD/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
VOLUMES=("teable_data" "teable_db")   # adjust to your volumes

mkdir -p "$BACKUP_DIR"

image="alpine:3.20"

for VOL in "${VOLUMES[@]}"; do
  ts=$(date +%F-%H%M%S)
  out="${BACKUP_DIR}/${VOL}-${ts}.tar.gz"
  echo "Backing up $VOL -> $out"
  docker run --rm -v "$VOL":/src:ro -v "$BACKUP_DIR":/dest "$image" \
    sh -c 'cd /src && tar -czf /dest/'"$(basename "$out")"' .'
done

# optional: DB logical dump (Postgres example)
if docker compose ps postgres >/dev/null 2>&1; then
  CID=$(docker compose ps -q postgres || true)
  if [ -n "${CID:-}" ]; then
    ts=$(date +%F-%H%M%S)
    echo "Dumping Postgres -> ${BACKUP_DIR}/pgdumpall-${ts}.sql"
    docker exec -t "$CID" pg_dumpall -U postgres > "${BACKUP_DIR}/pgdumpall-${ts}.sql" || true
  fi
fi

# retention
find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -print -delete
echo "Done."
```

Cron entry (runs daily at 02:30):
```
crontab -e
30 2 * * * cd /home/vishal/personal/dev/docker-compose-files/teable && ./backup.sh >> backups/cron.log 2>&1
```

Systemd timer is also an option if you prefer journals/services.

---

## Verify and test restores

- Inspect archive:
```
tar -tzf backups/volume-*.tar.gz | head
```

- Test restore into a throwaway volume:
```
TESTVOL=test_restore_$(date +%s)
docker volume create "$TESTVOL"
docker run --rm -v "$TESTVOL":/dest -v "$PWD":/src alpine:3.20 \
  sh -c 'cd /dest && tar -xzf /src/backups/volume-YYYY-MM-DD-HHMMSS.tar.gz && ls -la .'
docker volume rm "$TESTVOL"
```

- For DB dumps, try a temporary container and run psql/mysql client to ensure the dump parses.

---

## Optional: encryption and offsite

- Encrypt with age:
```
age -r <recipient_pubkey> -o backups/encrypted.tar.gz.age backups/volume-*.tar.gz
```

- Or GPG:
```
gpg --encrypt -r you@example.com --output backups/archive.tar.gz.gpg backups/archive.tar.gz
```

- Offsite sync with rclone (example remote “b2:mybucket”):
```
rclone copy ./backups b2:mybucket/homelab/teable --transfers=4 --checkers=8
```

---

## Troubleshooting and tips

- Check size of a volume:
```
VOL=name
docker run --rm -v "$VOL":/src alpine:3.20 du -sh /src
```

- Ensure correct ownership/permissions after restore if the app cares about UID/GID.
- Keep the app stopped during restore.
- Always keep at least one recent, tested backup off the host (disk loss happens).

---
```// filepath: /home/vishal/personal/dev/docker-compose-files/teable/backup_readme.md
# Docker Volumes Backup Guide (Generic)

Goal: Simple, reliable backups and restores for Docker volumes so container data isn’t lost.

Contents:
- Quick TL;DR (backup and restore now)
- Identify volumes to back up
- One-off backup/restore (tar in ephemeral container)
- Consistency for databases
- Automate with cron/systemd
- Verify, test restores, and retention
- Optional: encryption and offsite sync
- Troubleshooting and tips

---

## Quick TL;DR

- Backup a named volume to ./backups:
```
mkdir -p ./backups
VOL=my_volume_name
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c 'cd /src && tar -czf /dest/'"$VOL"'-$(date +%F-%H%M%S).tar.gz .'
```

- Restore that archive into an empty volume:
```
VOL=my_volume_name
ARCHIVE=backups/my_volume_name-YYYY-MM-DD-HHMMSS.tar.gz
# optional: wipe the volume contents first (DANGEROUS)
docker run --rm -v "$VOL":/dest alpine:3.20 sh -c 'rm -rf /dest/*'
docker run --rm \
  -v "$VOL":/dest \
  -v "$PWD":/src \
  alpine:3.20 sh -c 'cd /dest && tar -xzf /src/'"$ARCHIVE"
```

- For bind mounts, use tar directly on the host:
```
sudo tar -czf backups/appdata-$(date +%F-%H%M%S).tar.gz -C /path/to/bind/mount .
```

---

## Identify what to back up

- List all volumes:
```
docker volume ls
```

- See which volumes a service uses (replace SERVICE with your app service name):
```
docker compose ps -q SERVICE | xargs -r docker inspect --format '{{json .Mounts}}' | jq -r '.[].Name // empty' | sort -u
```
If jq is not installed, inspect by hand:
```
CID=$(docker compose ps -q SERVICE)
docker inspect "$CID" | less
```

- Compose-named volumes are usually project_volume (e.g., teable_db, teable_data).
- Also back up any bind-mounted directories that hold data.

---

## One-off backups (tar via ephemeral container)

Safer to snapshot when the app is idle. For databases, see “Consistency” below.

- Create destination:
```
mkdir -p ./backups
```

- Backup a named volume (gzip):
```
VOL=name_of_volume
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c 'cd /src && tar -czf /dest/'"$VOL"'-$(date +%F-%H%M%S).tar.gz .'
```

- Optional: use zstd (faster/better compression if you have tar with -I):
```
docker run --rm \
  -v "$VOL":/src:ro \
  -v "$PWD/backups":/dest \
  alpine:3.20 sh -c "apk add --no-cache zstd && cd /src && tar -I 'zstd -3' -cf /dest/${VOL}-$(date +%F-%H%M%S).tar.zst ."
```

- Backup a bind-mount path:
```
sudo tar -czf backups/pathname-$(date +%F-%H%M%S).tar.gz -C /absolute/path/to/mount .
```

---

## Restore

Warning: Restores overwrite the target volume contents.

- Stop the app to avoid writing during restore:
```
docker compose stop
```

- Restore into a named volume:
```
VOL=name_of_volume
ARCHIVE=backups/name_of_volume-YYYY-MM-DD-HHMMSS.tar.gz

# optional: wipe current contents (DANGEROUS)
docker run --rm -v "$VOL":/dest alpine:3.20 sh -c 'rm -rf /dest/*'

docker run --rm \
  -v "$VOL":/dest \
  -v "$PWD":/src \
  alpine:3.20 sh -c 'cd /dest && tar -xzf /src/'"$ARCHIVE"
```

- Restore into a bind-mount path:
```
sudo tar -xzf backups/pathname-YYYY-MM-DD-HHMMSS.tar.gz -C /absolute/path/to/mount
```

- Start the app:
```
docker compose up -d
```

---

## Consistency for databases (important)

To avoid corrupt/inconsistent backups:
- Prefer logical dumps (application-aware) over raw volume snapshots.
- PostgreSQL example:
```
# Set env appropriately or use your compose service name and user
CID=$(docker compose ps -q postgres)   # or your DB container
docker exec -t "$CID" pg_dumpall -U postgres > backups/pgdumpall-$(date +%F-%H%M%S).sql
```
- MySQL/MariaDB example:
```
CID=$(docker compose ps -q mariadb)
docker exec -t "$CID" sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > backups/mysqldump-$(date +%F-%H%M%S).sql
```
- If you must tar a live DB volume, at least stop the DB container during the snapshot:
```
docker compose stop postgres
# tar the DB volume(s) here
docker compose start postgres
```

---

## Automate (cron on Linux)

Example script to back up a list of volumes with retention:

```
#!/usr/bin/env bash
# save as ./backup.sh and chmod +x ./backup.sh
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-$PWD/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
VOLUMES=("teable_data" "teable_db")   # adjust to your volumes

mkdir -p "$BACKUP_DIR"

image="alpine:3.20"

for VOL in "${VOLUMES[@]}"; do
  ts=$(date +%F-%H%M%S)
  out="${BACKUP_DIR}/${VOL}-${ts}.tar.gz"
  echo "Backing up $VOL -> $out"
  docker run --rm -v "$VOL":/src:ro -v "$BACKUP_DIR":/dest "$image" \
    sh -c 'cd /src && tar -czf /dest/'"$(basename "$out")"' .'
done

# optional: DB logical dump (Postgres example)
if docker compose ps postgres >/dev/null 2>&1; then
  CID=$(docker compose ps -q postgres || true)
  if [ -n "${CID:-}" ]; then
    ts=$(date +%F-%H%M%S)
    echo "Dumping Postgres -> ${BACKUP_DIR}/pgdumpall-${ts}.sql"
    docker exec -t "$CID" pg_dumpall -U postgres > "${BACKUP_DIR}/pgdumpall-${ts}.sql" || true
  fi
fi

# retention
find "$BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -print -delete
echo "Done."
```

Cron entry (runs daily at 02:30):
```
crontab -e
30 2 * * * cd /home/vishal/personal/dev/docker-compose-files/teable && ./backup.sh >> backups/cron.log 2>&1
```

Systemd timer is also an option if you prefer journals/services.

---

## Verify and test restores

- Inspect archive:
```
tar -tzf backups/volume-*.tar.gz | head
```

- Test restore into a throwaway volume:
```
TESTVOL=test_restore_$(date +%s)
docker volume create "$TESTVOL"
docker run --rm -v "$TESTVOL":/dest -v "$PWD":/src alpine:3.20 \
  sh -c 'cd /dest && tar -xzf /src/backups/volume-YYYY-MM-DD-HHMMSS.tar.gz && ls -la .'
docker volume rm "$TESTVOL"
```

- For DB dumps, try a temporary container and run psql/mysql client to ensure the dump parses.

---

## Optional: encryption and offsite

- Encrypt with age:
```
age -r <recipient_pubkey> -o backups/encrypted.tar.gz.age backups/volume-*.tar.gz
```

- Or GPG:
```
gpg --encrypt -r you@example.com --output backups/archive.tar.gz.gpg backups/archive.tar.gz
```

- Offsite sync with rclone (example remote “b2:mybucket”):
```
rclone copy ./backups b2:mybucket/homelab/teable --transfers=4 --checkers=8
```

---

## Troubleshooting and tips

- Check size of a volume:
```
VOL=name
docker run --rm -v "$VOL":/src alpine:3.20 du -sh /src
```

- Ensure correct ownership/permissions after restore if the app cares about UID/GID.
- Keep the app stopped during restore.
- Always keep at least one recent, tested backup off the host (disk loss happens).

---