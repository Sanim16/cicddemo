variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {}    #use secrets from github actions to prevent uploading secrets
variable "public_key" {}  #use secrets from github actions to prevent uploading secrets
variable "private_key" {} #use secrets from github actions to prevent uploading secrets


variable "PROJECT_NAME" {
  type    = string
  default = "cicddemo"
}
variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}