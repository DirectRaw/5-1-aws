variable "ENV" {
  type    = string
  default = "test"
}

variable "RES" {
  type    = string
  default = "alb"
}

variable "REGION" {
  type    = string
  default = "eu-west-3"
}

variable "APP" {
  type    = string
  default = "web-app"
}

variable "TEAM" {
  type    = string
  default = "devops"
}

variable "CREATED" {
  type    = string
  default = "by Terraform"
}

variable "OWNER" {
  type    = string
  default = "Ravil Nagmetov"
}

variable "COST" {
  type    = string
  default = "Test COST center"
}

variable "INSTANCE_TYPE" {
  type    = string
  default = "t3.micro"
}