#!/usr/bin/env bash
# Install vzborg with:
#
# wget -O - https://raw.githubusercontent.com/g3492/vzborg/master/install_and_update_vzborg.sh | bash
#
# vim: set filetype=sh :
# Make the script exit when a command fails (set -e).
set -o errexit
# Make the script exit when tries to use undeclared variables (set -u)
set -o nounset
# Exit on pipe fail
set -o pipefail

say() {
    echo -e $1
}
die() {
    say "Error: $1" >&2
    exit 1
}

version_greater_equal() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# CHECKS

# Check if running as root.
if [[ $EUID = 0 ]]; then
   say "OK. Running as root."
else
    die "vzborg installation must be executed as root user."
fi

# Check PVE version
if [[ -f /usr/bin/pveversion ]]; then
    pve_version="$(pveversion | cut -d'/' -f2)"
    say 'Checking PVE version'
    if version_greater_equal "${pve_version}" 5.0; then
        say "OK"
    else
        die "You need Proxmox virtual environment (PVE) version >= 5.0.0"
    fi
else
    die "Can not find pveversion. Is this a Proxmox Virtual Environment (PVE) server?"
fi
# Check borg version
if [[ -f /usr/bin/borg ]]; then
    borg_version="$(borg -V | cut -d' ' -f2)"
    say 'Checking Borg backup version'
    if version_greater_equal "${borg_version}" 1.1.0; then
        say "OK"
    else
        die "You need borg backup version >= 1.1.0"
    fi
else
    die "Can not find borg. Is Borg Backup installed?"
fi

# Install
say "Installing vzborg to /usr/local/bin"
wget https://raw.githubusercontent.com/g3492/vzborg/master/vzborg -O /usr/local/bin/vzborg
chmod +x /usr/local/bin/vzborg
if [[ -f /etc/vzborg.conf ]]; then
    say "Configuration file /etc/vzborg.conf exist."
else
    say "Creating default configuration file (/etc/vzborg.conf)"
    wget -P /etc https://raw.githubusercontent.com/g3492/vzborg/master/vzborg.conf 
fi
