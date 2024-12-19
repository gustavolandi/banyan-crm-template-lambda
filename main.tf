terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
  default_tags {
    tags = {
      owner       = "Gustavo Landi"
      managed-by  = "terraform"
      project     = "crm"
      application = var.lambda_name
    }
  }
}

data "terraform_remote_state" "bucket_pipeline" {
  backend = "s3"
  config = {
    bucket = "landigu-tf-remote-state"
    key    = "banyan-crm/buckets-pipelines/terraform.tfstate"
    region = "sa-east-1"
  }
}

