#!/bin/bash
# This script installs Ansible on the host machine.
#
# Usage: ./setup_ansible.sh

if ! command -v ansible >/dev/null 2>&1; then
    echo "Ansible is not installed. Installing Ansible..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew is not installed. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install ansible

    elif [[ -f /etc/debian_version ]]; then
        sudo apt update
        sudo apt install -y ansible

    elif [[ -f /etc/redhat-release ]]; then
        sudo yum install -y epel-release
        sudo yum install -y ansible

    else
        echo "Unsupported OS"
        exit 1

    fi

    echo "Ansible has been installed."
else
    echo "Ansible is already installed."
fi