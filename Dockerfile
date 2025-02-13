#
# Dockerfile for scrapyd
#

FROM debian:bullseye
MAINTAINER EasyPi Software Foundation

ARG TARGETPLATFORM
ARG SCRAPY_VERSION=2.5.1
ARG SCRAPYD_VERSION=1.3.0
ARG SCRAPYD_CLIENT_VERSION=v1.2.0
ARG SCRAPYRT_VERSION=v0.13
ARG SPIDERMON_VERSION=1.16.2
ARG PILLOW_VERSION=9.0.0

SHELL ["/bin/bash", "-c"]

RUN set -xe \
    && echo ${TARGETPLATFORM} \
    && apt-get update \
    && apt-get install -y autoconf \
    build-essential \
    curl \
    libffi-dev \
    libssl-dev \
    libtool \
    libxml2 \
    libxml2-dev \
    libxslt1.1 \
    libxslt1-dev \
    python3 \
    python3-dev \
    python3-distutils \
    tini \
    vim-tiny \
    && apt-get install -y libtiff5 \
    libtiff5-dev \
    libfreetype6-dev \
    libjpeg62-turbo \
    libjpeg62-turbo-dev \
    liblcms2-2 \
    liblcms2-dev \
    libwebp6 \
    libwebp-dev \
    zlib1g \
    zlib1g-dev \
    && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt install -y cargo; fi \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
    && pip install --no-cache-dir ipython \
    https://github.com/scrapy/scrapy/archive/refs/tags/$SCRAPY_VERSION.zip \
    https://github.com/scrapy/scrapyd/archive/refs/tags/$SCRAPYD_VERSION.zip \
    https://github.com/scrapy/scrapyd-client/archive/refs/tags/$SCRAPYD_CLIENT_VERSION.zip \
    https://github.com/scrapy-plugins/scrapy-splash/archive/refs/heads/master.zip \
    https://github.com/scrapinghub/scrapyrt/archive/refs/tags/$SCRAPYRT_VERSION.zip \
    https://github.com/scrapinghub/spidermon/archive/refs/tags/$SPIDERMON_VERSION.zip \
    https://github.com/python-pillow/Pillow/archive/refs/tags/$PILLOW_VERSION.zip \
    && mkdir -p /etc/bash_completion.d \
    && curl -sSL https://github.com/scrapy/scrapy/raw/master/extras/scrapy_bash_completion -o /etc/bash_completion.d/scrapy_bash_completion \
    && echo 'source /etc/bash_completion.d/scrapy_bash_completion' >> /root/.bashrc \
    && if [[ ${TARGETPLATFORM} = "linux/arm/v7" ]]; then apt purge -y --auto-remove cargo; fi \
    && apt-get purge -y --auto-remove autoconf \
    build-essential \
    curl \
    libffi-dev \
    libssl-dev \
    libtool \
    libxml2-dev \
    libxslt1-dev \
    python3-dev \
    && apt-get purge -y --auto-remove libtiff5-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    liblcms2-dev \
    libwebp-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./spiders_req.txt .
RUN pip3 install -r spiders_req.txt

#COPY /raw/meta /raw

COPY ./scrapyd.conf /etc/scrapyd/
VOLUME /etc/scrapyd/ /var/lib/scrapyd/
EXPOSE 6800

ENTRYPOINT ["tini", "--"]
CMD ["scrapyd", "--pidfile="]
