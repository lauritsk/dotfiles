FROM dhi.io/alpine-base:3.23-dev

RUN apk add --no-cache ca-certificates curl bash fish git mise chezmoi sudo \
    && addgroup -S dev \
    && adduser -S -D -h /home/dev -G dev -s /usr/bin/fish dev \
    && mkdir -p /etc/sudoers.d \
    && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

USER dev
WORKDIR /workspaces
