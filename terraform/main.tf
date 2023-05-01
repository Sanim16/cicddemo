terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  ##Used to create a remote backend in s3 so that the .tfstate file can
  ##be accessed by more than one person in a team setting

  ##The backend code block doesn't accept variables
  ##A backend block cannot refer to named values (like input variables, locals, or data source attributes).
  
  backend "s3" {
    key    = "terraform/remotestate" #Key to object in S3
    region = "us-east-1"
    bucket = "ms-tfstate-bucket"
  }

}

provider "aws" {
  region     = var.AWS_REGION
  #shared_credentials_file = "" #use secrets from github actions for login to Aws
}

resource "aws_instance" "web_server" {
  ami = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_name.key_name
  vpc_security_group_ids = [ aws_security_group.cicd-demo-sg.id ]
  # associate_public_ip_address = true
  subnet_id = aws_subnet.public-subnet-01.id
  iam_instance_profile = aws_iam_instance_profile.cicddemo_ecr_profile.name
  ebs_optimized = true

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = var.private_key
    timeout = "4m"
  }
  tags = {
    "Name" = "EC2 Web Server"
  }
}

resource "aws_key_pair" "key_name" {
  key_name = var.key_name  ##"terraformawskey"
  public_key = var.public_key  #use secrets from github actions
}

resource "aws_security_group" "cicd-demo-sg" {
  name        = "cicddemo-sg"
  description = "Allow SSH, HTTP & HTTPS inbound traffic"
  vpc_id = aws_vpc.cicddemo.id

  ingress = [ {
    cidr_blocks = [ "0.0.0.0/0" ] ##this should be your IP address for ssh
    description = "allow SSH from my IP"
    from_port = 22
    protocol = "tcp"
    self = false
    to_port = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
  },
  {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self = false
  },
  {
    description      = "HTTPS from everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self = false
  } ]

  egress {
    description = "egress to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cicddemo-sg"
  }
}

resource "aws_iam_instance_profile" "cicddemo_ecr_profile" {
    name = "cicddemo_ecr_profile"  
    #role = aws_iam_role.role.name
    role = "cicd_demo_policy_for_ecr"  #This is a preexisting role, another option is to create the role with terraform
}

# resource "aws_iam_role" "role" {
#   name = "test_role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ecr-public:*",
#                 "sts:GetServiceBearerToken"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
  #sensitive = true
}
