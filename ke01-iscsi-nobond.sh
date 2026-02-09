#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define variables
IF_4048="eno12419np2"
IF_4049="eno12429np3"
IP_4048="11.1.1.21/24"
IP_4049="11.1.2.21/24"
DIR="/etc/NetworkManager/system-connections"

echo "Generating NetworkManager keyfiles..."

# 1. Physical Interface eno12419np2
cat <<EOF > $DIR/$IF_4048.nmconnection
[connection]
id=$IF_4048
uuid=$(uuidgen)
type=ethernet
interface-name=$IF_4048

[ipv4]
method=disabled

[ipv6]
method=ignore
EOF

# 2. Physical Interface eno12429np3
cat <<EOF > $DIR/$IF_4049.nmconnection
[connection]
id=$IF_4049
uuid=$(uuidgen)
type=ethernet
interface-name=$IF_4049

[ipv4]
method=disabled

[ipv6]
method=ignore
EOF

# 3. VLAN 4048
cat <<EOF > $DIR/vlan4048.nmconnection
[connection]
id=vlan4048
uuid=$(uuidgen)
type=vlan
interface-name=vlan4048

[vlan]
parent=$IF_4048
id=4048

[ipv4]
address1=$IP_4048
method=manual

[ipv6]
method=ignore
EOF

# 4. VLAN 4049
cat <<EOF > $DIR/vlan4049.nmconnection
[connection]
id=vlan4049
uuid=$(uuidgen)
type=vlan
interface-name=vlan4049

[vlan]
parent=$IF_4049
id=4049

[ipv4]
address1=$IP_4049
method=manual

[ipv6]
method=ignore
EOF

# Set secure permissions
echo "Setting file permissions..."
chmod 600 $DIR/*.nmconnection

# Reload NetworkManager
echo "Reloading NetworkManager..."
nmcli connection reload

echo "Configuration complete. Use 'nmcli connection up vlan4048' and 'vlan4049' to activate."
