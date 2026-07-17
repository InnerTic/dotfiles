#!/usr/bin/env fish

set IFACE enp6s0
set BRIDGE br0
set SLAVE br0-$IFACE

echo "[1/6] Cleaning old bridge configs..."

nmcli connection delete $BRIDGE ^/dev/null
nmcli connection delete $SLAVE ^/dev/null

echo "[2/6] Creating bridge $BRIDGE..."

nmcli connection add \
    type bridge \
    ifname $BRIDGE \
    con-name $BRIDGE

echo "[3/6] Setting DHCP on bridge..."

nmcli connection modify $BRIDGE \
    ipv4.method auto \
    ipv6.method auto

echo "[4/6] Attaching NIC $IFACE..."

nmcli connection add \
    type bridge-slave \
    ifname $IFACE \
    master $BRIDGE \
    con-name $SLAVE

echo "[5/6] Restarting connections..."

nmcli connection down $BRIDGE ^/dev/null
nmcli connection up $BRIDGE
nmcli connection up $SLAVE

echo "[6/6] State check..."

ip a show $BRIDGE
nmcli connection show --active

echo "DONE: br0 should now be DHCP from router."
