provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

