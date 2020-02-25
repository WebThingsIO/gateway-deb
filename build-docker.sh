#!/bin/bash
# -*- mode: Bash; tab-width: 2; indent-tabs-mode: t; -*-
#{
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/ .
#}

set -e -x

project="webthings-gateway"
dir="/usr/local/opt/${project}/dist"
repository="gatewaydeb_default"
tag="latest"
image="${repository}:${tag}"


cd "$(readlink -f $(dirname "$0"))"

docker version

docker build -t "${repository}" .
container=$(docker create "$image")
docker cp "$container:$dir/" ./
