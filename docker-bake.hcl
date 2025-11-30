variable "IMAGE" {
  default = "openssl-python"
}

variable "PYTHON_VERSION" {
  default = "3.12.7"
}

variable "OPENSSL_VERSION" {
  default = "3.6.0"
}

target "ssl33" {
  tags = [
    "${IMAGE}:py${PYTHON_VERSION}-ssl3.3.5"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION}"
    OPENSSL_VERSION = "3.3.5"
  }
}

target "ssl34" {
  tags = [
    "${IMAGE}:py${PYTHON_VERSION}-ssl3.4.3"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION}"
    OPENSSL_VERSION = "3.4.3"
  }
}

target "ssl35" {
  tags = [
    "${IMAGE}:py${PYTHON_VERSION}-ssl3.5.4"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION}"
    OPENSSL_VERSION = "3.5.4"
  }
}

target "ssl36" {
  tags = [
    "${IMAGE}:py${PYTHON_VERSION}-ssl3.6.0"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION}"
    OPENSSL_VERSION = "3.6.0"
  }
}

target "py312-ssl33" {
  tags = [
    "${IMAGE}:py3.12.12-ssl3.3.5"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.12.12"
    OPENSSL_VERSION = "3.3.5"
  }
}

target "py312-ssl34" {
  tags = [
    "${IMAGE}:py3.12.12-ssl3.4.3"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.12.12"
    OPENSSL_VERSION = "3.4.3"
  }
}

target "py312-ssl35" {
  tags = [
    "${IMAGE}:py3.12.12-ssl3.5.4"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.12.12"
    OPENSSL_VERSION = "3.5.4"
  }
}

target "py312-ssl36" {
  tags = [
    "${IMAGE}:py3.12.12-ssl3.6.0"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.12.12"
    OPENSSL_VERSION = "3.6.0"
  }
}

target "py313-ssl33" {
  tags = [
    "${IMAGE}:py3.13.9-ssl3.3.5"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.13.9"
    OPENSSL_VERSION = "3.3.5"
  }
}

target "py313-ssl34" {
  tags = [
    "${IMAGE}:py3.13.9-ssl3.4.3"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.13.9"
    OPENSSL_VERSION = "3.4.3"
  }
}

target "py313-ssl35" {
  tags = [
    "${IMAGE}:py3.13.9-ssl3.5.4"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.13.9"
    OPENSSL_VERSION = "3.5.4"
  }
}

target "py313-ssl36" {
  tags = [
    "${IMAGE}:py3.13.9-ssl3.6.0"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.13.9"
    OPENSSL_VERSION = "3.6.0"
  }
}

target "py314-ssl33" {
  tags = [
    "${IMAGE}:py3.14.0-ssl3.3.5"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.14.0"
    OPENSSL_VERSION = "3.3.5"
  }
}

target "py314-ssl34" {
  tags = [
    "${IMAGE}:py3.14.0-ssl3.4.3"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.14.0"
    OPENSSL_VERSION = "3.4.3"
  }
}

target "py314-ssl35" {
  tags = [
    "${IMAGE}:py3.14.0-ssl3.5.4"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.14.0"
    OPENSSL_VERSION = "3.5.4"
  }
}

target "py314-ssl36" {
  tags = [
    "${IMAGE}:py3.14.0-ssl3.6.0"
  ]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    PYTHON_VERSION = "3.14.0"
    OPENSSL_VERSION = "3.6.0"
  }
}

group "default" {
  targets = [
    "py312-ssl33", "py312-ssl34", "py312-ssl35", "py312-ssl36",
    "py313-ssl33", "py313-ssl34", "py313-ssl35", "py313-ssl36",
    "py314-ssl33", "py314-ssl34", "py314-ssl35", "py314-ssl36"
  ]
}