FROM dhi.io/alpine-base:3.23-dev

RUN apk add --no-cache sudo ca-certificates curl bash git mise chezmoi fd ripgrep usage \
    && addgroup -S dev \
    && adduser -S -D -h /home/dev -G dev dev \
    && mkdir -p /etc/sudoers.d \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

USER dev
WORKDIR /workspaces
