
// lookup latest ubuntu image
data "aws_ami" "ubuntu_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

// provision some additional ec2 instance on the private subnet to
// demonstrate access via the tailscale relay
module "some-instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"  
  version                = "~> 2.0"

  name                   = "some-instance"
  instance_count         = 1
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ubuntu_image.id
  subnet_id              = module.vpc.private_subnets.0
  key_name               = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  monitoring             = false
  tags                   = {
    Name        = "some-instance"
    Environment = var.environment
    Terraform   = "true"
  }
}