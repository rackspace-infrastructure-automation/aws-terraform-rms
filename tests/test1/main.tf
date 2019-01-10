provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=master"

  vpc_name = "RMS-Test-VPC"
}

module "test_rms" {
  source = "../../module"

  # Required parameters
  name                    = "Test-RMS"
  subnets                 = "${module.vpc.private_subnets}"
  alert_logic_customer_id = "123456789"
  build_state             = "Test"
}

module "test_rms_no_customer_id" {
  source = "../../module"

  # Required parameters
  name        = "Test-RMS2"
  subnets     = "${module.vpc.private_subnets}"
  build_state = "Test"
}
