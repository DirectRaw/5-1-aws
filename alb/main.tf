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
    key    = "test/alb/terraform.tfstate"
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

data "terraform_remote_state" "ec2" {
  backend = "s3"
  config = {
    bucket = "raw-tf-state-backend"
    key    = "test/ec2/terraform.tfstate"
    region = "eu-west-3"
    profile        = "DEV"
  }
}

#ALB
resource "aws_lb" "alb" {
  name               = "raw-tf-${var.ENV}-${var.APP}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.sg.outputs.sg_id]
  subnets            = [for subnet in data.terraform_remote_state.net.outputs.public_subnet_ids: subnet]
  enable_deletion_protection = true

  tags = {
    "Name" = "raw-tf-${var.ENV}-${var.APP}-alb"
  }
}


#TG
resource "aws_alb_target_group" "webserver" {
  name     = "raw-tf-${var.ENV}-${var.APP}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.net.outputs.vpc_id
}

resource "aws_alb_listener" "frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }
}

resource "aws_alb_listener_rule" "rule1" {
  listener_arn = aws_alb_listener.frontend.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webserver.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

#ASG
resource "aws_launch_template" "launchtemplate1" {
  name = "raw-tf-${var.ENV}-${var.APP}-lt"

  image_id               = "ami-0004623a94ca549cd"
  instance_type          = var.INSTANCE_TYPE
  key_name               = "raw-tf-ssh-key-ec2-1"
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "raw-tf-${var.ENV}-${var.APP}-lt"
    }
  }

  #user_data = filebase64("${path.module}/ec2.userdata")
}

resource "aws_autoscaling_group" "asg" {
  #vpc_zone_identifier = [for subnet in data.terraform_remote_state.net.outputs.public_subnet_ids: subnet]
  vpc_zone_identifier = [data.terraform_remote_state.net.outputs.public_subnet_ids[0], data.terraform_remote_state.net.outputs.public_subnet_ids[1]]

  desired_capacity = 0
  max_size         = 0
  min_size         = 0

  target_group_arns = [aws_alb_target_group.webserver.arn]

  launch_template {
    id      = aws_launch_template.launchtemplate1.id
    version = "$Latest"
  }
}