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

WORKDIR /
COPY src/openssl-python/docker-install.sh /install.sh
RUN set -eux && /bin/bash /install.sh && rm /install.sh

# verify that python uses the compiled OpenSSL.
CMD [ "python", "-c", "import ssl; print(ssl.OPENSSL_VERSION)" ]
