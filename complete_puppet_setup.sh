#!/bin/bash

# ========== USER CONFIGURATION ==============
PEM_KEY_PATH=~/Downloads/devops.pem                            # Path to your .pem key file
LOCAL_TAR_PATH=~/Downloads/production.tar.gz                   # Local .tar.gz archive path
REMOTE_PUBLIC_IP=ec2-3-4-32-1.ap-south-1.compute.amazonaws.com # Replace with your instance public IP
REMOTE_DEST_DIR=/etc/puppet/code/environments                  # Where to extract the archive
# ============================================

echo "🔧 Starting Puppet Master + Agent Setup on remote EC2..."

echo "Step 1: Uploading production.tar.gz to EC2 ($REMOTE_PUBLIC_IP)..."
scp -i "$PEM_KEY_PATH" "$LOCAL_TAR_PATH" ubuntu@$REMOTE_PUBLIC_IP:/home/ubuntu/

if [ $? -ne 0 ]; then
  echo "❌ Failed to upload file. Check PEM key or path."
  exit 1
fi

echo "✅ File uploaded. Starting remote Puppet setup and extraction..."

ssh -i "$PEM_KEY_PATH" ubuntu@$REMOTE_PUBLIC_IP << 'EOF'
  set -e

  echo "------------------------------------"
  echo "🛠️ Updating and Installing prerequisites..."
  sudo apt-get update -y
  sudo apt-get install wget vim -y

  echo "------------------------------------"
  echo "📌 Setting up /etc/hosts..."
  PRIVATE_IP=\$(hostname -I | awk '{print \$1}')
  echo "\$PRIVATE_IP puppet" | sudo tee -a /etc/hosts

  echo "------------------------------------"
  echo "📥 Downloading Puppet repo package..."
  wget https://apt.puppetlabs.com/puppet-release-bionic.deb
  sudo dpkg -i puppet-release-bionic.deb

  echo "------------------------------------"
  echo "📦 Installing Puppet Master and Agent..."
  sudo apt-get update -y
  sudo apt-get install puppet-master puppet -y

  echo "------------------------------------"
  echo "🧠 Configuring Puppet Master JVM Memory..."
  sudo sed -i 's/^JAVA_ARGS.*/JAVA_ARGS="-Xms512m -Xmx512m"/' /etc/default/puppet-master
  sudo systemctl restart puppet-master.service
  sudo ufw allow 8140/tcp || true

  echo "------------------------------------"
  echo "🔁 Enabling Puppet Agent service..."
  sudo systemctl start puppet
  sudo systemctl enable puppet

  echo "------------------------------------"
  echo "🔐 Signing Puppet certificates..."
  sudo puppet cert sign --all || true

  echo "------------------------------------"
  echo "📂 Extracting uploaded production.tar.gz..."
  sudo mkdir -p "$REMOTE_DEST_DIR"
  sudo mv /home/ubuntu/production.tar.gz "$REMOTE_DEST_DIR"
  cd "$REMOTE_DEST_DIR"
  sudo tar -xzvf production.tar.gz

  echo "------------------------------------"
  echo "🚀 Running puppet agent to apply manifests..."
  sudo puppet agent --test

  echo "✅ Puppet setup and extraction completed!"
EOF

echo "🎉 All steps finished. Puppet Master-Agent is set up, manifests are extracted and applied."

