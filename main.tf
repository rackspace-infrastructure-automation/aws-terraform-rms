provider "aws" {
  region = "us-west-2"
  alias  = "rms_oregon"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current" {}

data "aws_subnet" "selected" {
  id = "${element(var.subnets, 0)}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

locals {
  iam_build = "${var.alert_logic_customer_id != "" ? 1 : 0}"

  tags = {
    Name                            = "${var.name}"
    ServiceProvider                 = "Rackspace"
    Environment                     = "${var.environment}"
    ProductGroup                    = "RMS"
    ProductVendor                   = "AlertLogic"
    "rackspace:automation:ssmaudit" = "False"
  }

  rs_alarm_topic       = "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rackspace-support-emergency"
  cloudtrail_sns_topic = "arn:aws:sns:us-west-2:${data.aws_caller_identity.current.account_id}:rackspace-trail"

  alert_logic_details = {
    US = {
      log_principal = "arn:aws:iam::239734009475:root"
      tm_principal  = "arn:aws:iam::733251395267:root"
    }

    EU = {
      log_principal = "arn:aws:iam::239734009475:root"
      tm_principal  = "arn:aws:iam::857795874556:root"
    }
  }

  altm_image = {
    Deploy = {
      "ap-northeast-1" = "ami-f07e3896"
      "ap-northeast-2" = "ami-e768c589"
      "ap-south-1"     = "ami-944916fb"
      "ap-southeast-1" = "ami-1c1e5560"
      "ap-southeast-2" = "ami-3edd1b5c"
      "ca-central-1"   = "ami-6d880f09"
      "eu-central-1"   = "ami-aa92ffc5"
      "eu-west-1"      = "ami-c57336bc"
      "eu-west-2"      = "ami-c66480a1"
      "eu-west-3"      = "ami-2d66d050"
      "sa-east-1"      = "ami-72115a1e"
      "us-east-1"      = "ami-5934df24"
      "us-east-2"      = "ami-e5fdca80"
      "us-west-1"      = "ami-87e6ede7"
      "us-west-2"      = "ami-5b9e1623"
    }

    Test = {
      "ap-northeast-1" = "ami-9c9443e3"
      "ap-northeast-2" = "ami-ebc47185"
      "ap-south-1"     = "ami-5a8da735"
      "ap-southeast-1" = "ami-ed838091"
      "ap-southeast-2" = "ami-33f92051"
      "ca-central-1"   = "ami-03e86a67"
      "eu-central-1"   = "ami-a058674b"
      "eu-west-1"      = "ami-e4515e0e"
      "eu-west-2"      = "ami-b2b55cd5"
      "eu-west-3"      = "ami-d50bbaa8"
      "sa-east-1"      = "ami-83d58fef"
      "us-east-1"      = "ami-cfe4b2b0"
      "us-east-2"      = "ami-40142d25"
      "us-west-1"      = "ami-0e86606d"
      "us-west-2"      = "ami-0ad99772"
    }
  }

  alert_logic_ips = {
    US = ["204.110.218.96/27", "204.110.219.96/27", "208.71.209.32/27"]
    EU = ["185.54.124.0/24"]
  }

  dns_ips = ["8.8.4.4/32", "8.8.8.8/32"]
}

resource "aws_sqs_queue" "altm_queue" {
  count = "${local.iam_build}"

  name_prefix = "${var.name}-"

  tags = "${merge(
    local.tags,
    var.tags,
    map("Name", "${var.name}-SQSqueue"),
  )}"
}

resource "aws_sqs_queue_policy" "altm_queue_policy" {
  count = "${local.iam_build}"

  queue_url = "${aws_sqs_queue.altm_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sqs:SendMessage",
      "Effect": "Allow",
      "Resource": [ "${aws_sqs_queue.altm_queue.arn}"],
      "Principal": {"AWS": "*"},
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${local.cloudtrail_sns_topic}"
        }
      }
    }
  ]
}
POLICY
}

# SNS Subscription must be created in us-west-2, so use "aws.rms_oregon" provider
resource "aws_sns_topic_subscription" "altm_sns_subscription" {
  count    = "${local.iam_build}"
  provider = "aws.rms_oregon"

  topic_arn = "${local.cloudtrail_sns_topic}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.altm_queue.arn}"
}

data "aws_iam_policy_document" "cross_account_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${lookup(local.alert_logic_details[var.alert_logic_data_center], "tm_principal")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.alert_logic_customer_id}"]
    }
  }
}

module "cross_account_role" {
  source = "./iam_role"

  name               = "${var.name}-CrossAccountRole"
  build_state        = "${local.iam_build}"
  assume_role_policy = "${data.aws_iam_policy_document.cross_account_assume_role_policy.json}"
  policy_file        = "${"${path.module}/iam_policies/cross_account_role_policy.json"}"

  policy_vars = {
    cloudtrail_sns_topic = "${local.cloudtrail_sns_topic}"
  }
}

data "aws_iam_policy_document" "logging_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${lookup(local.alert_logic_details[var.alert_logic_data_center], "log_principal")}"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.alert_logic_customer_id}"]
    }
  }
}

module "logging_role" {
  source = "./iam_role"

