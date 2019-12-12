#!/bin/bash

set -e

git clean -Xdf
tar xzf *.orig.tar.gz
cd webthings-gateway
cp -r ../debian .
debuild -us -uc
cd ..
