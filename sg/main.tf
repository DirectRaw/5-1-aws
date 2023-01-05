provider "aws" {
  region = var.REGION
  profile = "DEV"
  default_tags {
    tags = {
      "Env"        = var.ENV
      "Team"       = var.TEAM
      "Managet By" = var.CREATED
      "Owner"      = var.OWNER
      "CostCenter" = "${var.ENV}_${var.COST}"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "raw-tf-state-backend"
    key    = "test/sg/terraform.tfstate"
    region = "eu-west-3"
    encrypt        = true
    profile        = "DEV"
  }
}

#DATA

data "terraform_remote_state" "net" {
  backend = "s3"
  config = {
    bucket = "raw-tf-state-backend"
    key    = "test/net/terraform.tfstate"
    region = "eu-west-3"
    profile        = "DEV"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_region" "current" {}

#SECURITY GROUP

resource "aws_security_group" "raw_tf_sg" {
  name        = "raw_tf_${var.ENV}_${var.APP}_sg"
  description = "Security Group for web_app generate by Terraform"
  vpc_id      = data.terraform_remote_state.net.outputs.vpc_id

  ingress {
    description = "Allow all to port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["82.200.165.82/32"]
  }

  ingress {
    description = "Allow all to port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["82.200.165.82/32"]
  }

  ingress {
    description = "Allow all to port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.200.165.82/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  }

  dynamic "ingress" {
    for_each = ["80", "22", "5432"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["10.10.20.0/23"]
    }
  }
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_sg"
  }
}
