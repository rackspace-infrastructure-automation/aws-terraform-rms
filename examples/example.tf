terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.2"
  region  = "us-east-1"
}

provider "aws" {
  version = "~> 2.2"
  region  = "us-west-2"
  alias   = "oregon"
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.1"

  name = "Test1VPC"
}

module "vpc_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.12.1"

  name = "Test2VPC"

  providers = {
    aws = aws.oregon
  }
}

module "rms_main" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.12.0"

  # alert_logic_customer_id required for first deployment in an account
  alert_logic_customer_id = "123456789"
  name                    = "Test-RMS"
  subnets                 = module.vpc.private_subnets

  # Optional parameters

  # alert_logic_data_center = "US"
  # az_count                = "2"
  # build_state             = "Deploy"
  # environment             = "Production"
  # instance_type           = "c5.large"
  # key_pair                = "my-key-pair"
  # tags                    = {}
  # volume_size             = 50

  providers = {
    aws.rms_oregon = aws.oregon
  }
}

module "rms_dr" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-rms//?ref=v0.12.0"

  # Required parameters
  name    = "Test-RMS-DR"
  subnets = module.vpc_dr.private_subnets

  # alert_logic_customer_id omitted on secondary deployments in an account

  # Optional parameters

  # alert_logic_data_center = "US"
  # az_count                = "2"
  # build_state             = "Deploy"
  # environment             = "Production"
  # instance_type           = "c5.large"
  # key_pair                = "my-key-pair"
  # tags                    = {}
  # volume_size             = 50

  providers = {
    aws            = aws.oregon
    aws.rms_oregon = aws.oregon
  }
}

