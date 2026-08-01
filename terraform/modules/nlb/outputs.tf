output "public_ip" {
  value = aws_eip.this.public_ip
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

output "arn" {
  value = aws_lb.this.arn
}
