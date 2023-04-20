#  Terraform to create vpcs, simple set up for ASAv firewalls. 
#
# Build VPCs for Project
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"

  for_each = var.app_vpcs     #App and Mgmt VPCs
    providers = {
      aws = aws.usw2  # Set region via provider alias
    }
    name              = each.value.region_dc
    cidr              = each.value.cidr
    azs               = each.value.az_list
	
    # Create subnets: private get route through NATGW, intra do not
    intra_subnets   		= each.value.vpc_subnets	
    intra_subnet_names 		= each.value.subnet_names
    enable_ipv6            	= false
    enable_nat_gateway   	= false
    enable_dns_hostnames	= true		# default is false
    enable_dns_support		= true		# default is true 
  
}
	
# Build IGW on the Security VPC to allow outside access 
resource "aws_internet_gateway" "sec_vpc_igw" {
	vpc_id = module.vpc["secvpc"].vpc_id
		
	tags = {
	  Name = "sec_vpc_igw"
	}
}
	

