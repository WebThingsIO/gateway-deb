#!/bin/bash

set -e

_gateway_version="$1"
_gateway_addon_python_version="$2"
_intent_parser_version="$3"

if [ -z "${_gateway_version}" ] || [ -z "${_gateway_addon_python_version}" ]; then
    echo "Usage:"
    echo "    $0 <gateway version> <gateway-addon-python version> [ <intent-parser version> ]"
    exit 1
fi

if [ -z "${_intent_parser_version}" ]; then
    _intent_parser_version="52b1d7f1f9d53d83adb813bc7bfbbbed203c0627"
fi

_gateway_url="https://github.com/mozilla-iot/gateway/archive/${_gateway_version}.tar.gz"
_gateway_addon_python_url="https://github.com/mozilla-iot/gateway-addon-python"
_intent_parser_url="https://github.com/mozilla-iot/intent-parser/archive/${_intent_parser_version}.zip"

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

# Pull down the intent parser
curl -L -o intent-parser.zip "${_intent_parser_url}"
unzip intent-parser.zip
mv intent-parser-*/ webthings-gateway/intent-parser
chmod a+x webthings-gateway/intent-parser/intent-parser-server.py
rm intent-parser.zip

# Package everything up
tar czf "webthings-gateway_${_gateway_version}.orig.tar.gz" webthings-gateway
rm -rf webthings-gateway

# Add the new tarball to git
git lfs track *.orig.tar.gz
git add *.orig.tar.gz
