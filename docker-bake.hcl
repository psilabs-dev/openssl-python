variable "IMAGE" {
  default = "openssl-python"
}

variable "PYTHON_VERSION" {
  default = "3.12.7"
}

variable "OPENSSL_VERSION" {
  default = "3.6.0"
}

target "default" {
  tags = [
    "${IMAGE}:py${PYTHON_VERSION}-ssl${OPENSSL_VERSION}"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION}"
    OPENSSL_VERSION = "${OPENSSL_VERSION}"
  }
}