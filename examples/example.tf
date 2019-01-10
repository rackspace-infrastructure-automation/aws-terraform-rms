provider "aws" {
  version = "~> 1.2"
  region  = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.1"

  vpc_name = "Test1VPC"
}

module "vpc_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.1"

  providers = {
    aws = "aws.oregon"
  }

  vpc_name = "Test2VPC"
}

module "rms_main" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.1.3"

  # Required parameters
  name    = "Test-RMS"
  subnets = "${module.vpc.private_subnets}"

  alert_logic_customer_id = "123456789" # Required for first deployment in an account

  # Optional parameters
  # alert_logic_data_center = "US"
  # az_count      = "2"
  # build_state   = "Deploy"
  # environment   = "Production"
  # instance_type = "c5.large"
  # key_pair      = "titus-aws2"
  # tags = {}
  # volume_size = 50
}

module "rms_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.1.3"

  providers = {
    aws = "aws.oregon"
  }

  # Required parameters
  name    = "Test-RMS-DR"
  subnets = "${module.vpc_dr.private_subnets}"

  # alert_logic_customer_id = "" # Not required as this is second deployment in account

  # Optional parameters

  # alert_logic_data_center = "US"
  # az_count      = "2"
  # build_state   = "Deploy"
  # environment   = "Production"
  # instance_type = "c5.large"
  # key_pair      = "titus-aws2"
  # tags = {}
  # volume_size = 50
}
