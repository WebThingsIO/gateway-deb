#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-
#{
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/ .
#}

FROM debian:10 as webthings-gateway-builder
LABEL maintainer="Philippe Coval <rzr@users.sf.net>"

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG ${LC_ALL}

RUN echo "#log: Configuring locales and setting up system" \
  && set -x \
  && apt update \
  && apt install -y locales sudo \
  && echo "${LC_ALL} UTF-8" | tee /etc/locale.gen \
  && locale-gen ${LC_ALL} \
  && dpkg-reconfigure locales \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && sync

ENV project webthings-gateway

ENV workdir /usr/local/opt/${project}/src/${project}
COPY . ${workdir}
WORKDIR ${workdir}
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && ./build.sh \
  && install -d /usr/local/opt/${project}/dist \
  && install ${project}*.* /usr/local/opt/${project}/dist \
  && sync


FROM debian:10
LABEL maintainer="Philippe Coval <rzr@users.sf.net>"
ENV project webthings-gateway
COPY --from=webthings-gateway-builder /usr/local/opt/${project}/dist /usr/local/opt/${project}/dist
WORKDIR /usr/local/opt/${project}/dist

RUN echo "# log: ${project}: Installing" \
  && set -x \
  && find ${PWD} \
  && apt-get update -y \
  && apt install -y ./${project}_*.deb \
  && apt-get install -f -y \
  && dpkg -L ${project} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && sync

ENTRYPOINT [ "/usr/bin/webthings-gateway" ]
