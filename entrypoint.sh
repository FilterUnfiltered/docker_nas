#!/bin/bash
set -e

echo "Creating folders"
mkdir -p "$SSHFS_LOCAL_PATH" "$GOCRYPTFS_MOUNT"

# Check required variables
if [ -z "$SSHFS_REMOTE" ] || [ -z "$GOCRYPTFS_PASSWORD" ]; then
  echo "Error: SSHFS_REMOTE and GOCRYPTFS_PASSWORD must be set."
  exit 1
fi


SSH_KEY_OPTION=""
if [ -f "/id_rsa" ]; then
  echo "Using mounted SSH key at /id_rsa"
else
  echo "Error: /id_rsa not found, exiting."
  exit 1
fi


echo "Mounting remote: $SSHFS_REMOTE:$SSHFS_REMOTE_PATH -> $SSHFS_LOCAL_PATH"
sshfs -o allow_other -o IdentityFile=/id_rsa -o StrictHostKeyChecking=no \
  "$SSHFS_REMOTE:$SSHFS_REMOTE_PATH" "$SSHFS_LOCAL_PATH"

echo "Mounting gocryptfs -> $GOCRYPTFS_MOUNT"

# If no gocryptfs.conf exists in the encrypted directory, initialize it
if [ ! -f "$SSHFS_LOCAL_PATH/gocryptfs.conf" ]; then
  echo "No gocryptfs.conf found, initializing new filesystem..."
  gocryptfs -init -extpass "printenv GOCRYPTFS_PASSWORD" "$SSHFS_LOCAL_PATH"
else
  echo "Found existing gocryptfs.conf, using it."
fi

gocryptfs -allow_other -extpass "printenv GOCRYPTFS_PASSWORD" -nosyslog "$SSHFS_LOCAL_PATH" "$GOCRYPTFS_MOUNT"

# Keep container running in foreground
if mountpoint -q "$GOCRYPTFS_MOUNT"; then
  echo "Mount ready at $GOCRYPTFS_MOUNT"
  tail -f /dev/null
else
  echo "Mount failed!"
  exit 1
fi
