#!/bin/bash

# ======== USER CONFIGURATION =========
PEM_KEY_PATH=~/Downloads/devops.pem        # Path to your .pem key file
REMOTE_FILE_PATH=/etc/puppet/code/environments/production.tar.gz
LOCAL_SAVE_PATH=~/Downloads/production.tar.gz

SOURCE_IP=xx.xx.xx.xx                      # Replace with source instance PUBLIC IP
DEST_IP=yy.yy.yy.yy                        # Replace with destination instance PUBLIC IP
DEST_DIR=/etc/puppet/code/environments     # Folder where to extract on destination
# ======================================

echo "Step 1: Downloading from source ($SOURCE_IP)..."
scp -i "$PEM_KEY_PATH" ubuntu@$SOURCE_IP:$REMOTE_FILE_PATH "$LOCAL_SAVE_PATH"

if [ $? -ne 0 ]; then
  echo "❌ Failed to download file from source."
  exit 1
fi

echo "✅ Downloaded to $LOCAL_SAVE_PATH"

echo "Step 2: Uploading to destination ($DEST_IP)..."
scp -i "$PEM_KEY_PATH" "$LOCAL_SAVE_PATH" ubuntu@$DEST_IP:/home/ubuntu/

if [ $? -ne 0 ]; then
  echo "❌ Failed to upload file to destination."
  exit 1
fi

echo "✅ Uploaded to destination."

echo "Step 3: Extracting on destination..."
ssh -i "$PEM_KEY_PATH" ubuntu@$DEST_IP << EOF
  set -e
  echo "📦 Moving tar file to $DEST_DIR"
  sudo mv /home/ubuntu/production.tar.gz $DEST_DIR
  cd $DEST_DIR
  echo "📂 Extracting contents..."
  sudo tar -xzvf production.tar.gz
  echo "✅ Extraction complete."
EOF

echo "🎉 Done! Puppet files transferred and extracted."

