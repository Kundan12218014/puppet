#!/bin/bash

# Exit on any error
set -e

echo "------------------------------------"
echo "Updating the server..."
sudo apt-get update -y
sudo apt-get install wget vim -y

echo "------------------------------------"
echo "Setting up hostname in /etc/hosts..."
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "$PRIVATE_IP puppet" | sudo tee -a /etc/hosts

echo "------------------------------------"
echo "Downloading Puppet package..."
wget https://apt.puppetlabs.com/puppet-release-bionic.deb

echo "Installing Puppet release package..."
sudo dpkg -i puppet-release-bionic.deb

echo "Installing Puppet Master & Agent..."
sudo apt-get update -y
sudo apt-get install puppet-master puppet -y

echo "------------------------------------"
echo "Checking Puppet Master installation..."
apt policy puppet-master
sudo systemctl status puppet-master.service || true

echo "------------------------------------"
echo "Configuring JVM memory for Puppet Master..."
sudo sed -i 's/^JAVA_ARGS.*/JAVA_ARGS="-Xms512m -Xmx512m"/' /etc/default/puppet-master

echo "Restarting Puppet Master..."
sudo systemctl restart puppet-master.service

echo "Allowing port 8140..."
sudo ufw allow 8140/tcp || true

echo "------------------------------------"
echo "Starting and enabling Puppet Agent..."
sudo systemctl start puppet
sudo systemctl enable puppet

echo "------------------------------------"
echo "Checking and signing agent certificate..."
sudo puppet cert list || true
sudo puppet cert sign --all || true

echo "------------------------------------"
echo "Creating initial manifest (site.pp)..."
sudo mkdir -p /etc/puppet/code/environments/production/manifests/
cat <<EOF | sudo tee /etc/puppet/code/environments/production/manifests/site.pp
file { '/tmp/puppet_test.txt':
  ensure  => present,
  mode    => '0644',
  content => "Working on \${ipaddress_eth0}!\n",
}
EOF

echo "Restarting Puppet Master after manifest creation..."
sudo systemctl restart puppet-master

echo "------------------------------------"
echo "Running Puppet Agent to apply site.pp..."
sudo puppet agent --test

echo "Checking if file was created..."
ls /tmp/puppet_test.txt && cat /tmp/puppet_test.txt

echo "------------------------------------"
echo "Creating additional manifest (new_site.pp)..."
cat <<EOF | sudo tee /etc/puppet/code/environments/production/manifests/new_site.pp
node default {
  package { 'nginx':
    ensure => installed,
  }

  file { '/tmp/status.txt':
    content => 'Nginx has been installed successfully',
    mode    => '0644',
  }
}
EOF

echo "Running Puppet Agent to apply new_site.pp..."
sudo puppet agent --test

echo "Checking Nginx status and result file..."
sudo systemctl status nginx || true
cat /tmp/status.txt

echo "You can now access the Nginx default page via your EC2 public IP!"
echo "Setup completed successfully."

