provider "template" {
  version = "~> 1.0"
}

resource "aws_iam_role" "role" {
  count = "${var.build_state ? 1 : 0}"

  name_prefix        = "${var.name}-"
  path               = "/"
  assume_role_policy = "${var.assume_role_policy}"
}

data "template_file" "role_policy" {
  template = "${file("${var.policy_file}")}"
  vars     = "${var.policy_vars}"
}

resource "aws_iam_role_policy" "role_policy" {
  count = "${var.build_state ? 1 : 0}"

  name = "${var.name}Policy"
  role = "${aws_iam_role.role.id}"

  policy = "${data.template_file.role_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "attach_managed_policy" {
  count      = "${var.build_state ? length(var.policy_arns) : 0}"
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${element(var.policy_arns, count.index)}"
}
