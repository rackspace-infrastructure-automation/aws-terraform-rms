# SQS Name
output "agent_sg" {
  description = "The security group id to assign to client instances"
  value       = "${aws_security_group.agent_sg.id}"
}

output "appliance_ip" {
  description = "The private IP addresses of the Alert Logic appliances."
  value       = "${aws_instance.threat_manager.*.private_ip}"
}

output "appliance_sg" {
  description = "The security group id applied to the Alert Logic appliances."
  value       = "${aws_security_group.appliance_sg.id}"
}

output "cross_account_role_arn" {
  description = "Logging IAM Role ARN"
  value       = "${module.cross_account_role.arn}"
}

output "deployment_details" {
  description = "All details required to proceed with Alert Logic setup"

  value = {
    "Alert Logic Customer ID" = "${var.alert_logic_customer_id}"
    "Cross Account Role ARN"  = "${module.cross_account_role.arn}"
    "Logging Role ARN"        = "${module.logging_role.arn}"
    "Threat Manager IPs"      = "${join(", ", aws_instance.threat_manager.*.private_ip)}"
    "SQS Queue Name"          = "${join(", ", aws_sqs_queue.altm_queue.*.name)}"
  }
}

output "logging_role_arn" {
  description = "Logging IAM Role ARN"
  value       = "${module.logging_role.arn}"
}

output "sqs_queue_name" {
  description = "Name of the Alert Logic SQS queue"
  value       = "${aws_sqs_queue.altm_queue.*.name}"
}
