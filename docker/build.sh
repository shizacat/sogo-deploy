#!/usr/bin/env bash

# Config section
# --------------

# Change your name and email address
DEBFULLNAME="Christian Schweingruber"
DEBEMAIL="c.schweingruber@catatec.ch"

# Version of SOGo which will be built
VERSION_TO_BUILD="5.2.0"

# Post config section
# -------------------

set -e

# https://stackoverflow.com/a/246128
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

REPOSITORY_SOGO="https://github.com/inverse-inc/sogo.git"
REPOSITORY_SOPE="https://github.com/inverse-inc/sope.git"
SOGO_GIT_TAG="SOGo-${VERSION_TO_BUILD}"
SOPE_GIT_TAG="SOPE-${VERSION_TO_BUILD}"

PACKAGES_DIR="${BASE_DIR}/vendor"
PACKAGES_TO_INSTALL="\
    git\
    zip\
    wget\
    make\
    debhelper\
    gnustep-make\
    libssl-dev\
    libgnustep-base-dev\
    libldap2-dev\
    zlib1g-dev\
    libmemcached-dev\
    liblasso3-dev\
    libcurl4-gnutls-dev\
    devscripts\
    libexpat1-dev\
    libpopt-dev\
    libsbjson-dev\
    libsbjson2.3\
    libcurl4\
    liboath-dev\
    libsodium-dev\
    libzip-dev\
    libmariadbclient-dev-compat\
"
# libpq-dev

export DEBIAN_FRONTEND=noninteractive

# Pre build section
# -------------

mkdir $PACKAGES_DIR
cd "${PACKAGES_DIR}"

# Do not install recommended or suggested packages
echo 'APT::Get::Install-Recommends "false";' >> /etc/apt/apt.conf
echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf

# Fix default python
ln -s /usr/bin/python3 /usr/bin/python

# Install required packages

# shellcheck disable=SC2086
apt-get update && apt-get install -y $PACKAGES_TO_INSTALL

# Library - PostgreSQL 12
echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update 
apt-get -y install postgresql-server-dev-12 libpq-dev

# Download and install libwbxml2 and libwbxml2-dev
#wget -c https://packages.inverse.ca/SOGo/nightly/5/debian/pool/stretch/w/wbxml2/libwbxml2-dev_0.11.6-1_amd64.deb
#wget -c https://packages.inverse.ca/SOGo/nightly/5/debian/pool/stretch/w/wbxml2/libwbxml2-0_0.11.6-1_amd64.deb
wget --no-check-certificate -qc https://packages.sogo.nu/nightly/5/ubuntu/pool/focal/w/wbxml2/libwbxml2-dev_0.11.8-1_amd64.deb
wget --no-check-certificate -qc https://packages.sogo.nu/nightly/5/ubuntu/pool/focal/w/wbxml2/libwbxml2-0_0.11.8-1_amd64.deb

dpkg -i libwbxml2-0_0.11.8-1_amd64.deb libwbxml2-dev_0.11.8-1_amd64.deb

# Install any missing packages
apt-get -f install -y

# Build section
# -------------

# Checkout the SOPE repository with the given tag
git clone --depth 1 --branch "${SOPE_GIT_TAG}" $REPOSITORY_SOPE
cd sope
cp -a packaging/debian debian
./debian/rules
dpkg-checkbuilddeps && dpkg-buildpackage

cd "$PACKAGES_DIR"

# Install the built packages
dpkg -i libsope*.deb

# Checkout the SOGo repository with the given tag
git clone --depth 1 --branch "${SOGO_GIT_TAG}" $REPOSITORY_SOGO
cd sogo
cp -a packaging/debian debian
dch --newversion "$VERSION_TO_BUILD" "Automated build for version $VERSION_TO_BUILD"
# cp packaging/debian-multiarch/control-no-openchange debian
./debian/rules
dpkg-checkbuilddeps && dpkg-buildpackage -b

cd "$PACKAGES_DIR"
dpkg-scanpackages . | gzip -9c > Packages.gz

# Clean section
# -------------

rm -rf ${PACKAGES_DIR}/sogo
rm -rf ${PACKAGES_DIR}/sope
