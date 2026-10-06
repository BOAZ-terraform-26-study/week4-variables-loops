# practice: week4 작업 폴더

여기가 오늘 손으로 치는 곳입니다. 막히면 `../solution/`을 보세요.

```
practice/
├── backend.tf      TODO ①      week3 버킷을 이어 씁니다. key 는 week04/app/...
├── variables.tf    TODO ②③④   subnets(map(object)) · my_ip 에 sensitive · primary_subnet_key
├── locals.tf       TODO ⑤⑥     name_prefix · merge 로 조립한 common_tags
├── network.tf      TODO ⑦⑧     subnet 과 association 을 for_each 로
├── outputs.tf      TODO ⑨⑩     for 표현식 맵 · sensitive output
├── compute.tf      읽기만       AMI · security group · EC2 1대
├── providers.tf    읽기만       default_tags = local.common_tags
├── versions.tf     읽기만       required_version >= 1.9.0
├── example.tfvars  복사해서 terraform.tfvars 로
└── count-demo/     무과금 샌드박스. AWS 자격증명이 필요 없습니다
```

## 순서

```bash
cp example.tfvars terraform.tfvars   # project_name · my_ip 채우기. 커밋 금지
# backend.tf 의 CHANGE-ME 두 곳을 week3 버킷/테이블 이름으로 (TODO ①)
terraform init                       # week3 버킷의 week04/app/ 키로 초기화됩니다
# TODO ②~⑩ 채우기
terraform fmt && terraform validate
terraform plan                       # Plan: 9 to add, 0 to change, 0 to destroy.
terraform apply                      # yes
terraform output                     # subnet_ids 맵 확인
terraform destroy                    # yes. 세션 끝에 반드시
```

`count-demo/`는 따로 돕니다. 여기서는 AWS에 아무것도 만들지 않습니다.

```bash
cd count-demo
terraform init && terraform apply    # yes
# main.tf 의 names 에서 "bravo" 를 지우고
terraform plan                       # count 쪽과 for_each 쪽의 차이를 봅니다
terraform destroy                    # yes
```

> [!CAUTION]
> EC2 1대가 켜져 있으면 퍼블릭 IPv4와 EBS까지 합쳐 시간당 $0.0190 입니다. 한 달 방치하면 약 $13.87 입니다.
> `for_each` 를 EC2 · NAT Gateway · Elastic IP 에 걸지 마세요. 요금이 항목 수만큼 곱해집니다.

자세한 절차는 [실습워크북](../lecture/실습워크북.md)에 있습니다.
