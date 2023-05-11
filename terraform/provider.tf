terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  ## Used to create a remote backend in s3 so that the .tfstate file can
  ## Be accessed by more than one person in a team setting

  ## The backend code block doesn't accept variables
  ## A backend block cannot refer to named values (like input variables, locals, or data source attributes).

  backend "s3" {
    key    = "terraform/remotestate" #Key to object in S3
    region = "us-east-1"
    bucket = "ms-tfstate-bucket"
  }

}

provider "aws" {
  region = var.AWS_REGION
  #shared_credentials_file = "" #use secrets from github actions for login to Aws
}
