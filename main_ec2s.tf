#  Terraform to create end user EC2s 

#  First EC2 in VPC=secvpc, subnet=sec-az1-mgmt, vars.tf subnet index = 3
resource "aws_instance" "secvpc-az1-linux" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "bastion-keypair"
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.3.10"
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
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.67.10"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[7]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = true
  tags = {
          Owner = "dan-via-terraform"
          Name  = "secvpc-az2-linux"
    }
}
##
