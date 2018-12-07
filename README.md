# aws-terraform-rms

This module deploys the required infrastructure for an RMS managed Alert Logic deployment.  This includes Alert Logic Threat Manager appliances in each AZ of the VPC, and required IAM roles to allow for Alert Logic scanning inventory scanning and log ingestion.


## Basic Usage

```
module "rms_main" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.1.2"

 name    = "Test-RMS"
 subnets = "${module.vpc.private_subnets}"

 alert_logic_customer_id = "123456789"
}
```

Full working references are available at [examples](examples)


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alert_logic_customer_id | The Alert Logic Customer ID, provided by RMS. A numeric string between 3 and 12 characters in length. Omit if this is not the first RMS deployment under this account. | string | `` | no |
| alert_logic_data_center | Alert Logic Data Center where logs will be shipped. | string | `US` | no |
| az_count | Number of Availability Zones. For environments where only Log ingestion is required, please select 0 | string | `2` | no |
| build_state | Allowed values 'Deploy' or 'Test'.  Select 'Deploy' unless the stack is being built for testing in an account without access to the Alert Logic AMIs. | string | `Deploy` | no |
| environment | Application environment for which this infrastructure is being created. e.g. Development/Production. | string | `Production` | no |
| instance_type | The instance type to use for the Alert Logic appliances.  Defaults to c5.large | string | `c5.large` | no |
| key_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | string | `` | no |
| name | The name prefix to use for the resources created in this module. | string | - | yes |
| notification_topic | SNS Topic ARN to use for customer notifications from CloudWatch alarms. (OPTIONAL) | string | `` | no |
| rackspace_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `true` | no |
| subnets | Private Subnet IDs for deployment. This is for the ALTM appliances. | list | - | yes |
| tags | Custom tags to apply to all resources. | map | `<map>` | no |
| volume_size | Select EBS Volume Size in GB. | string | `50` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent_sg | SQS Name |
| appliance_ip | The private IP addresses of the Alert Logic appliances. |
| appliance_sg | The security group id applied to the Alert Logic appliances. |
| cross_account_role_arn | Logging IAM Role ARN |
| deployment_details | All details required to proceed with Alert Logic setup |
| logging_role_arn | Logging IAM Role ARN |
| sqs_queue_name | Name of the Alert Logic SQS queue |

