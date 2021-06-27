FROM ubuntu:20.04 as packages
COPY build.sh ./
RUN ./build.sh

FROM ubuntu:20.04
LABEL maintainer="a.matveev@centrofinans.ru"
# based on https://github.com/JensErat/docker-sogo
# repo from http://www.axis.cz/linux/debian/dists

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow

COPY --from=packages /vendor /vendor

RUN apt-get update && \
    apt-get install -y dpkg-dev && \
    apt-get install -y supervisor nginx && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb [trusted=yes] file:/vendor ./" > /etc/apt/sources.list.d/sogo.list && \
    mkdir -p /usr/share/doc/sogo/ && \
    touch /usr/share/doc/sogo/dummy.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gettext-base\
        sogo\
        sope4.9-gdl1-postgresql\
        sope4.9-gdl1-mysql\
        memcached\
        tzdata && \
        apt-get -y autoremove && \
        rm -rf /var/lib/apt/lists/* && \
        rm -rf /tmp/* /var/tmp/* /vendor/*

# COPY etc /etc
# CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

USER sogo
EXPOSE 20000
ENTRYPOINT ["/usr/sbin/sogod"]
CMD [ \
    "-WONoDetach", "YES", \
    "-WOPidFile", "/var/run/sogo/sogo.pid", \
    "-WOPort", "0.0.0.0:20000" \
]
