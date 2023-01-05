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
    key    = "test/rds/terraform.tfstate"
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

data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket = "raw-tf-state-backend"
    key    = "test/sg/terraform.tfstate"
    region = "eu-west-3"
    profile        = "DEV"
  }
}


#RDS
resource "aws_db_instance" "rds" {
  identifier           = "raw-tf-${var.ENV}-${var.APP}-rds"
  allocated_storage    = 20
  max_allocated_storage = 100
  db_name              = "postgres"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t3.micro"
  username             = var.DBUSERNAME
  password             = var.DBPASS
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.raw-sub-gp.id
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.sg_id]
  availability_zone = "eu-west-3c"


  tags = {
    "Name" = "raw-tf-${var.ENV}-${var.APP}-rds"
  }
}

resource "aws_db_subnet_group" "raw-sub-gp" {
  name       = "raw-tf-${var.ENV}-${var.APP}-db-subnet-gp"
  subnet_ids = [data.terraform_remote_state.net.outputs.public_subnet_ids[2], data.terraform_remote_state.net.outputs.public_subnet_ids[1]]

  tags = {
    "Name" = "raw-tf-${var.ENV}-${var.APP}-db-subnet-gp"
  }
}

