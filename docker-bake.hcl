variable "VERSION" {
  # renovate: datasource=repology depName=alpine_3_21/unbound versioning=loose
  default = "1.22.0-r0"
}

group "default" {
  targets = ["default"]
}

target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["quay.io/seiferma/unbound:${VERSION}", "quay.io/seiferma/unbound:latest"]
  args = {
    VERSION = "${VERSION}"
  }
}
