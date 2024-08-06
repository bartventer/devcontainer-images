ARG VARIANT="latest"
ARG DOTFILES_REPO="https://github.com/bartventer/dotfiles.git"
FROM ghcr.io/bartventer/base-archlinux:${VARIANT}

LABEL org.opencontainers.image.title="Arch Linux-Based Dotfiles Image"
LABEL org.opencontainers.image.source="https://github.com/bartventer/devcontainer-images"
LABEL org.opencontainers.image.description="Arch Linux container with dotfiles dependencies installed"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Bart Venter <bartventer@outlook.com>"

# Install dotfiles
RUN git clone ${DOTFILES_REPO} /home/vscode/.dotfiles && \
    /home/vscode/.dotfiles/install.sh