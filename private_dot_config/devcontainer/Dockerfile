ARG BASE_IMAGE=dhi.io/debian-base:trixie
FROM ${BASE_IMAGE}

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends sudo passwd curl git \
    && install -dm 755 /etc/apt/keyrings \
    && curl -fSs https://mise.jdx.dev/gpg-key.pub -o /etc/apt/keyrings/mise-archive-keyring.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.jdx.dev/deb stable main" > /etc/apt/sources.list.d/mise.list \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends mise \
    && groupadd --system dev \
    && useradd --system --create-home --home-dir /home/dev --gid dev --shell /bin/bash dev \
    && mkdir -p /etc/sudoers.d \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/home/dev/.local/share/mise/shims:/home/dev/.local/bin:${PATH}"

USER dev
RUN mise use -g usage@latest chezmoi@latest ripgrep@latest fd@latest

WORKDIR /workspaces
