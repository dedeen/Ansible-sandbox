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
    
    
    
