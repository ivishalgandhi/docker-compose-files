#!/bin/bash
set -e

# Ensure runtime directory for named exists and has correct ownership
mkdir -p /run/named
chown -R bind:bind /run/named

# Move to a writable working directory so named won't fail
cd /run/named

# If no arguments are provided, start named with typical flags
if [ "$#" -eq 0 ]; then
	exec /usr/sbin/named -u bind -g
else
	exec "$@"
fi
