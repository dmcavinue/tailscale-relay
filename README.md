### Tailscale Relay Example

This is ideally set up to run using the provided devcontainer in vscode.  The terraform used to provision AWS resources obviously is pretty static but kept simple for simplicities sake.

#### Setup

##### env vars
Copy and update the .env file.  You will need to set the environment name, AWS credentials/region.  You will also need a tailscale [account]((https://tailscale.com) and [apikey](https://tailscale.com/kb/1085/auth-keys) to allow the provisioned relay to automatically register with tailscale.
```
cp .env.example .env
```
This file is purposefully ignored by git for safety.

##### Build the custom tailscale-relay AMI
I use packer to provision a basic tailscale relay AMI image, which will act as our relay.  You can see the code for this [here](./packer/tailscale-relay.json.pkr.hcl) This packer image is based off the latest ubuntu 20.04 AMI and simply adds the tailscale repository and package to the image.
```
task packer:build
```
If everything worked, it should spin up an EC2 instance and provision a custom AMI in the target region.

##### Provision the infrastructure
```
task terraform:apply
```
This will run a `terraform init` followed by `terraform apply`.  In AWS, It will provision the following resources:
 
 - one VPC named after the environment with:
   - one public subnet with Elastic IP and Internet Gateway.
   - one private subnet with associated NAT Gateway set up to use the above IGW.
 - one tls key pair and AWS key pair (Used for all instances in the environment).
 - one tailscale-relay t2.nano EC2 instance set up it automatically register with tailscale and route the above private subnet.
 - one t2.micro instance within the private subnet to demonstrate the functional relay.

All instances within the private subnet leverage the NAT Gateway/IGW for external connectivity and have no public IPs defined.
the tailscale relays user_data script simply initializes the tailscale agent installed via the custom packer AMI and advertises all private subnet(s).

When you're done, simply run:
```
task terraform:destroy
```
**Note:** This will not delete your custom AMI packer images/snapshots so be sure to do that to prevent incurring charges for their storage.
