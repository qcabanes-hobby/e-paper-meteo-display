#!/bin/bash
read -p "Enter the SSID (Wi-Fi network name): " ssid
read -sp "Enter the passphrase (minimum 8 characters): " passphrase
echo ""

# Validate passphrase length
if [ ${#passphrase} -lt 8 ]; then
  echo "Passphrase must be at least 8 characters long."
  exit 1
fi

# Generate the WPA3 PSK using OpenSSL
salt=$(echo -n "$ssid" | xxd -p)
psk=$(echo -n "$passphrase" | openssl dgst -sha1 -hmac "$salt" -binary | openssl enc -base64)

# Read the original config file, replace SSID and PSK, and output to new file
cat > $1 <<EOF
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="$ssid"
    psk=$psk
}
EOF

# Display the updated configuration file
echo "Updated wpa-supplicant configuration has been written to $1"