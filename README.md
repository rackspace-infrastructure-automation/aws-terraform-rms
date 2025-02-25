> [!CAUTION]
> This project is end of life. This repo will be deleted on June 2nd 2025.

# aws-terraform-rms

This module deploys the required infrastructure for an RMS managed Alert Logic deployment.  This includes  
Alert Logic Threat Manager appliances in each AZ of the VPC, and required IAM roles to allow for Alert  
Logic scanning inventory scanning and log ingestion.

**NOTE:** You must supply a provider configured to use the us-west-2 region into this module in order  
to create several of the resources.  The dependancies for these resources only exist in us-west-2.

## Basic Usage

```HCL
module "rms_main" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.12.2"

  alert_logic_customer_id = "123456789"
  name                    = "Test-RMS"
  subnets                 = module.vpc.private_subnets

  providers = {
    aws.rms_oregon = aws.oregon
  }
}
```

Full working references are available at [examples](examples)

## Terraform 0.12 upgrade

There should be no changes required to move from previous versions of this module to version 0.12.0 or higher.

## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
- status\_check\_failed\_system\_alarm\_ticket
- status\_check\_failed\_instance\_alarm\_ticket
- status\_check\_failed\_instance\_alarm\_reboot
- status\_check\_failed\_system\_alarm\_recover

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |
| aws.rms\_oregon | >= 2.7.0 |
| local | n/a |
| null | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| cross_account_role | ./iam_role |  |
| instance_role | ./iam_role |  |
| logging_role | ./iam_role |  |
| status_check_failed_instance_alarm_ticket | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |
| status_check_failed_system_alarm_ticket | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6 |  |

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/caller_identity) |
| [aws_canonical_user_id](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/canonical_user_id) |
| [aws_cloudwatch_metric_alarm](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/cloudwatch_metric_alarm) |
| [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/iam_instance_profile) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/iam_policy) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/iam_policy_document) |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/instance) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/region) |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/security_group) |
| [aws_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/sns_topic_subscription) |
| [aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/sqs_queue) |
| [aws_sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/sqs_queue_policy) |
| [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/subnet) |
| [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/data-sources/vpc) |
| [local_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) |
| [null_data_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alert\_logic\_customer\_id | The Alert Logic Customer ID, provided by RMS. A numeric string between 3 and 12 characters in length. Omit if this is not the first RMS deployment under this account. | `string` | `""` | no |
| alert\_logic\_data\_center | Alert Logic Data Center where logs will be shipped. | `string` | `"US"` | no |
| az\_count | Number of Availability Zones. For environments where only Log ingestion is required, please select 0 | `number` | `2` | no |
| build\_state | Allowed values 'Deploy' or 'Test'.  Select 'Deploy' unless the stack is being built for testing in an account without access to the Alert Logic AMIs. | `string` | `"Deploy"` | no |
| cloudtrail\_bucket | The desired cloudtrail log bucket to monitor.  In most cases, the correct bucket will be determined via the canonical user id display name, but if a nonstand value is used, or a custom bucket name is needed, the full bucket name can be provided here. | `string` | `""` | no |
| environment | Application environment for which this infrastructure is being created. e.g. Development/Production. | `string` | `"Production"` | no |
| instance\_type | The instance type to use for the Alert Logic appliances.  Defaults to c5.large | `string` | `"c5.large"` | no |
| key\_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | `string` | `""` | no |
| name | The name prefix to use for the resources created in this module. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL) | `list(string)` | `[]` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| subnets | Private Subnet IDs for deployment. This is for the ALTM appliances. | `list(string)` | n/a | yes |
| tags | Custom tags to apply to all resources. | `map(string)` | `{}` | no |
| volume\_size | Select EBS Volume Size in GB. | `number` | `50` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent\_sg | The security group id to assign to client instances |
| appliance\_ip | The private IP addresses of the Alert Logic appliances. |
| appliance\_sg | The security group id applied to the Alert Logic appliances. |
| cross\_account\_role\_arn | Logging IAM Role ARN |
| deployment\_details | All details required to proceed with Alert Logic setup |
| logging\_role\_arn | Logging IAM Role ARN |
| managed\_instance\_policy\_arn | RMS Managed instance policy ARN |
| sqs\_queue\_name | Name of the Alert Logic SQS queue |
