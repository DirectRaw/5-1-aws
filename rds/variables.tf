variable "ENV" {
  type    = string
  default = "test"
}

variable "RES" {
  type    = string
  default = "sg"
}

variable "REGION" {
  type    = string
  default = "eu-west-3"
}

variable "INSTANCE_TYPE" {
  type    = string
  default = "t3.micro"
}

variable "NAME" {
  type    = string
  default = "web/raw-tf-ssh-key-ec2"
}

variable "DESCRIPTION" {
  type    = string
  default = "SSH key for task 3"
}

variable "COUNT_EC2" {
  type    = number
  default = 2
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

variable "DBUSERNAME" {
  type    = string
  default = "postgres"
}

variable "DBPASS" {
  type    = string
  default = "Qwerty12"
}