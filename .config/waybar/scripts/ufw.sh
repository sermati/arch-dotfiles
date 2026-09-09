#!/bin/bash
# Waybar custom module: UFW firewall status (via systemd, no root needed)

if systemctl is-active --quiet ufw.service; then
    echo '{"text":"","tooltip":"UFW: activo","class":"active"}'
else
    echo '{"text":"","tooltip":"UFW: inactivo","class":"inactive"}'
fi
