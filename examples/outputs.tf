output "RMS_Deployment_Info" {
  value       = "${module.rms_main.deployment_details}"
  description = "Information about the RMS deployment"
}

output "RMS_DR_Deployment_Info" {
  value       = "${module.rms_dr.deployment_details}"
  description = "RMS DR deployment information"
}
