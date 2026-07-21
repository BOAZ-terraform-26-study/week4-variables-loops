variable "region" {
  type    = string
  default = "ap-northeast-2"
}
variable "project_name" {
  type = string
}
variable "my_ip" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

# TODO(L1): subnet_cidrs 를 map(string) 으로 선언 (AZ -> CIDR)
# variable "subnet_cidrs" { ... }

variable "common_tags" {
  type    = map(string)
  default = { Study = "boaz-terraform-26", Week = "4" }
}
