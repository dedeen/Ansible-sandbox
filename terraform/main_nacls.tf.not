# Create some base NACLs for each VPC 
#    NACLs are built per VPC, so iterate through VPCs

#  This secgrp will allow all IPv4 traffic in and out
resource "aws_network_acl" "NACL-allow_ipv4" {
  for_each      = var.app_vpcs 
    vpc_id      = module.vpc[each.value.map_key].vpc_id
      
    ingress {
      protocol		= "-1"
      rule_no		= 100
      action		= "allow"
      cidr_block		= "0.0.0.0/0"
      from_port		= 0	# ignored with protocol -1
      to_port		= 0	# ignored with protocol -1
    }
    egress {
      protocol		= "-1"
      rule_no		= 101
      action		= "allow"
      cidr_block		= "0.0.0.0/0"
      from_port		= 0	# ignored with protocol -1
      to_port		= 0	# ignored with protocol -1
    }
    tags = {
      Name = "NACL-allow_ipv4"
      Owner = "dan-via-terraform"
    }
}

  
  #  Now that each VPC has one of these ACLs, associate them with the usr-VPC instance subnets (2 per AZ)
  resource "aws_network_acl_association" "vpc-subnet-NACL-usr1-az1" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["usr1vpc"].id
     subnet_id        = module.vpc["usr1vpc"].intra_subnets[0]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-usr1-az2" {
    network_acl_id   = aws_network_acl.NACL-allow_ipv4["usr1vpc"].id
    subnet_id        = module.vpc["usr1vpc"].intra_subnets[2]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-usr2-az1" {
    network_acl_id   = aws_network_acl.NACL-allow_ipv4["usr2vpc"].id
    subnet_id        = module.vpc["usr2vpc"].intra_subnets[0]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-usr2-az2" {
    network_acl_id   = aws_network_acl.NACL-allow_ipv4["usr2vpc"].id
    subnet_id        = module.vpc["usr2vpc"].intra_subnets[2]
  }
    
  #  Assoc to the 4 Mgmt VPC instance subnets 
  resource "aws_network_acl_association" "vpc-subnet-NACL-mgmt-az1-int" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["mgmtvpc"].id
     subnet_id        = module.vpc["mgmtvpc"].intra_subnets[0]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-mgmt-az1-pub" {
    network_acl_id   = aws_network_acl.NACL-allow_ipv4["mgmtvpc"].id
    subnet_id        = module.vpc["mgmtvpc"].intra_subnets[1]
  }
  
  resource "aws_network_acl_association" "vpc-subnet-NACL-mgmt-az2-int" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["mgmtvpc"].id
     subnet_id        = module.vpc["mgmtvpc"].intra_subnets[3]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-mgmt-az2-pub" {
    network_acl_id   = aws_network_acl.NACL-allow_ipv4["mgmtvpc"].id
    subnet_id        = module.vpc["mgmtvpc"].intra_subnets[4]
  }

 #  Assoc to the 2 Web Server instance subnets 
  resource "aws_network_acl_association" "vpc-subnet-NACL-websrv-az1-inst" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["websrvvpc"].id
     subnet_id        = module.vpc["websrvvpc"].intra_subnets[0]
  }
  resource "aws_network_acl_association" "vpc-subnet-NACL-websrv-az2-inst" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["websrvvpc"].id
     subnet_id        = module.vpc["websrvvpc"].intra_subnets[3]
  }
    
  
    
