terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork?ref=v0.12.1"

  name = "RMS-Test-VPC"
}

module "test_rms" {
  source = "../../module"

  alert_logic_customer_id = "123456789"
  build_state             = "Test"
  name                    = "Test-RMS"
  subnets                 = module.vpc.private_subnets

  providers = {
    aws.rms_oregon = aws
  }
}

module "test_rms_no_customer_id" {
  source = "../../module"

  build_state = "Test"
  name        = "Test-RMS2"
  subnets     = module.vpc.private_subnets

  providers = {
    aws.rms_oregon = aws
  }
}

