#  Terraform to create Transit GW (TGW), attachments in the VPCs, and TGW Route Tables
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
