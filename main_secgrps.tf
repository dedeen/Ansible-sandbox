# Create security groups for each VPC in the project
#
#  This secgrp will llow all IPv4 traffic in and out
resource "aws_security_group" "SG-allow_ipv4" {
  name                  = "SG-allow_ipv4"
  description           = "SG-allow_ipv4"
  depends_on 	        	= [module.vpc["app1vpc"]]
  vpc_id                = module.vpc["app1vpc"].vpc_id
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
