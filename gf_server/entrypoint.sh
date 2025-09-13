#!/bin/sh
set -e

socat TCP-LISTEN:5432,fork TCP:database:5432 &

int_ip=$(hostname -I | awk '{print $1}' || echo "127.0.0.1")
ext_ip=${HOST:-$int_ip}

echo "Internal IP: $int_ip"
echo "External IP: $ext_ip"

echo "Waiting for PostgreSQL to be ready..."
until psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c '\q' >/dev/null 2>&1; do
    echo "PostgreSQL not ready, retrying..."
    sleep 2
done
echo "PostgreSQL is ready!"

psql_cmd="psql -h $PGHOST -p $PGPORT -U $PGUSER -v ON_ERROR_STOP=1 -w"

echo "Updating PostgreSQL with IP info..."
$psql_cmd -d gf_ls -c "UPDATE worlds SET ip = '$ext_ip';" || echo "⚠️ gf_ls update failed"
$psql_cmd -d gf_gs -c "UPDATE serverstatus SET int_address = '$int_ip';" || echo "⚠️ internal address update failed"
$psql_cmd -d gf_gs -c "UPDATE serverstatus SET ext_address = '$ext_ip' WHERE ext_address != 'none';" || echo "⚠️ external address update failed"

echo "PostgreSQL updates complete."

workdir=/root/gf_server/scripts
cd "$workdir" || exit 1
chmod +x ./*.sh
"$workdir/install.sh"
# "$workdir/start.sh"

tail -f /dev/null
