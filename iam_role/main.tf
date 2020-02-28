terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.1.0"
  }
}

resource "aws_iam_role" "role" {
  count = var.build_state ? 1 : 0

  assume_role_policy = var.assume_role_policy
  name_prefix        = "${var.name}-"
  path               = "/"
}

data "local_file" "policy_file" {
  filename = var.policy_file
}

data "template_file" "role_policy" {
  template = data.local_file.policy_file.content
  vars     = var.policy_vars
}

resource "aws_iam_role_policy" "role_policy" {
  count = var.build_state ? 1 : 0

  name   = "${var.name}Policy"
  policy = data.template_file.role_policy.rendered
  role   = aws_iam_role.role[0].id
}

resource "aws_iam_role_policy_attachment" "attach_managed_policy" {
  count = var.build_state ? length(var.policy_arns) : 0

  role       = aws_iam_role.role[0].name
  policy_arn = element(var.policy_arns, count.index)
}

