#!/bin/bash

set -e

# Install build dependencies
_build_deps=$(
    grep ^Build-Depends debian/control |
        cut -d: -f2- |
        sed -E -e 's/\s*\([><=]+\s*[0-9.]+\)//g' -e 's/,//g'
)
_extra_deps="build-essential ca-certificates devscripts fakeroot git-lfs"
sudo -p 'Enter sudo password to install build dependencies: ' \
    su -c "apt update && apt install -y ${_extra_deps} ${_build_deps}"

# Clean up
git clean -Xdf
rm -rf webthings-gateway

# Unpack the tarball
git lfs pull
tar xzf *.orig.tar.gz
cd webthings-gateway

# Copy in the build scripts
cp -r ../debian .

# Pin the node major version, since dependencies will be built against it
_node_version=$(dpkg --status nodejs | awk '/Version/ {print $2}' | cut -d. -f1)
sed -i "s/{{nodejs}}/nodejs (>= ${_node_version}.0.0), nodejs (<< $(expr ${_node_version} + 1).0.0~~)/" debian/control

# Pin the python3 major version, since dependencies will be built against it
_python3_version=$(dpkg --status python3 | awk '/Version/ {print $2}' | cut -d. -f 1-2)
sed -i "s/{{python3}}/python3 (>= ${_python3_version}.0), python3 (<< 3.$(expr $(echo ${_python3_version} | cut -d. -f2) + 1).0~~)/" debian/control

# Build it
debuild -us -uc

# Done building, let's just rename things
cd ..
_deb=$(ls webthings-gateway_*.deb)
_renamed="${_deb/.deb/-$(lsb_release -is | tr '[A-Z]' '[a-z]')-$(lsb_release -cs | tr '[A-Z]' '[a-z]')}.deb"
mv "${_deb}" "${_renamed}"

echo ""
echo "Done building: ${_renamed}"
