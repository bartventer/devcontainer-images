# [Choice] Arch Linux version: latest
ARG VARIANT="latest"
FROM archlinux:${VARIANT}

# Adjust directory permissions
RUN chmod 555 /srv/ftp && \
    chmod 755 /usr/share/polkit-1/rules.d/

# Initialize the pacman keyring and perform a full system upgrade
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman-key --populate archlinux && \
    pacman -Sy --needed --noconfirm archlinux-keyring && \
    pacman -Su --noconfirm

# Full system upgrade
RUN pacman -Syu --noconfirm