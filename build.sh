#!/bin/bash -e

set -x

cd "$(readlink -f $(dirname "$0"))"

# On Ubuntu 18.04, we need to get Node.js from NodeSource
if [[ $(. /etc/lsb-release && echo $DISTRIB_ID) == "Ubuntu" &&
      $(. /etc/lsb-release && echo $DISTRIB_CODENAME) = "bionic" ]]; then
    if [[ $EUID -eq 0 ]]; then
        apt update
        apt install --no-install-recommends -y ca-certificates curl
        curl -sL https://deb.nodesource.com/setup_10.x | bash -
    else
        sudo -p 'Enter sudo password to install build dependencies: ' \
            su -c "apt update && apt install --no-install-recommends -y ca-certificates curl"
        curl -sL https://deb.nodesource.com/setup_10.x | sudo -p 'Enter sudo password to install build dependencies: ' -E bash -
    fi

    sed -i "s/{{npm}}//" debian/control
else
    sed -i "s/{{npm}}/npm,/" debian/control
fi

# Install build dependencies
_build_deps=$(
    grep ^Build-Depends debian/control |
        cut -d: -f2- |
        sed -E -e 's/\s*\([><=]+\s*[0-9.]+\)//g' -e 's/,//g'
)
_extra_deps="build-essential ca-certificates devscripts fakeroot git-lfs lsb-release"

if [[ $EUID -eq 0 ]]; then
    apt update
    apt install --no-install-recommends -y ${_extra_deps} ${_build_deps}
    # this should be `npm config -g set unsafe-perm true`, but that sometimes
    # causes crashes with ancient npm versions
    echo 'unsafe-perm = true' >> /etc/npmrc
    npm install -g npm@latest
else
    sudo -p 'Enter sudo password to install build dependencies: ' \
        su -c "apt update && apt install --no-install-recommends -y ${_extra_deps} ${_build_deps} && echo 'unsafe-perm = true' >> /etc/npmrc && npm install -g npm@latest"
fi

# Clean up
git clean -Xdf
rm -rf webthings-gateway

# Unpack the tarball
git lfs install
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
ln -s "${_deb}" "webthings-gateway.deb"

echo ""
echo "Done building: ${_deb}"
