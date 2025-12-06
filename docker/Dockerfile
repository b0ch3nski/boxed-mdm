# syntax=docker/dockerfile:1.20
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xc"]
ENV DEBIAN_FRONTEND=noninteractive NO_AT_BRIDGE=1

RUN apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates \
        socat \
        curl \
        gosu \
        gpg; \
    curl --location --fail-with-body --no-progress-meter "https://packages.microsoft.com/keys/microsoft.asc" | gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" > /etc/apt/sources.list.d/microsoft.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests intune-portal || true; \
    update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java; \
    sed -i 's/pam_pwquality.so retry=3/pam_pwquality.so retry=3 minlen=12 dcredit=-1 ocredit=-1 ucredit=-1 lcredit=-1/' /etc/pam.d/common-password; \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

COPY --chmod=755 <<EOF /usr/local/bin/init.sh
#!/usr/bin/env bash
set -euxo pipefail

dbus-daemon --system --fork --print-address --address="unix:path=/tmp/dbus_system_bus_socket" > /tmp/dbus_system_bus_address
export DBUS_SYSTEM_BUS_ADDRESS="\$(cat /tmp/dbus_system_bus_address)"

export STATE_DIRECTORY="/var/lib/ms-state" RUNTIME_DIRECTORY="/run/ms-runtime"
mkdir -pv "\${STATE_DIRECTORY}" "\${RUNTIME_DIRECTORY}" -m 700
chown -v microsoft-identity-broker:microsoft-identity-broker "\${STATE_DIRECTORY}" "\${RUNTIME_DIRECTORY}"

gosu microsoft-identity-broker:microsoft-identity-broker /opt/microsoft/identity-broker/bin/microsoft-identity-device-broker &

exec as_user.sh intune.sh
EOF

COPY --chmod=755 <<EOF /usr/local/bin/as_user.sh
#!/usr/bin/env bash
set -euxo pipefail

useradd --uid \${USER_ID} --gid 0 --shell "/bin/bash" --create-home "slave" || true

export XDG_RUNTIME_DIR="/run/user/\${USER_ID}" STATE_DIRECTORY="/tmp/ms-state" RUNTIME_DIRECTORY="/tmp/ms-runtime"
mkdir -pv "\${XDG_RUNTIME_DIR}" "\${STATE_DIRECTORY}" "\${RUNTIME_DIRECTORY}" -m 700
chown -v "\${USER_ID}:0" "\${XDG_RUNTIME_DIR}" "\${STATE_DIRECTORY}" "\${RUNTIME_DIRECTORY}"

exec gosu "\${USER_ID}:0" "\${@}"
EOF

COPY --chmod=755 <<EOF /usr/local/bin/intune.sh
#!/usr/bin/env bash
set -euxo pipefail

dbus-daemon --session --fork --print-address --address="unix:path=/tmp/dbus_session_bus_socket" > /tmp/dbus_session_bus_address
export DBUS_SESSION_BUS_ADDRESS="\$(cat /tmp/dbus_session_bus_address)"
socat TCP-LISTEN:5556,reuseaddr,fork UNIX-CONNECT:/tmp/dbus_session_bus_socket &

eval \$(echo -n 'xxx' | gnome-keyring-daemon --unlock | sed -e 's/^/export /')

until [ -f "\${STATE_DIRECTORY}/registration.toml" ]; do
    intune-portal || true
    sleep 1
done

while true; do
    /opt/microsoft/intune/bin/intune-agent
    sleep \${INTUNE_AGENT_INTERVAL:-3600} &
    wait \$!
done
EOF

CMD ["init.sh"]
