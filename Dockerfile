FROM debian:bookworm

ARG OPENSSL_VERSION="3.3.1"
ARG PYTHON_VERSION="3.12.7"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y wget build-essential gdb lcov pkg-config \
    libbz2-dev libffi-dev libgdbm-dev libgdbm-compat-dev liblzma-dev \
    libncurses5-dev libreadline6-dev libsqlite3-dev libssl-dev \
    lzma lzma-dev tk-dev uuid-dev zlib1g-dev

# install openssl
WORKDIR /workdir
RUN wget https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar zxvf openssl-${OPENSSL_VERSION}.tar.gz && rm openssl-${OPENSSL_VERSION}.tar.gz
WORKDIR /workdir/openssl-${OPENSSL_VERSION}
RUN ./Configure --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared
RUN make
RUN make install

# configure environment variable for python build
ENV LD_LIBRARY_PATH="/usr/local/ssl/lib"

# install python
WORKDIR /workdir
RUN wget --no-check-certificate https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
RUN tar zxvf Python-${PYTHON_VERSION}.tgz
WORKDIR /workdir/Python-${PYTHON_VERSION}
RUN set -x && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        ./configure --with-openssl=/usr/local/ssl --with-openssl-rpath=/usr/local/ssl/lib64 --enable-optimizations; \
    elif [ "${arch}" = "aarch64"  ]; then \
        ./configure --with-openssl=/usr/local/ssl --enable-optimizations; \
    else \
        echo "Unsupported architecture: ${arch}."; \
        exit 1; \
    fi
RUN ./configure --with-openssl=/usr/local/ssl --enable-optimizations
RUN make
RUN make install

# copy certificates
RUN cp -a /usr/lib/ssl/certs/* /usr/local/ssl/certs/

# clean up
WORKDIR /
RUN rm -rf /workdir

# verify that python uses the compiled OpenSSL.
CMD [ "python3", "-c", "import ssl; print(ssl.OPENSSL_VERSION)" ]
