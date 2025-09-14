#!/usr/bin/env bash

set -e

WORKDIR="/root/gf_server"
BIN_FOLDER="$WORKDIR/_utils/bin"

WORLD_BIN="WorldServer"
ZONE_BIN="ZoneServer"

GATEWAY_BIN="GatewayServer"
LOGIN_BIN="LoginServer"
MISSION_BIN="MissionServer"
TICKET_BIN="TicketServer"

WORLD101_BIN="WorldServer101"
WORLD102_BIN="WorldServer102"
WORLD109_BIN="WorldServer109"

ZONE101_BIN="ZoneServer101"
ZONE102_BIN="ZoneServer102"
ZONE109_BIN="ZoneServer109"

log() {
    echo -e "\n[INFO] $1"
}

log "Configuring server IP addresses..."
HOST_IP=$(hostname -I | awk '{print $1}')
log "Detected Host IP: $HOST_IP"

IP_PARTS=(${HOST_IP//./ })
IP_PARTS[3]=0
SERVER_IP="${IP_PARTS[0]}.${IP_PARTS[1]}.${IP_PARTS[2]}.0"

HEX_IP=$(printf '%s' "$SERVER_IP" | od -An -tx1 | tr -d ' \n' | awk '{ printf "%-60s", $0 }' | tr ' ' '0')
IP_BYTES=$(echo "$HEX_IP" | sed 's/\(..\)/\\\x\1/g')

log "Updating GatewayServer"
echo -en "$IP_BYTES" | dd of="${WORKDIR}/${GATEWAY_BIN}/${GATEWAY_BIN}" bs=1 seek=$((0x$GATEWAY_OFFSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

log "Updating LoginServer"
echo -en "$ip_bytes" | dd of="${WORKDIR}/${LOGIN_BIN}/${LOGIN_BIN}" bs=1 seek=$((0x$LOGIN_OFSSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

log "Updating MissionServer"
echo -en "$IP_BYTES" | dd of="${WORKDIR}/${MISSION_BIN}/${MISSION_BIN}" bs=1 seek=$((0x$MISSION_OFFSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

log "Updating TicketServer"
echo -en "$IP_BYTES" | dd of="${WORKDIR}/${TICKET_BIN}/${TICKET_BIN}" bs=1 seek=$((0x$TICKET_OFFSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

log "Updating WorldServer binary"
echo -en "$IP_BYTES" | dd of="${BIN_FOLDER}/${WORLD_BIN}" bs=1 seek=$((0x$WORLD_OFFSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

log "Updating ZoneServer binary"
echo -en "$IP_BYTES" | dd of="${BIN_FOLDER}/${ZONE_BIN}" bs=1 seek=$((0x$ZONE_OFFSET)) count=${#IP_BYTES} conv=notrunc >/dev/null 2>&1

copy_binary() {
    local source=$1
    local destination=$2
    
    log "Copying $source to $destination"
    cp -f "$source" "$destination"
}

copy_binary "$BIN_FOLDER/$WORLD_BIN" "$WORKDIR/$WORLD101_BIN/$WORLD101_BIN"
copy_binary "$BIN_FOLDER/$WORLD_BIN" "$WORKDIR/$WORLD102_BIN/$WORLD102_BIN"
copy_binary "$BIN_FOLDER/$WORLD_BIN" "$WORKDIR/$WORLD109_BIN/$WORLD109_BIN"

copy_binary "$BIN_FOLDER/$ZONE_BIN" "$WORKDIR/$ZONE101_BIN/$ZONE101_BIN"
copy_binary "$BIN_FOLDER/$ZONE_BIN" "$WORKDIR/$ZONE102_BIN/$ZONE102_BIN"
copy_binary "$BIN_FOLDER/$ZONE_BIN" "$WORKDIR/$ZONE109_BIN/$ZONE109_BIN"


log "Setting full permissions for the server directory..."
chmod -R 777 "$WORKDIR"


log "Updating setup.ini with database passwords..."
sed -i "/GameDBPassword/c\GameDBPassword=$PGPASSWORD" "$WORKDIR/setup.ini"
sed -i "/AccountDBPW/c\AccountDBPW=$PGPASSWORD" "$WORKDIR/setup.ini"
sed -i "/AccountDBPW/c\AccountDBPW=$PGPASSWORD" "$WORKDIR/$GATEWAY_BIN/setup.ini"

log "Deploying PHP files to Apache..."
rm -f /var/www/html/index.html
cp -f "$WORKDIR/_utils/web/"*.php /var/www/html/

log "Updating PHP configuration for the web application..."
sed -i "/server_host =/c\    \$server_host = '$PGHOST';" "/var/www/html/config.php"
sed -i "/db_password =/c\    \$db_password = '$PGPASSWORD';" "/var/www/html/config.php"

log "Restarting Apache server..."
service apache2 restart

log "Server installation and configuration completed successfully!"
