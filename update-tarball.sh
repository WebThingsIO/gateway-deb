#!/bin/bash

set -e

gateway_version="$1"
gateway_addon_python_version="$2"

if [ -z "$gateway_version" ] || [ -z "$gateway_addon_python_version" ]; then
    echo "Usage:"
    echo "    $0 <gateway version> <gateway-addon-python version>"
    exit 1
fi

gateway_url="https://github.com/mozilla-iot/gateway/archive/${gateway_version}.tar.gz"
gateway_addon_python_url="https://github.com/mozilla-iot/gateway-addon-python"

curl -L -o "gateway.tar.gz" "${gateway_url}"
curl -L -o "gateway-addon-python.tar.gz" "${gateway_addon_python_url}"

git lfs untrack *.orig.tar.gz || true
git rm -f *.orig.tar.gz || true

rm -rf webthings-gateway

tar xzf gateway.tar.gz
mv gateway-*/ webthings-gateway
rm gateway.tar.gz

git clone "$gateway_addon_python_url" webthings-gateway/gateway-addon-python
cd webthings-gateway/gateway-addon-python
git checkout "v${gateway_addon_python_version}"
cd -

tar czf "webthings-gateway_${gateway_version}.orig.tar.gz" webthings-gateway
rm -rf webthings-gateway

git lfs track *.orig.tar.gz
git add *.orig.tar.gz
