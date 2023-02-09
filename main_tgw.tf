#  Terraform to create Transit GW (TGW), attachments in the VPCs, and Route Tables

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
