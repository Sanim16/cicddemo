# variable "AWS_CREDENTIALS" {} #empty to prevent uploading secrets
# variable "VSCODE_PROFILE" {} #empty to prevent uploading secrets
variable "AWS_REGION" {
    type = string
    default = "us-east-1"  
}

variable "key_name" {} #empty to prevent uploading secrets
variable "public_key" {} #public key used for key pair creation
variable "private_key" {} #public key used for key pair creation
#variable "AWS_KEY" {}
#variable "AWS_SECRET_KEY" {}
variable "PROJECT_NAME" {
  type = string
  default = "cicddemo"
}
variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "MY_IP" {
  default = "0.0.0.0/0" #edit this to the ip address that needs ssh access. prefably your Ip address.
}