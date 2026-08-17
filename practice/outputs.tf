# ---------------------------------------------------------------------------
# outputs.tf: 리소스가 여러 개가 되면 output 도 값 하나로 끝나지 않습니다.
# for 표현식으로 맵을 만들어 한 덩어리로 냅니다.
#
# 실습워크북 B-3 을 따라 TODO ⑨⑩ 을 채우세요.
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.main.id
}

# TODO(B-3) ⑨: for 표현식으로 서브넷 ID 맵을 냅니다.
#
#   기본형:  { for k, v in <맵> : <새 key> => <새 value> }
#   aws_subnet.public 은 for_each 로 만들어졌으므로 그 자체가 맵입니다.
#   결과:    { "a" = "subnet-0abc...", "c" = "subnet-0def..." }
#
# output "subnet_ids" {
#   description = "for_each 로 만든 서브넷의 key 와 ID 맵"
#   value       = { for k, s in aws_subnet.public : k => s.id }
# }

# 값을 두 개 이상 묶고 싶으면 새 value 자리에 객체를 씁니다. 이건 채워 뒀습니다.
output "subnet_detail" {
  description = "서브넷 key 별 AZ 와 CIDR. plan 없이 배치를 확인할 때 씁니다"
  value = {
    for k, s in aws_subnet.public : k => {
      az   = s.availability_zone
      cidr = s.cidr_block
    }
  }
}

output "instance_id" {
  description = "EC2 인스턴스 ID (destroy 전에 기록해 두면 증빙이 된다)"
  value       = aws_instance.web.id
}

output "instance_subnet_key" {
  description = "EC2 가 실제로 놓인 서브넷 key. primary_subnet_key 와 같아야 합니다"
  value       = var.primary_subnet_key
}

output "instance_public_ip" {
  description = "자동 할당된 퍼블릭 IPv4. EIP가 아니므로 stop/start 시 바뀝니다. Discord에 올리지 마세요"
  value       = aws_instance.web.public_ip
}

# TODO(B-3) ⑩: sensitive 는 전염됩니다.
#
#   var.my_ip 에 sensitive = true 를 붙였으므로(③), 그 값을 조립한 이 output 에도
#   sensitive = true 가 있어야 합니다. 일부러 빼고 plan 을 한 번 돌려 보세요.
#   `Output refers to sensitive values` 오류가 나는 것을 확인한 뒤에 붙이세요.
#   값을 정말 봐야 하면 `terraform output -raw ssh_source_cidr` 로 꺼냅니다.
#
# output "ssh_source_cidr" {
#   description = "시큐리티 그룹이 22번을 열어준 대역. 본인 공인 IP 이므로 가려 둡니다"
#   value       = "${var.my_ip}/32"
#   sensitive   = true
# }
