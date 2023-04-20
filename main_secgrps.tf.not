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

#  This secgrp is for the public side of the PA firewalls, connected through an IGW with an EIP
resource "aws_security_group" "SG-PAFW-Public" {
  name                  = "SG-PAFW-Public"
  description           = "SG-PAFW-Public"
  vpc_id                = module.vpc["secvpc"].vpc_id
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
    Name = "SG-PAFW-Public"
    Owner = "dan-via-terraform"
    }
}

#  This secgrp is for the mgmt interface of the PA firewalls
resource "aws_security_group" "SG-PAFW-Mgmt" {
  name                  = "SG-PAFW-Mgmt"
  description           = "SG-PAFW-Mgmt"
  vpc_id                = module.vpc["secvpc"].vpc_id
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
    Name = "SG-PAFW-Mgmt"
    Owner = "dan-via-terraform"
    }
}
  
#  This secgrp is for the internal side (client VPCs) of the PA firewalls
resource "aws_security_group" "SG-PAFW-Private" {
  name                  = "SG-PAFW-Private"
  description           = "SG-PAFW-Private"
  vpc_id                = module.vpc["secvpc"].vpc_id
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
    Name = "SG-PAFW-Private"
    Owner = "dan-via-terraform"
    }
}

#  This secgrp is for the public side of the Panorama instances
resource "aws_security_group" "SG-Panorama-Public" {
  name                  = "SG-Panorama-Public"
  description           = "SG-Panorama-Public"
  vpc_id                = module.vpc["mgmtvpc"].vpc_id
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
    Name = "SG-Panorama-Public"
    Owner = "dan-via-terraform"
    }
}
  
  #  This secgrp is for the private (internal) interface of the Panorama instances
resource "aws_security_group" "SG-Panorama-Private" {
  name                  = "SG-Panorama-Private"
  description           = "SG-Panorama-Private"
  vpc_id                = module.vpc["mgmtvpc"].vpc_id
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
    Name = "SG-Panorama-Private"
    Owner = "dan-via-terraform"
    }
}

#  This secgrp is for the internet facing ALB for inbound web traffic
  #   Need outbound in this secgrp for traffic ALB to Target Groups 
resource "aws_security_group" "SG-Inbound-Web" {
  name                  = "SG-Inbound-Web"
  description           = "SG-Inbound-Web"
  vpc_id                = module.vpc["secvpc"].vpc_id
  ingress {
    description         = "inbound http"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
  }
  ingress {
    description         = "inbound https"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
  }
  egress {
    description         = "outbound http"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
  }
  egress {
    description         = "outbound https"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
  }
    tags = {
    Name = "SG-Inbound-Web"
    Owner = "dan-via-terraform"
    }
}
  
#  This secgrp is for web traffic from the security VPC to the interior ALB, then through to the web servers
  #   Need outbound in this secgrp for traffic ALB to Target Groups 
resource "aws_security_group" "SG-Interior-Web" {
  name                  = "SG-Interior-Web"
  description           = "SG-Interior-Web"
  vpc_id                = module.vpc["websrvvpc"].vpc_id
  ingress {
    description         = "inbound http"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
  }
  ingress {
    description         = "inbound https"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
  }
  egress {
    description         = "outbound http"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
  }
  egress {
    description         = "outbound https"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
  }
    tags = {
    Name = "SG-Interior-Web"
    Owner = "dan-via-terraform"
    }
}
