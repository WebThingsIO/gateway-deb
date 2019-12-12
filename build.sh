#!/bin/bash

set -e

# Clean up
git clean -Xdf
rm -rf webthings-gateway

# Unpack the tarball
tar xzf *.orig.tar.gz
cd webthings-gateway

# Copy in the build scripts
cp -r ../debian .

# Build it
debuild -us -uc

# Done
cd ..
