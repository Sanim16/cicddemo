variable "AWS_REGION" {
    type = string
    default = "us-east-1"  
}

variable "key_name" {} #empty to prevent uploading secrets
variable "public_key" {} #public key used for key pair creation
variable "private_key" {} #public key used for key pair creation


variable "PROJECT_NAME" {
  type = string
  default = "cicddemo"
}
variable "VPC_CIDR" {
  default = "10.0.0.0/16"
}