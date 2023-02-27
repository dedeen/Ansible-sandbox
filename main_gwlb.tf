#  Terraform to create Gateway Load Balancer for Palo Alto middlebox project
#
resource "aws_lb" "PAVMGWLB2" {
  name                                = "PAVMGWLB2"
  load_balancer_type                  = "gateway"
  internal                            = true
  enable_cross_zone_load_balancing    = true
  ip_address_type                     = "ipv4"
  
  subnet_mapping  {
    subnet_id                         = module.vpc["secvpc"].intra_subnets[5]
  }
  subnet_mapping  {
    subnet_id                         = module.vpc["secvpc"].intra_subnets[11]
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVMGWLB2"
  }
}    
#
