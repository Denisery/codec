#!/bin/bash

set -e

# Default values for username and password
USERNAME=${USERNAME:-user}
PASSWORD=${PASSWORD:-root}
PIN=${PIN:-123456}
CRP=${CRP:-"DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="4/0AanRRrsG8NTDinU2auLSM-oeCi5919tZ5iHPaYbJ5GNFptoC-Hq2JCoElgdw2OTxJn_00A" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)"}
AUTOSTART=${AUTOSTART:-true}

# Create the user
echo "Creating user: $USERNAME"
useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo "$USERNAME"

# Set bash as the default shell
sed -i 's|/bin/sh|/bin/bash|g' /etc/passwd

# Install Chrome Remote Desktop
echo "Installing Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg --install chrome-remote-desktop_current_amd64.deb || apt-get install -f -y

# Configure desktop environment
echo "Configuring Desktop Environment"
echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session
systemctl disable lightdm.service

# Configure autostart if enabled
if [ "$AUTOSTART" = true ]; then
    echo "Configuring autostart for user: $USERNAME"
    mkdir -p /home/$USERNAME/.config/autostart
    cat <<EOL > /home/$USERNAME/.config/autostart/colab.desktop
[Desktop Entry]
Type=Application
Name=Colab
Exec=sh -c "sensible-browser https://colab.research.google.com/github/PradyumnaKrishna/Colab-Hacks/blob/master/Colab%20RDP/Colab%20RDP.ipynb"
Icon=
Comment=Open a predefined notebook at session signin.
X-GNOME-Autostart-enabled=true
EOL
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
fi

# Add user to the Chrome Remote Desktop group
usermod -aG chrome-remote-desktop "$USERNAME"

# Start Chrome Remote Desktop if CRP code is provided
if [ -n "$CRP" ]; then
    echo "Starting Chrome Remote Desktop"
    su - $USERNAME -c "$CRP --pin=$PIN"
    service chrome-remote-desktop start
else
    echo "CRP code not provided. Skipping Chrome Remote Desktop setup."
fi

exec "$@"
