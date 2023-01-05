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
    key    = "test/net/terraform.tfstate"
    region = "eu-west-3"
    encrypt        = true
    profile        = "DEV"
  }
}

#DATA


data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_region" "current" {}


#VPC

resource "aws_vpc" "raw-tf-vpc" {
  cidr_block = var.VPC_CIDR
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_vpc"
  }
}

#INTERNET GATEWAY

resource "aws_internet_gateway" "raw_tf_igw" {
  vpc_id = aws_vpc.raw-tf-vpc.id
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_igw"
  }
}

#SUBNETS

resource "aws_subnet" "raw_tf_subnet" {
  count                   = length(var.SUBNET_CIDR)
  vpc_id                  = aws_vpc.raw-tf-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.SUBNET_CIDR[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_subnet_${count.index + 1}"
  }
}

#ROUTE TABLES

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.raw-tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.raw_tf_igw.id
  }

  depends_on = [
    aws_internet_gateway.raw_tf_igw
  ]
  tags = {
    "Name" = "raw_tf_${var.ENV}_${var.APP}_public_route"
  }
}

resource "aws_route_table_association" "pub_subnet_associate" {
  count          = length(aws_subnet.raw_tf_subnet[*].id)
  route_table_id = aws_route_table.public_route.id
  subnet_id      = element(aws_subnet.raw_tf_subnet[*].id, count.index)
}
