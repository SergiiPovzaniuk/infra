data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "network" {
  source             = "../../modules/network"
  name               = var.project
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "k3s_security_group" {
  source = "../../modules/security-group"
  name   = "${var.project}-k3s"
  vpc_id = module.network.vpc_id
  ingress_rules = concat(
    [
      for cidr in var.operator_cidrs : {
        description = "Operator SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [cidr]
      }
    ],
    [
      for cidr in var.jenkins_cidrs : {
        description = "Jenkins SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [cidr]
      }
    ],
    [
      for cidr in var.jenkins_cidrs : {
        description = "Jenkins Kubernetes API"
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        cidr_blocks = [cidr]
      }
    ],
    [
      {
        description = "k3s internal TCP"
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        self        = true
      },
      {
        description = "k3s internal UDP"
        from_port   = 0
        to_port     = 65535
        protocol    = "udp"
        self        = true
      }
    ]
  )
}

module "edge_security_group" {
  source = "../../modules/security-group"
  name   = "${var.project}-edge"
  vpc_id = module.network.vpc_id
  ingress_rules = [
    {
      description = "Public HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Public HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "app1" {
  source               = "../../modules/ec2"
  name                 = "${var.project}-app-1"
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = module.network.public_subnet_id
  security_group_ids   = [module.k3s_security_group.id, module.edge_security_group.id]
  key_name             = var.key_name
  associate_elastic_ip = true
}

module "app2" {
  source             = "../../modules/ec2"
  name               = "${var.project}-app-2"
  ami                = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  subnet_id          = module.network.public_subnet_id
  security_group_ids = [module.k3s_security_group.id]
  key_name           = var.key_name
}

module "app3" {
  source             = "../../modules/ec2"
  name               = "${var.project}-app-3"
  ami                = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  subnet_id          = module.network.public_subnet_id
  security_group_ids = [module.k3s_security_group.id]
  key_name           = var.key_name
}
