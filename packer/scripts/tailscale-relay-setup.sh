#!/bin/bash
# Add tailscale repos and installs tailscale
set -x
sleep 15

# add tailscale repo
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list

# base packages
sudo apt update -y && \
sudo apt install -y tailscale

exit 0
