FROM debian:stable-slim AS setup
ARG VERSION
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY docker/setup.sh /setup.sh
RUN /setup.sh

FROM debian:stable-slim AS libs
COPY docker/libs.sh /libs.sh
RUN /libs.sh /rootfs

FROM scratch
COPY --from=libs /rootfs/ /
COPY --from=setup /opt/geekbench /opt/geekbench
WORKDIR /opt/geekbench
USER 65534:65534
STOPSIGNAL SIGINT
ENTRYPOINT [ "/opt/geekbench/entrypoint" ]
