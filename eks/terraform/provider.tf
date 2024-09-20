provider "aws" {}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

