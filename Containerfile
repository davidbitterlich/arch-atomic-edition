FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/davidbitterlich/arch-bootc:latest

ARG DESKTOP
ENV DESKTOP=${DESKTOP}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx,rw \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=cache,dst=/var/lib/apt \
    --mount=type=cache,dst=/var/lib/dpkg/updates \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/desktop.sh ${DESKTOP} && \
    /ctx/finalize.sh

# Setup a temporary root passwd (changeme) for dev purposes
RUN pacman -S whois --noconfirm
RUN usermod -p "$(echo "changeme" | mkpasswd -s)" root

# https://bootc-dev.github.io/bootc/bootc-images.html#standard-metadata-for-bootc-compatible-images
LABEL containers.bootc 1

RUN bootc container lint
