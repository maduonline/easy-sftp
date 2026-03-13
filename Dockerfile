FROM debian:trixie-slim

LABEL maintainer="atmoz.net"
LABEL org.opencontainers.image.description="Secure SFTP server based on OpenSSH"

# Steps done in one RUN layer:
# - Install upgrades and new packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends \
        openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD pgrep sshd > /dev/null || exit 1

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
