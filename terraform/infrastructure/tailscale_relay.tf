
locals {
  aws_cidr            = "10.0.0.0/16"
  aws_azs             = ["us-east-2a"]
  aws_public_subnets  = ["10.0.1.0/24"]
  aws_private_subnets = ["10.0.2.0/24"]
}

// ssh keys used to auth against environments provisioned instances
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// spin up a new VPC for our environment
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3.0"

  name                   = var.environment
  cidr                   = local.aws_cidr
  azs                    = local.aws_azs
  public_subnets         = local.aws_public_subnets
  private_subnets        = local.aws_private_subnets
  create_igw             = true  // create our IGW
  enable_nat_gateway     = true  // create our NAT-GW
  single_nat_gateway     = true  // shared NAT gateway private subnet(s)
  one_nat_gateway_per_az = false // shared NAT gateway for all AZs
  enable_dns_support     = true  // enable dns support within our subnets
  enable_dns_hostnames   = true  // enable dns hostnames within our subnets

  // some tags to associate with our resources
  tags = {
    terraform   = "true"
    environment = var.environment
  }
}

// Generate a new key pair for each service
module "key_pair" {
  source          = "terraform-aws-modules/key-pair/aws"
  version         = "1.0.0"
  key_name        = var.environment
  public_key      = tls_private_key.ssh_key.public_key_openssh
  create_key_pair = true
  tags = {
    terraform   = "true"
    environment = var.environment
  }
}

// lookup latest custom AMI tailscale-relay image
data "aws_ami" "tailscale_image" {
  most_recent = true
  filter {
    name   = "tag:role"
    values = ["tailscale-relay"]
  }
  owners = ["self"]
}

// tailscale startup script template
// we inject the tailscale apikey and 
// list of private subnets here
data "template_file" "user_data" {
  template = file("./startup_scripts/tailscale-relay.sh.tmpl")
  vars     = {
    // pass the tailscale authkey to auto-register
    // with tailscale
    "TAILSCALE_AUTHKEY" = var.tailscale_authkey
    // pass a list of all private subnets to 
    // the instance to setup subnet routing
    "PRIVATE_SUBNETS"   = join(",", local.aws_private_subnets)
  }
}

// deploy our tailscale-relay instance
module "tailscale-relay" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  
  version                = "~> 2.0"

  name                   = "tailscale-relay"
  instance_count         = 1
  instance_type          = "t2.nano"
  ami                    = data.aws_ami.tailscale_image.id
  subnet_id              = module.vpc.private_subnets.0
  key_name               = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  user_data_base64       = base64encode(data.template_file.user_data.rendered)
  monitoring             = false
  tags                   = {
    Name        = "tailscale-relay"
    Environment = var.environment
    Terraform   = "true"
  }
}
