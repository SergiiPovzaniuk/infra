variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "targets" {
  type        = map(string)
  description = "Static map of name => instance_id for target attachments"
}
