output "id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = try(aws_eip.this[0].public_ip, aws_instance.this.public_ip)
}

output "public_dns" {
  value = aws_instance.this.public_dns
}
