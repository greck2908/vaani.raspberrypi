#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -e

swigv="3.0.10"
pcrev="8.39"
cmakeva="3.6"
soxv="14.4.2"
nodev="v4.4.7"
cmakevb="0"
cmakev=$cmakeva.$cmakevb

cd /opt

# install the various packages and build tools we'll need
apt-get update
apt-get install python-dev autoconf automake libtool bison

# download and compile a recent version of swig.
# You can change the version number if there is a newer release
wget  http://prdownloads.sourceforge.net/swig/swig-$swigv.tar.gz
tar xf swig-$swigv.tar.gz
cd swig-$swigv/
wget  ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$pcrev.tar.gz
bash Tools/pcre-build.sh
./configure
make
make install
cd ..
rm -r swig-$swigv swig-$swigv.tar.gz

# download and compile a recent version of cmake
# You can change the version number if there is a newer release
wget --no-check-certificate https://cmake.org/files/v$cmakeva/cmake-$cmakev.tar.gz
tar xf cmake-$cmakev.tar.gz
cd cmake-$cmakev
./bootstrap
make
make install
cd ..
rm -r cmake-$cmakev cmake-$cmakev.tar.gz

# Get Mozilla's version of sphinxbase and build it
git clone https://github.com/mozilla/sphinxbase.git
cd sphinxbase
./autogen.sh
make
make install
cd ..

# Get Mozilla's version of pocketsphinx and build it
git clone https://github.com/mozilla/pocketsphinx.git
cd pocketsphinx
./autogen.sh
make
make install
cd ..

# We set pkg_config so that node-pocketsphinx can be built
export PKG_CONFIG_PATH=/opt/sphinxbase:/opt/pocketsphinx
export LD_LIBRARY_PATH=/usr/local/lib/

echo "/usr/local/lib/" >> /etc/ld.so.conf
ldconfig

# We then setup sox
wget --no-check-certificate https://sourceforge.net/projects/sox/files/sox/$soxv/sox-$soxv.tar.gz/download -O sox-$soxv.tar.gz
tar xf sox-$soxv.tar.gz
cd sox-$soxv
./configure
make -s
make install
cd ..
rm -rf sox-$soxv.tar.gz sox-$soxv

# Install a recent version of node and npm.
# See https://nodejs.org/en/download/ for latest stable i386 download link
wget --no-check-certificate https://nodejs.org/dist/$nodev/node-$nodev-linux-armv7l.tar.xz
tar xf node-$nodev-linux-armv7l.tar.xz
cd node-$nodev-linux-armv7l/
cp -R bin include lib share /usr/local/
cd ..
rm -r node-$nodev-linux-armv7l node-$nodev-linux-armv7l.tar.xz

# Install node bindings for cmake
npm install -g cmake-js
