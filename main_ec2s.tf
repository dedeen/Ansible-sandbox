#  Terraform to create end user EC2s 

#  First EC2 in VPC=secvpc, subnet=sec-az1-mgmt, vars.tf subnet index = 3
resource "aws_instance" "secvpc-az1-linux" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "bastion-keypair"
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.3.20"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[3]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = true
  tags = {
          Owner = "dan-via-terraform"
          Name  = "secvpc-az1-linux"
    }
}
 
#  Second end user EC2 in VPC=usr1vpc, subnet=usr1-az2-inst, vars.tf subnet index = 7
resource "aws_instance" "secvpc-az2-linux" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "bastion-keypair"
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.67.20"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[7]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = true
  tags = {
          Owner = "dan-via-terraform"
          Name  = "secvpc-az2-linux"
    }
}
##

# First Cisco ASAv firewall 
locals {
  asav_ami           = "ami-0e59c968be56bcc4d"  # BYOL AMI, ASAv version 9.19.1 
  asav_inst_type     = "c5.xlarge"               # Cisco min recommendation
  }  

resource "aws_instance" "ASAv-1" {
  ami                                 = local.asav_ami
  instance_type                       = local.asav_inst_type           
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  key_name                            = "bastion-keypair"
  associate_public_ip_address         = false
  private_ip                          = "10.100.3.10"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[3]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = false
  #iam_instance_profile                = aws_iam_instance_profile.ec2_profile.id   # Allow this instance to get bootstrap config from S3 bucket
  #user_data = <<EOF
#vmseries-bootstrap-aws-s3bucket=pavm-s3-ds/PA-VM-1
#EOF

  tags = {
          Owner = "dan-via-terraform"
          Name  = "ASAv-1"
    }
}
  
  
