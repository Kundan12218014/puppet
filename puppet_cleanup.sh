#!/bin/bash

set -e

echo "🔧 Stopping Puppet-related services..."
sudo systemctl stop puppet || true
sudo systemctl stop puppet-master || true

echo "🚫 Disabling services..."
sudo systemctl disable puppet || true
sudo systemctl disable puppet-master || true

echo "🧽 Uninstalling all Puppet packages..."
sudo apt-get remove --purge puppet puppet-master -y
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "🗑️ Deleting Puppet-related directories..."
sudo rm -rf /etc/puppet
sudo rm -rf /var/lib/puppet
sudo rm -rf /var/log/puppet
sudo rm -rf /etc/default/puppet-master
sudo rm -rf /etc/systemd/system/puppet*

echo "🧹 Removing puppet-release .deb file if downloaded..."
sudo rm -f puppet-release-bionic.deb

echo "🧹 Removing production.tar.gz and extracted content..."
sudo rm -f /home/ubuntu/production.tar.gz
sudo rm -f /etc/puppet/code/environments/production.tar.gz
sudo rm -rf /etc/puppet/code/environments/production
sudo rm -rf /etc/puppet/code/environments/production/manifests
sudo rm -rf /etc/puppet/code/environments/production/modules

echo "🧽 Cleaning /etc/hosts entry..."
sudo sed -i '/puppet$/d' /etc/hosts

echo "🔥 Cleaning up UFW firewall rules..."
sudo ufw delete allow 8140/tcp || true

echo "🧹 Removing test files created by manifests..."
sudo rm -f /tmp/puppet_test.txt
sudo rm -f /tmp/status.txt

echo "✅ Cleanup complete. All Puppet-related configurations and files have been removed."

