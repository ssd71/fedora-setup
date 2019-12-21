#!/bin/bash

echo "Detected Fedora $(rpm -E %fedora)"

echo "Opening a root shell\n"
# sudo into a root shell
sudo -s

echo "Upgrading existing packages\n"
# Upgrade existing packages
dnf upgrade -y

echo "Enabling RPM Fusion Free Repositories"
# Enable RPM Fusion Free repository (for installing VLC)
dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# Install VLC media player
dnf install -y vlc

# Enable RPM Fusion Nonfree repository (optional; for Nvidia drivers and such)
if [ "$1" == "nonfree" ]
    then
        shift
        dnf install -y \
            https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
fi        

# Rustup and Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Visual Studio Code

# Install key and repository
rpm --import https://packages.microsoft.com/keys/microsoft.asc

sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Install Visual Studio Code
dnf check-update
dnf install -y code
# Install VS Code extensions
if [ -a vsc-ext ]
then
    echo "VS Code extensions records detected\n\
        Installing VS Code extensions"
    while read -r line
    do
        code --install-extension "$line"
    done < vsc-ext
fi


# TLP (for laptops)
if [ "$1" == "laptop"  -o "$1" == "thinkpad" ]
    then
        echo "Laptop:\n Installing TLP for power saving\n"
        dnf install -y tlp tlp-rdw
        if [ "$1" == "thinkpad" ]
            then
                echo "ThinkPads only: Installing Drivers for detecting \
                    charge threshold and battery health\n"

                echo "Installing TLP repository\n"
                dnf install -y http://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm 

                echo "Installing drivers\n"
                dnf install kernel-devel akmod-acpi_call
        fi
        shift
fi


