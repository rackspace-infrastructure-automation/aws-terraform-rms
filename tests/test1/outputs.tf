output "RMS_Deployment_Info" {
  value       = "${module.test_rms.deployment_details}"
  description = "Information about the RMS deployment"
}

output "RMS_Deployment_Info_No_Customer_ID" {
  value       = "${module.test_rms_no_customer_id.deployment_details}"
  description = "RMS DR deployment information"
}
