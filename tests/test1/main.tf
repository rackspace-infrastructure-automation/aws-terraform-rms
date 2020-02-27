provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.0.10"

  vpc_name = "RMS-Test-VPC"
}

module "test_rms" {
  source = "../../module"

  alert_logic_customer_id = "123456789"
  build_state             = "Test"
  name                    = "Test-RMS"
  subnets                 = "${module.vpc.private_subnets}"
}

module "test_rms_no_customer_id" {
  source = "../../module"

  build_state = "Test"
  name        = "Test-RMS2"
  subnets     = "${module.vpc.private_subnets}"
}
