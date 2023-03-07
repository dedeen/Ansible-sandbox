#  Terraform to create Route Tables for the environment (TGW RTs are in separate .tf file)

# Create RT for app1vpc instances
resource "aws_route_table" "app1vpc-rt" {
  vpc_id                = module.vpc["app1vpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "0.0.0.0/0"
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "App1-instances-RT"
  }  
}

# Associate RT with both instance subnets in app1vpc (one per AZ)
  /* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "app1-az1-assoc" {
  subnet_id           = module.vpc["app1vpc"].intra_subnets[0]
  route_table_id      = aws_route_table.app1vpc-rt.id
}  
resource "aws_route_table_association" "app1-az2-assoc" {
  subnet_id           = module.vpc["app1vpc"].intra_subnets[2]
  route_table_id      = aws_route_table.app1vpc-rt.id
}
>>> End of terraform bug skip   */

# Create RT for app2vpc instances
resource "aws_route_table" "app2vpc-rt" {
  vpc_id                = module.vpc["app2vpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "0.0.0.0/0"
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "App2-instances-RT"
  }  
}

# Associate RT with both instance subnets in app2vpc (one per AZ)
  /* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "app2-az1-assoc" {
  subnet_id           = module.vpc["app2vpc"].intra_subnets[0]
  route_table_id      = aws_route_table.app2vpc-rt.id
} 
resource "aws_route_table_association" "app2-az2-assoc" {
  subnet_id           = module.vpc["app2vpc"].intra_subnets[2]
  route_table_id      = aws_route_table.app2vpc-rt.id
}
>>> End of terraform bug skip   */

    
  
# Create RT for private interfaces on Panorama instances
resource "aws_route_table" "mgmtvpc-rt-private-subnets" {
  depends_on            = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                = module.vpc["mgmtvpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "10.100.0.0/16"                       # route to PA-VM firewalls
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Mgmt-private-subnets-RT"
  }  
}
#   Need to associate this RT to the two private subnets in the mgmt VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id = mgmt-az1-int, move RT association from Mgmt-VPC-intra to Mgmt-private-subnets-RT
#     subnet_id = mgmt-az2-int, move RT association from Mgmt-VPC-intra to Mgmt-private-subnets-RT

  
# Create RT for public interfaces on Panorama instances
resource "aws_route_table" "mgmtvpc-rt-public-subnets" {
  depends_on            = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                = module.vpc["mgmtvpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.mgmt_vpc_igw.id 
  }
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "10.100.0.0/16"
    gateway_id          = aws_ec2_transit_gateway.TGW-PAN.id 
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Mgmt-public-subnets-RT"
  }  
}
#   Need to associate this RT to the two private subnets in the mgmt VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id = mgmt-az1-pub, move RT association from Mgmt-VPC-intra to Mgmt-public-subnets-RT
#     subnet_id = mgmt-az2-pub, move RT association from Mgmt-VPC-intra to Mgmt-public-subnets-RT
  
  
# Create RT for public subnets (2) of Security VPC
resource "aws_route_table" "secvpc-rt-public-subnets" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          # route to IGW - gives outside access for inbound traffic to PA-VMs
    gateway_id  = aws_internet_gateway.sec_vpc_igw.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-public-subnets-RT"
  }  
}
# Associate this RT with the public subnets in the security VPC
  /* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "sec-pub1-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[2]
  route_table_id      = aws_route_table.secvpc-rt-public-subnets.id
} 
resource "aws_route_table_association" "sec-pub2-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[8]
  route_table_id      = aws_route_table.secvpc-rt-public-subnets.id
}
>>> End of terraform bug skip   */
 
  
# Create RT for mgmt subnets (2) of Security VPC
resource "aws_route_table" "secvpc-rt-mgmt-subnets" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          # route to IGW - mgmt interface of PA-VMs 
    gateway_id  = aws_internet_gateway.sec_vpc_igw.id
  }
  route {                                                      
    cidr_block          = "10.104.0.0/16"                      # route via TGW to App1 VPC
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.105.0.0/16"                      # route via TGW to App2 VPC 
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.255.0.0/16"                      # route via TGW to mgmt VPC (Panoramas) from mgmt int of PA-VMs 
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-mgmt-subnets-RT"
  }  
}
# Associate this RT with the public subnets in the security VPC
  /* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "sec-pub1-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[0]
  route_table_id      = aws_route_table.secvpc-rt-public-subnets.id
} 
resource "aws_route_table_association" "sec-pub2-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[6]
  route_table_id      = aws_route_table.secvpc-rt-public-subnets.id
}
>>> End of terraform bug skip   */


