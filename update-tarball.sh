#!/bin/bash

set -e

_gateway_version="$1"
_gateway_addon_python_version="$2"

if [ -z "${_gateway_version}" ] || [ -z "${_gateway_addon_python_version}" ]; then
    echo "Usage:"
    echo "    $0 <gateway version> <gateway-addon-python version>"
    exit 1
fi

_gateway_url="https://github.com/mozilla-iot/gateway/archive/${_gateway_version}.tar.gz"
_gateway_addon_python_url="https://github.com/mozilla-iot/gateway-addon-python"

# Download the gateway tarball
curl -L -o "gateway.tar.gz" "${_gateway_url}"

# Clean up
git lfs untrack *.orig.tar.gz || true
git rm -f *.orig.tar.gz || true
rm -rf webthings-gateway

# Unpack the gateway
tar xzf gateway.tar.gz
mv gateway-*/ webthings-gateway
rm gateway.tar.gz

# Pull down the gateway-addon Python library
git clone "${_gateway_addon_python_url}" webthings-gateway/gateway-addon-python
cd webthings-gateway/gateway-addon-python
git checkout "v${_gateway_addon_python_version}"
cd -

# Package everything up
tar czf "webthings-gateway_${_gateway_version}.orig.tar.gz" webthings-gateway
rm -rf webthings-gateway

# Add the new tarball to git
git lfs track *.orig.tar.gz
git add *.orig.tar.gz
