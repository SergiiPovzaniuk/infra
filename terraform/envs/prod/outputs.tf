output "lb_public_ip" {
  description = "Single public IP for HTTP/HTTPS (NLB EIP)"
  value       = module.nlb.public_ip
}

output "lb_dns_name" {
  value = module.nlb.dns_name
}

output "app1_public_ip" {
  value = module.app1.public_ip
}

output "app2_public_ip" {
  value = module.app2.public_ip
}

output "app3_public_ip" {
  value = module.app3.public_ip
}

output "app1_public_dns" {
  value = module.app1.public_dns
}

output "ingress_url" {
  value = "http://${module.nlb.public_ip}/"
}
