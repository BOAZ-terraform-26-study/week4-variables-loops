# TODO(L1): subnet_ids 를 for 표현식으로 맵 출력
# output "subnet_ids" {
#   value = { for k, s in aws_subnet.public : k => s.id }
# }
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
