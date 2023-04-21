#  Terraform to create end user EC2s 

#  private subnet ec2
resource "aws_instance" "linux1-priv-snet" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "bastion-keypair"
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.1.20"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[1]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = true
  tags = {
          Owner = "dan-via-terraform"
          Name  = "linux1-priv-snet"
    }
}
 
#  dmz subnet ec2
resource "aws_instance" "linux2-dmz-snet" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "bastion-keypair"
  #key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  private_ip                          = "10.100.2.20"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[2]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = true
  tags = {
          Owner = "dan-via-terraform"
          Name  = "linux2-dmz-snet"
    }
}

#  bastion host in mgmt subnet
resource "aws_instance" "bastion-host" {
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
          Name  = "bastion-host"
    }
}
##
  
