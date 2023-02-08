# Create some base NACLs for each VPC 
#    NACLs are built per VPC, so iterate through VPCs

#  This secgrp will llow all IPv4 traffic in and out
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

  
  #  Now that each VPC has one of these ACLs, associate it with the app-VPC instance subnets
  resource "aws_network_acl_association" "vpc-subnet-NACL-assoc" {
     network_acl_id   = aws_network_acl.NACL-allow_ipv4["app1vpc"]
     subnet_id        = module.vpc["app1vpc"].intra_subnets[0]
  }
    
