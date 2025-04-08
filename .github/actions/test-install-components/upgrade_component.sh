#!/bin/bash

package_name=$1
target=$2

if [ -z "$package_name" ] || [ -z "$target" ]; then
    echo "Error: Both package_name and target must be provided."
    echo "Usage: $0 <package_name> <target>"
    exit 1
fi

echo "Upgrading Wazuh $target."

if [ -n "$(command -v yum)" ]; then
    upgrade="yum upgrade -y --nogpgcheck"
    installed_log="/var/log/yum.log"
elif [ -n "$(command -v dpkg)" ]; then
    upgrade="dpkg --install"
    installed_log="/var/log/dpkg.log"
else
    echo "Couldn't find type of system"
    exit 1
fi

$upgrade "/packages/$package_name" | tee /packages/status.log

grep -i " installed.*wazuh-$target" $installed_log | tee -a /packages/status.log

if [ $? -eq 0 ]; then
    echo "Wazuh $target was upgraded successfully."
    exit 0
else
    echo "Failed to upgrade Wazuh $target."
    exit 1
fi
