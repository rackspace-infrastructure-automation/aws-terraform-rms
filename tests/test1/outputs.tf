output "rms_deployment_info" {
  value       = module.test_rms.deployment_details
  description = "Information about the RMS deployment"
}

output "rms_deployment_info_no_customer_id" {
  value       = module.test_rms_no_customer_id.deployment_details
  description = "RMS DR deployment information"
}

