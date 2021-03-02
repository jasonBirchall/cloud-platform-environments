
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pingdom = {
      source = "registry.terraform.io/-/pingdom"
      version = "1.1.3"
    }
  }
}