  name               = "${var.name}-LoggingRole"
  build_state        = "${local.iam_build}"
  assume_role_policy = "${data.aws_iam_policy_document.logging_assume_role_policy.json}"
  policy_file        = "${"${path.module}/iam_policies/logging_role_policy.json"}"

  policy_vars = {
    cloudtrail_bucket = "${data.aws_canonical_user_id.current.display_name}-logs"
    sqs_queue_arn     = "arn:aws:sqs:us-west-2:794790922771:rms-stack-ALSQSQueue-130WSCL28TCBR"
  }
}

resource "aws_security_group" "appliance_sg" {
  name        = "${var.name}-ApplianceSecurityGroup"
  description = "Enable In-Out access for Alert Logic Threat Management Services."
  vpc_id      = "${data.aws_subnet.selected.vpc_id}"

  ingress {
    from_port   = 7777
    to_port     = 7777
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${local.alert_logic_ips[var.alert_logic_data_center]}"
  }

  egress {
    from_port   = 4138
    to_port     = 4138
    protocol    = "tcp"
    cidr_blocks = "${local.alert_logic_ips[var.alert_logic_data_center]}"
  }

  egress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = "${local.alert_logic_ips[var.alert_logic_data_center]}"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = "${local.dns_ips}"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = "${local.dns_ips}"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    local.tags,
    var.tags,
    map("Name", "${var.name}-ApplianceSecurityGroup"),
  )}"
}

resource "aws_security_group" "agent_sg" {
  name        = "${var.name}-AgentSecurityGroup"
  description = "Enable Out access to Alert Logic Threat Management Device."
  vpc_id      = "${data.aws_subnet.selected.vpc_id}"

  egress {
    from_port       = 7777
    to_port         = 7777
    protocol        = "tcp"
    security_groups = ["${aws_security_group.appliance_sg.id}"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    local.tags,
    var.tags,
    map("Name", "${var.name}-AgentSecurityGroup"),
  )}"
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "instance_role" {
  source = "./iam_role"

  name               = "${var.name}-InstanceRole"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
  policy_file        = "${"${path.module}/iam_policies/appliance_role_policy.json"}"
  policy_vars        = {}
  policy_arns        = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "${var.name}-InstanceRole-"
  role        = "${module.instance_role.name}"
  path        = "/"
}

resource "aws_instance" "threat_manager" {
  count                  = "${var.az_count}"
  ami                    = "${lookup(local.altm_image[var.build_state], data.aws_region.current.name)}"
  subnet_id              = "${element(var.subnets, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.appliance_sg.id}"]
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_pair}"
  monitoring             = true
  iam_instance_profile   = "${aws_iam_instance_profile.instance_profile.name}"

  tags = "${merge(
    local.tags,
    var.tags,
    map("Name", "${var.name}-ThreatManager-${format("%01d",count.index+1)}"),
  )}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.volume_size}"
    delete_on_termination = true
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_system_alarm_ticket" {
  count               = "${var.az_count}"
  alarm_name          = "${join("-", list(var.name, "SystemRecoveryNotification", format("%01d",count.index+1)))}"
  alarm_description   = "Status checks have failed for system, generating ticket."
  namespace           = "AWS/EC2"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  unit                = "Count"
  evaluation_periods  = "10"
  period              = "60"
  metric_name         = "StatusCheckFailed_System"
  alarm_actions       = ["${local.rs_alarm_topic}"]
  ok_actions          = ["${local.rs_alarm_topic}"]

  dimensions {
    InstanceId = "${element(aws_instance.threat_manager.*.id, count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_instance_alarm_ticket" {
  count               = "${var.az_count}"
  alarm_name          = "${join("-", list(var.name, "InstanceRecoveryNotification", format("%01d",count.index+1)))}"
  alarm_description   = "Status checks have failed for instance, generating ticket."
  namespace           = "AWS/EC2"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  unit                = "Count"
  evaluation_periods  = "10"
  period              = "60"
  metric_name         = "StatusCheckFailed_Instance"
  ok_actions          = ["${local.rs_alarm_topic}"]
  alarm_actions       = ["${local.rs_alarm_topic}"]

  dimensions {
    InstanceId = "${element(aws_instance.threat_manager.*.id, count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_instance_alarm_reboot" {
  count               = "${var.az_count}"
  alarm_name          = "${join("-", list(var.name, "InstanceRecoveryAlarm", format("%01d",count.index+1)))}"
  alarm_description   = "Status checks have failed for instance, rebooting system."
  namespace           = "AWS/EC2"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  unit                = "Count"
  evaluation_periods  = "5"
  period              = "60"
  metric_name         = "StatusCheckFailed_Instance"
  alarm_actions       = ["arn:aws:swf:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"]

  dimensions {
    InstanceId = "${element(aws_instance.threat_manager.*.id, count.index)}"
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_system_alarm_recover" {
  count               = "${var.az_count}"
  alarm_name          = "${join("-", list(var.name, "SystemRecoveryAlarm", format("%01d",count.index+1)))}"
  alarm_description   = "Status checks have failed for system, recovering instance"
  namespace           = "AWS/EC2"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  unit                = "Count"
  evaluation_periods  = "2"
  period              = "60"
  metric_name         = "StatusCheckFailed_System"
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

  dimensions {
    InstanceId = "${element(aws_instance.threat_manager.*.id, count.index)}"
  }
}
