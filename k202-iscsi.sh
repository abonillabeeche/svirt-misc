#!/bin/bash

# Configuration Directory
CONF_DIR="/etc/NetworkManager/system-connections"

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit
fi

echo "Generating NetworkManager configurations..."

# 1. Bond Master
cat <<EOF > $CONF_DIR/bond0.nmconnection
[connection]
id=bond0
uuid=$(uuidgen)
type=bond
interface-name=bond0

[bond]
miimon=100
mode=active-backup

[ipv4]
method=disabled

[ipv6]
addr-gen-mode=stable-privacy
method=ignore
EOF

# 2. Port 1 (eno12419np2)
cat <<EOF > $CONF_DIR/bond0-port1.nmconnection
[connection]
id=bond0-port1
uuid=$(uuidgen)
type=ethernet
interface-name=eno12419np2
master=bond0
slave-type=bond
EOF

# 3. Port 2 (eno12429np3)
cat <<EOF > $CONF_DIR/bond0-port2.nmconnection
[connection]
id=bond0-port2
uuid=$(uuidgen)
type=ethernet
interface-name=eno12429np3
master=bond0
slave-type=bond
EOF

# 4. VLAN 4048 (iSCSI A)
cat <<EOF > $CONF_DIR/bond0.4048.nmconnection
[connection]
id=bond0.4048
uuid=$(uuidgen)
type=vlan
interface-name=bond0.4048

[vlan]
parent=bond0
id=4048

[ipv4]
address1=11.1.1.31/24
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=ignore
EOF

# 5. VLAN 4049 (iSCSI B)
cat <<EOF > $CONF_DIR/bond0.4049.nmconnection
[connection]
id=bond0.4049
uuid=$(uuidgen)
type=vlan
interface-name=bond0.4049

[vlan]
parent=bond0
id=4049

[ipv4]
address1=11.1.2.31/24
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=ignore
EOF

# Set secure permissions
chmod 600 $CONF_DIR/bond0*.nmconnection
chown root:root $CONF_DIR/bond0*.nmconnection

# Reload NetworkManager to pick up new files
nmcli connection reload

echo "Configuration files created and NetworkManager reloaded."
echo "You can now activate them with: nmcli connection up bond0"
