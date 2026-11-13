#!/bin/sh
# Railway start wrapper for Astrum Repository (the server itself is unmodified).
set -e
D="${ASTRUM_DATA_DIR:-/astrum-data}"
mkdir -p "$D"
# Railway volumes mount root-owned: hand the data dir to the image's astrum user (uid 200) once.
[ "$(stat -c %u "$D")" = "200" ] || chown -R 200:200 "$D"

# Wait for Postgres (a fresh template deploy starts both services together).
HP=$(echo "$ASTRUM_DATABASE_URL" | sed -E 's#^[a-z]+://[^@]*@([^/?]+).*#\1#')
H=${HP%%:*}; P=${HP##*:}; [ "$P" = "$HP" ] && P=5432
i=0
while [ $i -lt 90 ]; do
  if timeout 2 bash -c "echo > /dev/tcp/$H/$P" 2>/dev/null; then break; fi
  i=$((i+1)); sleep 2
done

setpriv --reuid=200 --regid=200 --clear-groups astrum serve "$@" &
PID=$!
trap 'kill -TERM $PID 2>/dev/null' TERM INT

# First boot only: Astrum writes a random password for "admin" to $D/admin.password and deletes that file
# once the password is changed. Replace it with ASTRUM_ADMIN_PASSWORD through Astrum's own REST API.
if [ -n "$ASTRUM_ADMIN_PASSWORD" ]; then
  (
    PORTNUM=${ASTRUM_LISTEN##*:}
    U="http://127.0.0.1:${PORTNUM:-8080}"
    n=0
    until curl -fsS -o /dev/null "$U/service/rest/v1/status"; do
      n=$((n+1)); [ $n -gt 150 ] && exit 0; sleep 2
    done
    if [ -f "$D/admin.password" ]; then
      FIRST=$(cat "$D/admin.password")
      code=$(curl -sS -o /tmp/pw.out -w '%{http_code}' -u "admin:$FIRST" -X PUT \
        -H 'Content-Type: text/plain' --data-binary "$ASTRUM_ADMIN_PASSWORD" \
        "$U/service/rest/v1/security/users/admin/change-password")
      if [ "$code" = "204" ]; then
        echo "railway-start: admin password set from ASTRUM_ADMIN_PASSWORD (sign in as admin)"
      else
        echo "railway-start: could not set the admin password (HTTP $code): $(cat /tmp/pw.out)"
      fi
      rm -f /tmp/pw.out
    fi
  ) &
fi

set +e
wait $PID; st=$?
wait $PID 2>/dev/null
exit $st
