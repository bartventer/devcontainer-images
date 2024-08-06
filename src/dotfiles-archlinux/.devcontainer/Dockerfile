ARG VARIANT="latest"
FROM ghcr.io/bartventer/devcontainer-images/base-archlinux:${VARIANT}

LABEL org.opencontainers.image.title="Arch Linux-Based Dotfiles Image"
LABEL org.opencontainers.image.source="https://github.com/bartventer/devcontainer-images"
LABEL org.opencontainers.image.description="Arch Linux container with dotfiles dependencies installed"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Bart Venter <bartventer@outlook.com>"

RUN pacman -Syu --noconfirm coreutils

ENV USERNAME=vscode
ENV HOME_DIR=/home/${USERNAME}

WORKDIR ${HOME_DIR}

ARG DOTFILES_REPO="https://github.com/bartventer/dotfiles.git"
ADD --keep-git-dir=true ${DOTFILES_REPO} dotfiles

USER ${USERNAME}

RUN git config --global --add safe.directory ${HOME_DIR}/dotfiles

RUN cd dotfiles && \
    ./install.sh

USER root