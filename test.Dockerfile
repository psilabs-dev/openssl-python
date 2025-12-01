FROM openssl-python:py3.12.7-ssl3.3.1

WORKDIR /workdir
RUN python3 -m pip install requests
COPY tests/test_pixiv_login.py /workdir/test_pixiv_login.py
CMD ["python3", "test_pixiv_login.py"]
