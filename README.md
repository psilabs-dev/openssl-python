# Python OpenSSL

Docker image of Python with custom OpenSSL.

```sh
docker build -t ghcr.io/psilabs-dev/python-openssl:latest \
    --build-arg OPENSSL_VERSION=3.3.1 --build-arg PYTHON_VERSION=3.12.7 .
```
