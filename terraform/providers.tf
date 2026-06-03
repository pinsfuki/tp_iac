terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.4.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
