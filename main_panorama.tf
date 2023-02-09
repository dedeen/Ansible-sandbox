#  Terraform to create EC2s as Palo Alto Panorama systems
#    For starters, just building t2.micro EC2s, one in each AZ subnet

resource "aws_instance" "Panorama-1" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"               
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.255.0.10"
  subnet_id                           = module.vpc["mgmtvpc"].intra_subnets[0]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "Panorama-1"
    }
}
  
  resource "aws_instance" "Panorama-2" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"               
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.255.128.10"
  subnet_id                           = module.vpc["mgmtvpc"].intra_subnets[2]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "Panorama-2"
    }
}
  
