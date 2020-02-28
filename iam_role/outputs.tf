output "arn" {
  description = "IAM role ARN"
  value       = element(concat(aws_iam_role.role.*.arn, [""]), 0)
}

output "id" {
  description = "IAM role id"
  value       = element(concat(aws_iam_role.role.*.id, [""]), 0)
}

output "name" {
  description = "IAM role name"
  value       = element(concat(aws_iam_role.role.*.name, [""]), 0)
}

