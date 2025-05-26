provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket  = "devops-task-tf-state-isb"
    key     = "project-name/env/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }
}
