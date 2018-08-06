resource "random_string" "AlertLogicExternalId" {
  length  = 25
  special = false
}

data "aws_canonical_user_id" "current" {}

data "aws_subnet" "selected" {
  id = "${element(var.Subnets, 0)}"
}

data "aws_vpc" "selected" {
  id = "${data.aws_subnet.selected.vpc_id}"
}

resource "aws_cloudformation_stack" "rms_stack" {
  name = "rms-stack"

  parameters {
    Subnets                       = "${join(",", var.Subnets)}"
    VPCID                         = "${data.aws_subnet.selected.vpc_id}"
    CloudTrailLogBucket           = "${data.aws_canonical_user_id.current.display_name}-logs"
    AvailabilityZoneCount         = "${var.AvailabilityZoneCount}"
    AlertLogicDataCenter          = "US"
    VPCCIDR                       = "${data.aws_vpc.selected.cidr_block}"
    ThreatManagerBuildState       = "${var.build_state}"
    ThreatManagerVolumeSize       = "50"
    Environment                   = "${var.environment}"
    KeyName                       = "${var.KeyName}"
    AlertLogicExternalId          = "${random_string.AlertLogicExternalId.result}"
    InstanceRoleManagedPolicyArns = "${var.InstanceRoleManagedPolicyArns}"
    ThreatManagerInstanceType     = "${var.ThreatManagerInstanceType}"
    DisableApiTermination         = "${var.DisableApiTermination}"
  }

  template_body = "${file("${path.module}/rms.template")}"
  capabilities  = ["CAPABILITY_IAM"]
}
