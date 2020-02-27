# aws-terraform-rms

This module deploys the required infrastructure for an RMS managed Alert Logic deployment.  This includes  
Alert Logic Threat Manager appliances in each AZ of the VPC, and required IAM roles to allow for Alert  
Logic scanning inventory scanning and log ingestion.

**NOTE:** You must supply a provider configured to use the us-west-2 region into this module in order  
to create several of the resources.  The dependancies for these resources only exist in us-west-2.

## Basic Usage

```HCL
module "rms_main" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.1.7"

  alert_logic_customer_id = "123456789"
  name                    = "Test-RMS"
  subnets                 = "${module.vpc.private_subnets}"

  providers = {
    aws.rms_oregon = "aws.oregon"
  }
}
```

Full working references are available at [examples](examples)
## Other TF Modules Used  
Using [aws-terraform-cloudwatch\_alarm](https://github.com/rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm) to create the following CloudWatch Alarms:
- status\_check\_failed\_system\_alarm\_ticket
- status\_check\_failed\_instance\_alarm\_ticket
- status\_check\_failed\_instance\_alarm\_reboot
- status\_check\_failed\_system\_alarm\_recover

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| aws.rms\_oregon | n/a |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| alert\_logic\_customer\_id | The Alert Logic Customer ID, provided by RMS. A numeric string between 3 and 12 characters in length. Omit if this is not the first RMS deployment under this account. | `string` | `""` | no |
| alert\_logic\_data\_center | Alert Logic Data Center where logs will be shipped. | `string` | `"US"` | no |
| az\_count | Number of Availability Zones. For environments where only Log ingestion is required, please select 0 | `string` | `2` | no |
| build\_state | Allowed values 'Deploy' or 'Test'.  Select 'Deploy' unless the stack is being built for testing in an account without access to the Alert Logic AMIs. | `string` | `"Deploy"` | no |
| cloudtrail\_bucket | The desired cloudtrail log bucket to monitor.  In most cases, the correct bucket will be determined via the canonical user id display name, but if a nonstand value is used, or a custom bucket name is needed, the full bucket name can be provided here. | `string` | `""` | no |
| environment | Application environment for which this infrastructure is being created. e.g. Development/Production. | `string` | `"Production"` | no |
| instance\_type | The instance type to use for the Alert Logic appliances.  Defaults to c5.large | `string` | `"c5.large"` | no |
| key\_pair | Name of an existing EC2 KeyPair to enable SSH access to the instances. | `string` | `""` | no |
| name | The name prefix to use for the resources created in this module. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications from CloudWatch alarms. (OPTIONAL) | `list` | `[]` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `string` | `true` | no |
| subnets | Private Subnet IDs for deployment. This is for the ALTM appliances. | `list` | n/a | yes |
| tags | Custom tags to apply to all resources. | `map` | `{}` | no |
| volume\_size | Select EBS Volume Size in GB. | `string` | `"50"` | no |

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

