FROM ubuntu:rolling AS setup
ARG VERSION
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y wget
COPY setup.sh /setup.sh
RUN /setup.sh

FROM ubuntu:rolling
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY --from=setup /opt/geekbench /opt/geekbench
COPY --from=setup /entrypoint.sh /entrypoint.sh
STOPSIGNAL SIGINT
ENTRYPOINT [ "/entrypoint.sh" ]
