#  Terraform to create a EC2s in the AZ/subnets of the application vpcs

resource "aws_instance" "EC2-app1vpc-az1" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  subnet_id                           = module.vpc["app1vpc"].intra_subnets[0]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["app1vpc"].id]  
 # vpc_security_group_ids              = [aws_security_group.SG-inbnd_ssh.id, aws_security_group.SG-inbnd_icmp.id]  #Turn off icmp in production
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "EC2-app1vpc-az1"
    }
}
