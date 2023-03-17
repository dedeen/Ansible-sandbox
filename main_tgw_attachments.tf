#  Create TGW Attachments in each of the VPCs
#  Usr01-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "usr1vpc-att" {
  subnet_ids              = [module.vpc["usr1vpc"].intra_subnets[1],module.vpc["usr1vpc"].intra_subnets[3]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["usr1vpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-usr1vpc-att"
  }  
}

#  Usr02-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "usr2vpc-att" {
  subnet_ids              = [module.vpc["usr2vpc"].intra_subnets[1],module.vpc["usr2vpc"].intra_subnets[3]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["usr2vpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-usr2vpc-att"
  }  
}
    
#  Mgmt-VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "mgmtvpc-att" {
  subnet_ids              = [module.vpc["mgmtvpc"].intra_subnets[2],module.vpc["mgmtvpc"].intra_subnets[5]]
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
    
#  WebSrv VPC 
resource "aws_ec2_transit_gateway_vpc_attachment" "websrvvpc-att" {
  subnet_ids              = [module.vpc["websrvvpc"].intra_subnets[1],module.vpc["websrvvpc"].intra_subnets[4]]
  transit_gateway_id      = aws_ec2_transit_gateway.TGW-PAN.id
  vpc_id                  = module.vpc["websrvvpc"].vpc_id
  appliance_mode_support  = "enable"                            # prevents asymm flows between consumer VPC and security VPC
  dns_support             = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Owner = "dan-via-terraform"
    Name  = "TGW-websrvvpc-att"
  }  
}

#  Associate spokes route table with app1vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-to-usr1vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.usr1vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}
    
#  Associate spokes route table with app2vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-to-usr2vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.usr2vpc-att.id
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

 #  Associate security route table with the webserver vpc TGW attachment
 resource "aws_ec2_transit_gateway_route_table_association" "spoke-rt-to-websrvvpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.websrvvpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Spoke-VPCs.id
}

#  Propagate routes from usr1vpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "usr1vpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.usr1vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}
    
#  Propagate routes from usr2vpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "usr2vpc-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.usr2vpc-att.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-RT-Security-VPC.id
}

#  Propagate routes from websrvvpc TGW attachment to the route table for the security vpc
resource "aws_ec2_transit_gateway_route_table_propagation" "web-to-sec-rt" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.websrvvpc-att.id
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
    
