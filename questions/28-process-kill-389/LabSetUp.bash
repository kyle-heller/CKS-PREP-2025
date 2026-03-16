#!/bin/bash
set -euo pipefail

# Create output directory
mkdir -p /candidate/13

# Kill any existing process on port 389
if command -v ss &>/dev/null; then
  EXISTING_PID=$(ss -tlnp 'sport = :389' 2>/dev/null | grep -oP 'pid=\K[0-9]+' | head -1)
elif command -v netstat &>/dev/null; then
  EXISTING_PID=$(netstat -tlnp 2>/dev/null | grep ':389 ' | awk '{print $7}' | cut -d/ -f1 | head -1)
fi
if [ -n "${EXISTING_PID:-}" ] && [ "$EXISTING_PID" != "" ]; then
  kill -9 "$EXISTING_PID" 2>/dev/null || true
  sleep 1
fi

# Create a fake binary that listens on port 389 (simulating an unauthorized LDAP service)
cp /bin/sleep /usr/local/bin/fake-ldap 2>/dev/null || true

# Use socat to create a listener on port 389 if available, otherwise use nc
if command -v socat &>/dev/null; then
  nohup socat TCP-LISTEN:389,fork,reuseaddr EXEC:/bin/cat &>/dev/null &
elif command -v nc &>/dev/null; then
  # Run nc in a loop to keep listening
  nohup bash -c 'while true; do nc -l -p 389 < /dev/null 2>/dev/null; sleep 0.1; done' &>/dev/null &
else
  # Fallback: use python3
  nohup python3 -c "
import socket, time
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 389))
s.listen(1)
while True:
    time.sleep(3600)
" &>/dev/null &
fi

# Give it a moment to start
sleep 2

echo "Lab setup complete."
echo "  A suspicious process is listening on port 389"
echo "  Output dir: /candidate/13/"
echo "  Find the PID, save its open files, kill it, and delete the binary"
