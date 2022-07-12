provider "aws" {
  version = "~> 2.0"
  region = "us-west-2"
  access_key = "AKIA2LUDM3WK4NG4MVLK"
  secret_key = "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"
}

  resource "aws_instance" "dev" {
      count = 1
      ami = "ami-0e8c04af2729ff1bb"
      instance_type = "t2.micro"
      key_name = "terraform-aws"
      tags = {
        Name = "dev${count.index}"
      }
  }

  
