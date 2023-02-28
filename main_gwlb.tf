#  Terraform to create Gateway Load Balancer for Palo Alto middlebox project
#
#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 4.0"
#    }
#  }
#}
resource "aws_lb" "PAVMGWLB2" {
  #source                              = "hashicorp/awb" 
  name                                = "PAVMGWLB2"
  load_balancer_type                  = "gateway"
  enable_cross_zone_load_balancing    = true
  ip_address_type                     = "ipv4"
  
  subnet_mapping  {                         #VPC inferred from subnets
    subnet_id             = module.vpc["secvpc"].intra_subnets[5]
  }
  subnet_mapping  {
    subnet_id            = module.vpc["secvpc"].intra_subnets[11]
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM_GWLB2"
  }
}    
#
resource "awb_lb_target_group" "PAVMTargetGroup2" {
  name                   = "PAVMTargetGroup2"
  port                   = 6081
  protocol               = "GENEVE"
  target_type            = "ip"
  vpc_id                 = module.vpc["secvpc"].vpc_id
 
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM_GWLB_TG2"
  }
}
  
