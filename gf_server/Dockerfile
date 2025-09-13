FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    gnupg \
    lsb-release \
    wget \
    net-tools \
    nano \
    socat \
    postgresql \
    postgresql-client \
    iputils-ping \
    php-cli \
    php-pgsql \
    php \
    apache2 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /root/gf_server

COPY ./gf_server .

RUN chmod 777 /root/gf_server/*

EXPOSE 80 6543 6544 6545 6546 7777 5560 7878 10321 20061 10322 20062 10329 20069 5517 5527 5597 1010 1091 1021 1011 1090 1020 43916 10010 43121 10090 34568 39901 53317 10020

ENTRYPOINT ["/root/gf_server/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
