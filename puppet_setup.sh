#!/bin/bash

# ==============================
# Puppet Master & Agent Setup
# ==============================

echo "Updating system..."
sudo apt-get update -y

echo "Installing wget..."
sudo apt-get install -y wget

echo "Setting /etc/hosts with master entry..."
echo "<PRIVATE_IP_OF_MASTER> puppet" | sudo tee -a /etc/hosts

echo "Downloading Puppet release package..."
wget https://apt.puppetlabs.com/puppet-release-bionic.deb

echo "Installing Puppet repo..."
sudo dpkg -i puppet-release-bionic.deb

echo "Installing Puppet Master (if master)..."
sudo apt-get install -y puppet-master

echo "Installing Puppet Agent (if slave)..."
sudo apt-get install -y puppet

echo "Enabling Puppet Agent..."
sudo systemctl enable puppet
sudo systemctl start puppet

echo "Puppet setup complete. For master, run the following:"
echo "sudo ufw allow 8140/tcp"
echo "sudo systemctl restart puppet-master.service"

echo "To check certs on master:"
echo "sudo puppet cert list"
echo "sudo puppet cert sign --all"
