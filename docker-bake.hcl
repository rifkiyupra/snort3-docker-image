variable "image_name" {
  default = "snort-base"
}

variable "snort_version" {
  default = "3.3.4.0"
}

variable "libdaq_version" {
  default = "3.0.16"
}

variable "libdnet_version" {
  default = "1.18.0"
}

variable "hyperscan_version" {
  default = "5.4.2"
}

variable "image_repo_host" {
    default = "mfscy"
}

variable "image_tag" {
    //default = ["3", "3.3", "3.3.4", "3.3.4.0"]
    default = ["3.3.4.0"]
}

function "get_image_tag" {
  params = [image, tag, variant, version]
  result = notequal(tag, "latest") ? flatten([
        for itag in tag : concat(
            notequal(variant, "") ? ["${image_repo_host}/${image}:${itag}-${variant}"] : ["${image_repo_host}/${image}:${itag}"],
            notequal(version, "") ? ["${image_repo_host}/${image}:${itag}-${variant}-${version}"] : [],
        )
    ]) : ["${image_repo_host}/${image}:${tag}"]
}

group "default" {
  targets = [
    //"snort3-debian-12",
    "snort3-debian-12-6",
    //"snort3-alpine-3",
    // "snort3-alpine-3-20",
  ]
}

target "docker-metadata-action" {}

target "virtual-platforms" {
  platforms = [
    "linux/amd64",
    // "linux/386",
    "linux/arm64",
    // "linux/arm/v7",
    // "linux/ppc64le",
    // "linux/s390x",
  ]
}

target "virtual-debian" {
  dockerfile = "dockerfiles/debian.dockerfile"
}

target "virtual-alpine" {
  dockerfile = "dockerfiles/alpine.dockerfile"
}

target "snort3-default" {
  inherits = [
    "docker-metadata-action",
    "virtual-platforms",
  ]
  args = {
    SNORT_VERSION = snort_version
    LIBDAQ_VERSION = libdaq_version
    LIBDNET_VERSION = libdnet_version
    HYPERSCAN_VERSION = hyperscan_version
  }
}

target "snort3-debian" {
  inherits = [
    "snort3-default",
    "virtual-debian"
  ]
}

target "snort3-alpine" {
  inherits = [
    "snort3-default",
    "virtual-alpine"
  ]
}

target "snort3-debian-12" {
  inherits = [
    "snort3-debian"
  ]
  args = {
    DEBIAN_VERSION = "12-slim"
  }
  tags = concat(
    // get_image_tag(image_name, "latest", "", ""),
    get_image_tag(image_name, image_tag, "", "")
  )
}

target "snort3-debian-12-6" {
  inherits = [
    "snort3-debian"
  ]
  args = {
    DEBIAN_VERSION = "12.6-slim"
  }
  tags = get_image_tag(image_name, image_tag, "debian", "12.6")
}

target "snort3-alpine-3" {
  inherits = [
    "snort3-alpine"
  ]
  args = {
    ALPINE_VERSION = "3"
  }
  tags = get_image_tag(image_name, image_tag, "alpine", "3")
}

target "snort3-alpine-3-20" {
  inherits = [
    "snort3-alpine"
  ]
  args = {
    ALPINE_VERSION = "3.20"
  }
  tags = get_image_tag(image_name, image_tag, "alpine", "3.20")
}
