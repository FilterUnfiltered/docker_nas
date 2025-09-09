#!/bin/bash

echo "$(date +'%FT%T') cleanup: starting"

# try to stop gocryptfs gracefully if we started it
if [ -n "${GOC_PID-}" ] && kill -0 "$GOC_PID" 2>/dev/null; then
	echo "Stopping gocryptfs (pid $GOC_PID)"
	kill -TERM "$GOC_PID" 2>/dev/null || true
	wait "$GOC_PID" 2>/dev/null || true
fi

# unmount gocryptfs mountpoint
if mountpoint -q "$GOCRYPTFS_MOUNT"; then
	echo "Unmounting gocryptfs at $GOCRYPTFS_MOUNT"
	fusermount -u "$GOCRYPTFS_MOUNT" || umount -l "$GOCRYPTFS_MOUNT" || true
fi

# unmount sshfs mountpoint
if mountpoint -q "$SSHFS_LOCAL_PATH"; then
	echo "Unmounting sshfs at $SSHFS_LOCAL_PATH"
	fusermount -u "$SSHFS_LOCAL_PATH" || umount -l "$SSHFS_LOCAL_PATH" || true
fi

rm -f gocryptfs_pass
echo "$(date +'%FT%T') cleanup: done"