# Create RT for private subnets (2) of Security VPC to end user VPCs via TGW
resource "aws_route_table" "secvpc-rt-private-subnets" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "10.104.0.0/24"                         
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.105.0.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.104.128.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                      
    cidr_block          = "10.105.128.0/24"                       
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-private-subnets-RT"
  }  
}  
# Need to associate this RT to the two private subnets in the security VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id = module.vpc["secvpc"].intra_subnets[1] to TGW (subnet name is sec-az1-int)
#     subnet_id = module.vpc["secvpc"].intra_subnets[7] to TGW (subnet name is sec-az2-int)
#     Bash cmds to make these associations are as follows: 
 
  
/* dje - uncomment these 2 RTs and add GWLB-eps after building the resources: 
resource "aws_route_table" "secvpc-rt-tgw-az1" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          
    gateway_id  = GWLB-Endpoint-2A
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-TGW-AZ1-to-GWLBe-RT"
  }  
}
# and associate here to subnet sec-az1-TGW_Att

resource "aws_route_table" "secvpc-rt-tgw-az2" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                         
    gateway_id  = GWLB-Endpoint-2B
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-TGW-AZ2-to-GWLBe-RT"
  }  
}
# and associate here to subnet sec-az2-TGW_Att
*/  
#resource "aws_route_table" "secvpc-rt-gwlbe-tgw" {
#  vpc_id                = module.vpc["secvpc"].vpc_id 
#  route {                                                      
#    cidr_block          = "0.0.0.0/0"                         
#    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
#  }
#  tags = {
#    Owner = "dan-via-terraform"
#    Name  = "Secvpc-GWLBe-az1andaz2-to-TGW-RT"
#  }  
#}
# associate with GWLB-EP subnets (both)
/* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "sec-gwlbe-tgw-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[4]
  route_table_id      = aws_route_table.secvpc-rt-gwlbe-tgw.id
} 
resource "aws_route_table_association" "sec-gwlbe-tgw-assoc" {
  subnet_id           = module.vpc["secvpc"].intra_subnets[10]
  route_table_id      = aws_route_table.secvpc-rt-gwlbe-tgw.id
} 
>>> end of commented out association  */
    
# Create RT for websrvvpc instances
resource "aws_route_table" "webaz1and2-inst-rt" {
  vpc_id                = module.vpc["websrvvpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "0.0.0.0/0"
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "WebSrv-subnets-RT"
  }  
}
# Need to associate this RT to the two instance subnets in the webserver VPC
#   This is done via bash script due to terraform bug with RT association changes 
#     subnet_id = module.vpc["websrvvpc"].intra_subnets[0] to TGW (subnet name is websrv-az1-inst)
#     subnet_id = module.vpc["websrvvpc"].intra_subnets[3] to TGW (subnet name is websrv-az2-inst)  
  
# Create RT for vpn subnet of Palo Alto firewall PA-VM1
resource "aws_route_table" "secvpc-rt-vpn-az1-subnets" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          # route to IGW - mgmt interface of PA-VMs 
    gateway_id  = aws_internet_gateway.sec_vpc_igw.id
  }
  
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-vpn-az1-subnet-RT"
  }  
}

  # Create RT for vpn subnet of Palo Alto firewall PA-VM2
resource "aws_route_table" "secvpc-rt-vpn-az2-subnets" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          # route to IGW - mgmt interface of PA-VMs 
    gateway_id  = aws_internet_gateway.sec_vpc_igw.id
  }
  
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-vpn-az2-subnet-RT"
  }  
}
  # Need to associate these two RTs to the two vpn subnets on the Palo Alto firewalls
#   This is done via bash script due to terraform bug with RT association changes 
#     RT name is Secvpc-vpn-az1-subnet-RT <-> subnet name is sec-az1-vpn
#     RT name is Secvpc-vpn-az2-subnet-RT <-> subnet name is sec-az2-vpn

