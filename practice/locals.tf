locals {
  name_prefix = var.project_name
  # TODO(L1): common_tags 에 Project = var.project_name 을 merge 한 값
  # common_tags = merge(var.common_tags, { Project = var.project_name })
}
