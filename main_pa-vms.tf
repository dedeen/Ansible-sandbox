#  Terraform to create EC2s as Palo Alto VM-NGFWs
#    For starters, just building small EC2s with 3 NICs

resource "aws_instance" "PA-VM-1" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  subnet_id                           = module.vpc["secvpc"].intra_subnets[0]
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "PA-VM-1"
    }
}
  

