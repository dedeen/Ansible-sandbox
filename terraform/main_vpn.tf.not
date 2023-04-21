#  Terraform to add infrastructure configuration to the more Palo Alto VM-NGFWs already deployed from other .tf scripts in this repo. 

resource "aws_network_interface" "eth-PA-VM1-vpn" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[12]                 # index=12 for az1, 13 for az2
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.6.10"]  
  source_dest_check     = false                                                 # promiscuous mode
    
  attachment  {
    instance            = aws_instance.PA-VM-1.id                               # for 2nd PA-VM, instance id is 'PA-VM-2.id' 
    device_index        = 3                                                     # eth0,1,2 already in use on firewall 
  }
}
  
# Create another EIP for the VPN interface 
resource "aws_eip" "PA1-vpn-int" {
  vpc                   = true
}

# Associate new IP to Firewall ENI
resource "aws_eip_association" "pa1-vpn-assoc" {
  allocation_id         = aws_eip.PA1-vpn-int.id
  network_interface_id  = aws_network_interface.eth-PA-VM1-vpn.id
}
###################################################################
resource "aws_network_interface" "eth-PA-VM2-vpn" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[13]                 # index=12 for az1, 13 for az2
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.70.10"]  
  source_dest_check     = false                                                 # promiscuous mode
    
  attachment  {
    instance            = aws_instance.PA-VM-2.id                               # for 2nd PA-VM, instance id is 'PA-VM-2.id' 
    device_index        = 3                                                     # eth0,1,2 already in use on firewall 
  }
}
  
# Create another EIP for the VPN interface 
resource "aws_eip" "PA2-vpn-int" {
  vpc                   = true
}

# Associate new IP to Firewall ENI
resource "aws_eip_association" "pa2-vpn-assoc" {
  allocation_id         = aws_eip.PA2-vpn-int.id
  network_interface_id  = aws_network_interface.eth-PA-VM2-vpn.id
}
  
