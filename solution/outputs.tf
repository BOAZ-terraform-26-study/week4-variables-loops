output "subnet_ids" {
  value = { for k, s in aws_subnet.public : k => s.id }
}
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
