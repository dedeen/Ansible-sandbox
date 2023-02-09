#  Terraform to create EC2s as Palo Alto VM-NGFWs
#    For starters, just building small EC2s with 3 NICs

resource "aws_instance" "PA-VM-1" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.small"                # max 4 NICs
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  subnet_id                           = module.vpc["secvpc"].intra_subnets[0]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "PA-VM-1"
    }
}
  
# Add two more NICs to the PA-VM instance 
resource "aws_network_interface" "eth1" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[1]                   #internal (app-vpc side) subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  #private_ips          = ["10.100.1.10"]      
    
  attachment  {
    instance            = aws_instance.PA-VM-1.id
    device_index        = 1
  }
}

resource "aws_network_interface" "eth2" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[2]             #public subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  #private_ips          = ["10.100.1.10"]      
    
  attachment  {
    instance            = aws_instance.PA-VM-1.id
    device_index        = 2
  }
}

