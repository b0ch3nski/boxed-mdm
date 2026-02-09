#!/usr/bin/env bash
set -euxo pipefail

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends --no-install-suggests \
    /tmp/zscaler.deb \
    qemu-guest-agent \
    ca-certificates \
    microsocks \
    socat \
    curl \
    sudo \
    gpg

curl --location --fail-with-body --no-progress-meter "https://packages.microsoft.com/keys/microsoft.asc" | gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" > /etc/apt/sources.list.d/microsoft.list

apt-get update
apt-get install -y --no-install-recommends --no-install-suggests intune-portal
sed -i 's/pam_pwquality.so retry=3/pam_pwquality.so retry=3 minlen=12 dcredit=-1 ocredit=-1 ucredit=-1 lcredit=-1/' /etc/pam.d/common-password

cat > /usr/local/bin/xdg-open <<'EOF'
#!/bin/bash
echo "xdg-open $@" >> /tmp/xdg-open.log
dbus-send --session --print-reply --dest=com.bochen.opener --reply-timeout=1 / com.ignore.me string:"$@" 2>/dev/null || true
EOF
chmod +x /usr/local/bin/xdg-open

systemctl disable apt-daily.timer snapd.socket snapd.service
apt-get autoremove -y --purge
rm -rfv \
    /var/cache/apt/* \
    /var/lib/apt/lists/* \
    /var/log/* \
    /var/tmp/* \
    /tmp/*

fstrim --all --verbose
sync
