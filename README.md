# openssl-python

Custom selection of OpenSSL/Python images for debugging purposes and using Python with a custom SSL version.

## Buildx guide:

Build all available OpenSSL and Python versions.
```sh
docker buildx bake
```

Build test
```sh
docker build -t test-pixiv -f test.Dockerfile .
docker run -it --rm -e PIXIV_COOKIE=$PIXIV_COOKIE test-pixiv
```