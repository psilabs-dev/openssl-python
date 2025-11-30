FROM debian:bookworm

LABEL org.opencontainers.image.authors="psilabs-dev <https://github.com/psilabs-dev>"
LABEL org.opencontainers.image.source="https://github.com/psilabs-dev/openssl-python"

ARG OPENSSL_VERSION="3.3.1"
ARG PYTHON_VERSION="3.12.7"
ARG TARGETPLATFORM
ARG TARGETARCH

ENV OPENSSL_VERSION=${OPENSSL_VERSION}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV DEBIAN_FRONTEND=noninteractive

# Given these builds are for debugging only, there is really no reason to
# do any stage-based compression and forcing a single run for everything.

# dependencies
RUN apt-get update && apt-get install -y wget build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev

# uninstall system provided OpenSSL.
RUN apt-get remove -y libssl-dev openssl

# install openssl
WORKDIR /openssl-workdir
RUN wget https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar zxvf openssl-${OPENSSL_VERSION}.tar.gz && rm openssl-${OPENSSL_VERSION}.tar.gz
WORKDIR /openssl-workdir/openssl-${OPENSSL_VERSION}
RUN ./Configure --prefix=/usr --openssldir=/etc/ssl shared
RUN make
RUN make install

# copy files over to avoid not found errors.
RUN set -eux && \
    arch=$(uname -m) && \
    if [ "${arch}" = "aarch64" ]; then \
        cp /usr/lib/libssl.so*              /lib/aarch64-linux-gnu/ && \
        cp /usr/lib/libcrypto.so*           /lib/aarch64-linux-gnu/; \
    elif [ "${arch}" = "x86_64" ]; then \
        cp /usr/lib64/libssl.so*            /lib/x86_64-linux-gnu/ && \
        cp /usr/lib64/libcrypto.so*         /lib/x86_64-linux-gnu/; \
    else \
        echo "Unsupported architecture: ${arch}."; \
        exit 1; \
    fi

RUN ldconfig

# install python
WORKDIR /python-workdir
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
RUN tar zxvf Python-${PYTHON_VERSION}.tgz
WORKDIR /python-workdir/Python-${PYTHON_VERSION}

# Build Python (without optimizations and thus no tests run)
RUN set -eux && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        ./configure \
            --with-openssl=/usr\
            --with-openssl-rpath=/usr/lib64; \
    elif [ "${arch}" = "aarch64"  ]; then \
        ./configure \
            --with-openssl=/usr; \
    else \
        echo "Unsupported architecture: ${arch}."; \
        exit 1; \
    fi

# Build Python (with --enable-optimizations, which adds test time)
# RUN set -eux && \
#     arch=$(uname -m) && \
#     if [ "${arch}" = "x86_64" ]; then \
#         ./configure \
#             --with-openssl=/usr\
#             --with-openssl-rpath=/usr/lib64\
#             --enable-optimizations; \
#     elif [ "${arch}" = "aarch64"  ]; then \
#         ./configure \
#             --with-openssl=/usr \
#             --enable-optimizations; \
#     else \
#         echo "Unsupported architecture: ${arch}."; \
#         exit 1; \
#     fi
RUN make
RUN make install

# Protect custom Python/OpenSSL from being overwritten by future apt installs
RUN set -eux && \
    arch="$(uname -m)" && \
    if [ "${arch}" = "x86_64" ]; then \
        archdir="/usr/lib/x86_64-linux-gnu"; \
        libdir="/usr/lib64"; \
    elif [ "${arch}" = "aarch64" ]; then \
        archdir="/usr/lib/aarch64-linux-gnu"; \
        libdir="/usr/lib"; \
    else \
        echo "Unsupported architecture: ${arch}."; \
        exit 1; \
    fi && \
    dpkg-divert --local --add --no-rename /usr/bin/python3 && \
    ln -sf /usr/local/bin/python3 /usr/bin/python3 && \
    dpkg-divert --local --add --no-rename /usr/bin/openssl && \
    dpkg-divert --local --rename --add "${archdir}/libssl.so.3" && \
    ln -sf "${libdir}/libssl.so.3" "${archdir}/libssl.so.3" && \
    dpkg-divert --local --rename --add "${archdir}/libcrypto.so.3" && \
    ln -sf "${libdir}/libcrypto.so.3" "${archdir}/libcrypto.so.3" && \
    ldconfig

# verify that python uses the compiled OpenSSL.
CMD [ "python3", "-c", "import ssl; print(ssl.OPENSSL_VERSION)" ]