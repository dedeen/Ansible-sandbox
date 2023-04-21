#  Terraform to create ASAvs on AWS

# First Cisco ASAv firewall 
#     Building these firewalls with 4 interfaces: mgmt, public, private, and dmz
#       in that order. Creating 2nd eth interfaces for mgmt and public and hang an EIP on them for outside access
  
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
  user_data = <<EOF
    hostname ASAv-1
    enable password password
    password password
    interface Management0/0
    nameif management 
    security-level 100 
    ip address dhcp setroute 
    no shutdown
    interface TenGigabitEthernet0/0
    nameif TG00
    security-level 0
    ip address 10.100.1.10 255.255.255.0
    no shutdown
    interface TenGigabitEthernet0/1
    nameif TG01
    security-level 0
    ip address 10.100.2.10 255.255.255.0
    no shutdown
    EOF
  tags = {
          Owner = "dan-via-terraform"
          Name  = "ASAv-1"
    }
}

#  Add three additional NICs to the ASAv
#    2nd = eth1
resource "aws_network_interface" "eth1" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[0]                   # public subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.0.10"]   
  source_dest_check     = false                                                 # promisc mode -> this is a firewall
    
  attachment  {
    instance            = aws_instance.ASAv-1.id
    device_index        = 1
  }
} 
 
  
#    3rd = eth2
resource "aws_network_interface" "eth2" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[1]                   # private subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.1.10"]   
  source_dest_check     = false                                                 # promisc mode -> this is a firewall
    
  attachment  {
    instance            = aws_instance.ASAv-1.id
    device_index        = 2
  }
} 
  
  
#    4th = eth3
resource "aws_network_interface" "eth3" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[2]                   # dmz subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.2.10"]   
  source_dest_check     = false                                                 # promisc mode -> this is a firewall
    
  attachment  {
    instance            = aws_instance.ASAv-1.id
    device_index        = 3
  }
} 

  
# Create two EIPs for each ASAv one for the mgmt interface, and one for the public-side interface for outbound traffic flows. 
resource "aws_eip" "ASAv-eip-mgmt-int" {
  vpc                   = true
}
resource "aws_eip" "ASAv-eip-public-int" {
  vpc                   = true
}

# Associate these EIPs with the specific firewall NICs 
resource "aws_eip_association" "asav1-mgt-assoc" {
  allocation_id         = aws_eip.ASAv-eip-mgmt-int.id
  network_interface_id  = aws_instance.ASAv-1.primary_network_interface_id
}
resource "aws_eip_association" "asav1-pub-assoc" {
  allocation_id         = aws_eip.ASAv-eip-public-int.id
  network_interface_id  = aws_network_interface.eth1.id
}
  

