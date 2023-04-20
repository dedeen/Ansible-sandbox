# Create security groups for each VPC 
#    SecGrps are per VPC, so iterate through my list of VPC vars and build one SG per VPC


#  This secgrp will allow all IPv4 traffic in and out
resource "aws_security_group" "SG-allow_ipv4" {
  for_each = var.app_vpcs 
    name                  = "SG-allow_ipv4"
    description           = "SG-allow_ipv4"
    vpc_id                = module.vpc[each.value.map_key].vpc_id
    ingress {
      description         = "inbound v4"
      cidr_blocks         = ["0.0.0.0/0"]
      from_port           = 0
      to_port             = 0
      protocol            = "-1"
    }
    egress {
      description         = "outbound v4"
      cidr_blocks         = ["0.0.0.0/0"]
      from_port           = 0
      to_port             = 0
      protocol            = "-1"
    }
    tags = {
      Name = "SG-allow_ipv4"
      Owner = "dan-via-terraform"
    }
}
##
