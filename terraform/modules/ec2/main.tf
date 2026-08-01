resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = { Name = var.name }
}

resource "aws_eip" "this" {
  count    = var.associate_elastic_ip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.this.id

  tags = { Name = "${var.name}-eip" }
}
