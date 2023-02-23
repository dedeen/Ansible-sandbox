# Create 'interim RT' for TGW Attachment subnets in SecVPC. 
#  These routes are needed for testing before adding the GWLB to the architecture. 
#
resource "aws_route_table" "devonly_secvpc_tgwatt-az1-subnet" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block            = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.eth1.id     #this is the 2nd (eth1) int on 1nd firewall (PA-VM-1), 10.100.1.10
  }
  route {                                                      
    cidr_block          = "10.104.0.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.105.0.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
    
  tags = {
    Owner = "dan-via-terraform"
    Name  = "devonly_secvpc_tgwatt-az1-subnet"
  }  
}  
# Need to associate this RT to the two private subnets in the security VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id         = module.vpc["secvpc"].intra_subnets[3]                -> subnet name is sec-az2-TGW_Att
#     route_table_id    = devonly_secvpc-rt-secvpc_tgwatt_az1-subnet.id
#
resource "aws_route_table" "devonly_secvpc_tgwatt-az2-subnet" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block            = "0.0.0.0/0"
    network_interface_id  = aws_network_interface.eth3.id     #this is the 2nd (eth1) int on 2nd firewall (PA-VM-2), 10.100.65.10
  }
  route {                                                      
    cidr_block          = "10.104.0.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.105.0.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
    
  tags = {
    Owner = "dan-via-terraform"
    Name  = "devonly_secvpc_tgwatt-az2-subnet"
  }  
}  
# Need to associate this RT to the two private subnets in the security VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id         = module.vpc["secvpc"].intra_subnets[9]                 -> subnet name is sec-az2-TGW_Att
#     route_table_id    = devonly_secvpc-rt-secvpc_tgwatt_az1-subnet.id
#
