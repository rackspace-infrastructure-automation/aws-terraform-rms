provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

data "aws_canonical_user_id" "current" {}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//"

  vpc_name = "Test1VPC"
}

module "test_rms" {
  source = "../../module"

  Subnets                       = "${module.vpc.private_subnets}"
  VPCID                         = "${module.vpc.vpc_id}"
  CloudTrailLogBucket           = "${data.aws_canonical_user_id.current.display_name}-logs"
  AvailabilityZoneCount         = "2"
  VPCCIDR                       = "172.18.0.0/16"
  Environment                   = "Production"
  build_state                   = "Test"
  KeyName                       = "CircleCI"
  InstanceRoleManagedPolicyArns = ""
  ThreatManagerInstanceType     = "c4.large"
}
