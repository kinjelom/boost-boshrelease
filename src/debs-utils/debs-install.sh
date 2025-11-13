#!/usr/bin/env bash
set -euo pipefail

install_deb_if_missing() {
    local deb_name="$1"
    local deb_path="$2"

    # Check if the package is already installed
    if dpkg-query -W -f='${Status}' "$deb_name" 2>/dev/null | grep -q "install ok installed"; then
        echo "*** $deb_name is already installed"
    else
        echo "*** Installing $deb_name -> $deb_path"
        dpkg --force-confdef -i "$deb_path"
    fi
}

install_debs_from_dir() {
    local debs_dir_path="$1"

    shopt -s nullglob
    local debs=( "$debs_dir_path"/*/*.deb )
    if ((${#debs[@]} == 0)); then
        echo "*** No debs found in $debs_dir_path"
        shopt -u nullglob
        return 0
    fi

    echo "*** Installing ${#debs[@]} debs from $debs_dir_path"
    dpkg --force-confdef -i "${debs[@]}"
    shopt -u nullglob
}

# Usage:
# CODENAME=$(get_system_codename)
# if [ "$CODENAME" == "xenial" ]; then
#       echo $CODENAME
# fi
get_system_codename() {
    # Return only the codename, e.g. "jammy", "noble"
    lsb_release -sc 2>/dev/null
}
