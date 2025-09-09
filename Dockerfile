FROM alpine:3.19

# Install dependencies
RUN apk add --no-cache \
    openssh-client \
    sshfs \
    fuse \
    gocryptfs \
    bash \
    tini

ARG GOCRYPTFS_MOUNT
ARG SSHFS_LOCAL_PATH

# Ensure FUSE is allowed
RUN mkdir -p ${SSHFS_LOCAL_PATH} ${GOCRYPTFS_MOUNT}

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
COPY cleanup.sh /cleanup.sh
RUN chmod +x /entrypoint.sh /cleanup.sh


ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

