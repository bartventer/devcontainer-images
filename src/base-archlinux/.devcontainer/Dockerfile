ARG VARIANT="latest"
FROM docker.io/archlinux/archlinux:${VARIANT}

LABEL org.opencontainers.image.title="Arch Linux Base Image"
LABEL org.opencontainers.image.source="https://github.com/bartventer/devcontainer-images"
LABEL org.opencontainers.image.description="Simple Arch Linux container with common tools installed"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Bart Venter <bartventer@outlook.com>"

# Adjust directory permissions
RUN chmod 555 /srv/ftp && \
    chmod 755 /usr/share/polkit-1/rules.d/

# Initialize pacman keyring and upgrade system
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Sy --needed --noconfirm --disable-download-timeout archlinux-keyring && \
    pacman -Su --noconfirm --disable-download-timeout
