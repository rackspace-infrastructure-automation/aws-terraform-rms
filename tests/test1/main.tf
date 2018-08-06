provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//"

  vpc_name = "Test1VPC"
}

module "test_rms" {
  source = "../../module"

  Subnets                       = "${module.vpc.private_subnets}"
  AvailabilityZoneCount         = "2"
  Environment                   = "Production"
  build_state                   = "Test"
  KeyName                       = "CircleCI"
  InstanceRoleManagedPolicyArns = ""
  ThreatManagerInstanceType     = "c4.large"
}
