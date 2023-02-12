#  Terraform to create Transit GW (TGW), attachments in the VPCs, and Route Tables
#   TGW:
resource "aws_ec2_transit_gateway" "TGW-PAN"  {
  description                         = "TGW-PAN"
  amazon_side_asn                     = 64512
  default_route_table_association     = "disable"
  default_route_table_propagation     = "disable"
  dns_support                         = "enable" 
  vpn_ecmp_support                    = "enable"
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-PAN"
  }
}

#  Route Table for Spoke VPCs
resource "aws_ec2_transit_gateway_route_table" "TGW-RT-Spoke-VPCs" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW-PAN.id
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-RT-Spokes"
  }
}

#  Route Table for Security VPC
resource "aws_ec2_transit_gateway_route_table" "TGW-RT-Security-VPC" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW-PAN.id
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-RT-Security-VPC"
  }
}

#  Create TGW Attachments in each of the VPCs
#  App01-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "app1vpc-att" {
  subnet_ids              = [module.vpc["app1vpc"].intra_subnets[1],module.vpc["app1vpc"].intra_subnets[3]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["app1vpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-app1vpc-att"
  }  
}

#  App02-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "app2vpc-att" {
  subnet_ids              = [module.vpc["app2vpc"].intra_subnets[1],module.vpc["app2vpc"].intra_subnets[3]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["app2vpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-app2vpc-att"
  }  
}
    
#  Mgmt-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "mgmtvpc-att" {
  subnet_ids              = [module.vpc["mgmtvpc"].intra_subnets[1],module.vpc["mgmtvpc"].intra_subnets[3]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["mgmtvpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-mgmtvpc-att"
  }  
}

#  Sec01-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "secvpc-att" {
  subnet_ids              = [module.vpc["secvpc"].intra_subnets[3],module.vpc["secvpc"].intra_subnets[9]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["secvpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-secvpc-att"
  }  
}

#  Associate spokes route table with app1vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-to-app1vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app1vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}
    
#  Associate spokes route table with app2vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-to-app2vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app2vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}
    
 #  Associate spokes route table with mgmtvpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-to-mgmtvpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmtvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}
  
 #  Associate security route table with the security vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "sec-rt-to-secvpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.secvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}
    
#  Propagate routes from app1vpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "app1vpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app1vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}
    
#  Propagate routes from app2vpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "app2vpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app2vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}
    
#  Propagate routes from mgmtvpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "mgmtvpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgmtvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}

#  Propagate routes from >> security VPC to the security_route_table
resource "aws_ec2_transit_gateway_route_table_propagation" "secvpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.secvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}
#  Propagate routes from >> security VPC to the spokes_route_table
resource "aws_ec2_transit_gateway_route_table_propagation" "secvpc-to-spokes-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.secvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}
 
#  Add default route to TGW spokes RT to direct all traffic to the security VPC
resource "aws_ec2_transit_gateway_route" "spokes-def-route-via-TGW" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.secvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}   
    
 
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

    
  
  # Create RT for mgmtvpc instances (Panorama)
resource "aws_route_table" "mgmtvpc-rt" {
  vpc_id                = module.vpc["mgmtvpc"].vpc_id 
  route {                                                       # local route to the VPC is added to RT automatically 
    cidr_block          = "10.0.0.0/8"                          # route to PA-VM firewalls
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  route {                                                       # local route to the VPC is added to RT automatically 
  cidr_block          = "0.0.0.0/0"                             # route to Internet via IGW in mgmt VPC
  gateway_id          = aws_internet_gateway.mgmt_vpc_igw.id 
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Mgmt-instances-RT"
  }  
}

# Associate RT with both instance subnets in mgmtvpc (one Panorama per AZ)
  /* >>> This commented out due to terraform bug, will add to cleanup bash script 
resource "aws_route_table_association" "mgmt-az1-assoc" {
  subnet_id           = module.vpc["mgmtvpc"].intra_subnets[0]
  route_table_id      = aws_route_table.mgmtvpc-rt.id
} 
resource "aws_route_table_association" "mgmt-az2-assoc" {
  subnet_id           = module.vpc["mgmtvpc"].intra_subnets[2]
  route_table_id      = aws_route_table.mgmtvpc-rt.id
}
>>> End of terraform bug skip   */
    
  
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
resource "aws_route_table" "secvpc-rt-gwlbe-tgw" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                         
    transit_gateway_id  = aws_ec2_transit_gateway.TGW-PAN.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "Secvpc-GWLBe-az1andaz2-to-TGW-RT"
  }  
}
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
  
