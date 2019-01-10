output "arn" {
  description = "IAM role ARN"
  value       = "${element(concat(aws_iam_role.role.*.arn, list("")), 0)}"
}

output "id" {
  description = "IAM role id"
  value       = "${element(concat(aws_iam_role.role.*.id, list("")), 0)}"
}

output "name" {
  description = "IAM role name"
  value       = "${element(concat(aws_iam_role.role.*.name, list("")), 0)}"
}
