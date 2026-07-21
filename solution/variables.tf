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
variable "subnet_cidrs" {
  type = map(string)
  default = {
    "ap-northeast-2a" = "10.0.1.0/24"
    "ap-northeast-2c" = "10.0.2.0/24"
  }
}
variable "common_tags" {
  type    = map(string)
  default = { Study = "boaz-terraform-26", Week = "4" }
}
