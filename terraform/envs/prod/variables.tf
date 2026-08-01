variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type    = string
  default = "exam-devops"
}

variable "project" {
  type    = string
  default = "exam-devops"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.40.10.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}

variable "operator_cidrs" {
  type = list(string)
}

variable "jenkins_cidrs" {
  type = list(string)
}
