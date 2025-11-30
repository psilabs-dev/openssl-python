#!/bin/bash
set -euo pipefail

# check for OPENSSL_VERSION and PYTHON_VERSION environment variables.
OPENSSL_VERSION=${OPENSSL_VERSION:?Environment variable OPENSSL_VERSION is required}
PYTHON_VERSION=${PYTHON_VERSION:?Environment variable PYTHON_VERSION is required}
TARGETPLATFORM=${TARGETPLATFORM:?Environment variable TARGETPLATFORM is required}
TARGETARCH=${TARGETARCH:?Environment variable TARGETARCH is required}

# set up common dependencies
apt-get update && apt-get install -y wget build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev

# remove system OpenSSL
apt-get remove -y libssl-dev openssl

# clean up work directory, install openssl
# move to clean work directory
cd / && \
    rm -rf /workdir && \
    mkdir -p /workdir && \
    cd /workdir

# unpack and move to openssl work directory
wget https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VERSION/openssl-$OPENSSL_VERSION.tar.gz && \
    tar zxvf openssl-$OPENSSL_VERSION.tar.gz && \
    cd /workdir/openssl-$OPENSSL_VERSION

# configure and install openssl
./Configure --prefix=/usr --openssldir=/etc/ssl shared
make
make install
if [ "$TARGETARCH" = "amd64" ]; then
    cp /usr/lib64/libssl.so*          /lib/x86_64-linux-gnu/
    cp /usr/lib64/libcrypto.so*       /lib/x86_64-linux-gnu/
elif [ "$TARGETARCH" = "arm64" ]; then
    cp /usr/lib/libssl.so*          /lib/aarch64-linux-gnu/
    cp /usr/lib/libcrypto.so*       /lib/aarch64-linux-gnu/
else
    echo "Unsupported architecture: $TARGETARCH."
    exit 1
fi
ldconfig

# return to root and reset work directory
cd / && \
    rm -rf /workdir && \
    mkdir -p /workdir && \
    cd /workdir

# unpack and move to python work directory
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz && \
    tar zxvf Python-$PYTHON_VERSION.tgz && \
    cd /workdir/Python-$PYTHON_VERSION

# configure and install python
mkdir -p build
if [ "$TARGETARCH" = "amd64" ]; then
    ./configure \
        --with-openssl=/usr \
        --with-openssl-rpath=/usr/lib64 \
        --prefix=/usr \
        --enable-optimizations
elif [ "$TARGETARCH" = "arm64"  ]; then
    ./configure \
        --with-openssl=/usr \
        --prefix=/usr \
        --enable-optimizations
else
    echo "Unsupported architecture: $TARGETARCH."
    exit 1
fi
make -j $(nproc)
make install
ln -sf /usr/bin/python3     /usr/bin/python
ln -sf /usr/bin/pip3        /usr/bin/pip

# go back to root and clean up everything
cd / && rm -rf /workdir && \
    apt-get remove --purge -y build-essential gdb lcov pkg-config && \
    apt-get autoremove -y && apt-get clean
