#  Terraform to create Gateway Load Balancer for Palo Alto middlebox project
#
# create the load balancer
resource "aws_lb" "PAVM_GWLB" {
  #source                              = "hashicorp/awb" 
  name                                = "PAVM_GWLB"
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
    Name  = "PAVM_GWLB"
  }
}    
# create the LB target group
resource "aws_lb_target_group" "PAVMTargetGroup2" {
  name                    = "PAVMTargetGroup2"
  port                    = 6081
  protocol                = "GENEVE"
  target_type             = "ip"
  vpc_id                  = module.vpc["secvpc"].vpc_id
 
  health_check {
    path                  = "/php/login.php"      # specific to Palo Alto firewalls 
    port                  = 443
    protocol              = "HTTPS"
    timeout               = 5
    healthy_threshold     = 5
    unhealthy_threshold   = 2
    interval              = 10 
  }
    
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM_GWLB_TG2"
  }
}

# create an LB listener, connecting the LB and target group
resource "aws_lb_listener" "lb_listener1" {   
  load_balancer_arn   = aws_lb.PAVM_GWLB.id   #example is com.amazonaws.vpce.us-west-2.vpce-svc-0f68bde741e93d0c6
  #port                = "6081"
  #protocol            = "GENEVE"
  default_action {
    target_group_arn  = aws_lb_target_group.PAVMTargetGroup2.id
    type              = "forward"
  }
}

# register IP addresses of Palo Alto firewalls to the GWLB target group
resource "aws_lb_target_group_attachment" "reg_ip1" {
  target_group_arn    = aws_lb_target_group.PAVMTargetGroup2.arn
  target_id           = "10.100.1.10"
  port                = 6081
}
  
resource "aws_lb_target_group_attachment" "reg_ip2" {
  target_group_arn    = aws_lb_target_group.PAVMTargetGroup2.arn
  target_id           = "10.100.65.10"
  port                = 6081
}
  
  
# create VPC endpoint service (uses AWS PrivateLink)
resource "aws_vpc_endpoint_service" "vpc_ep_svc" {
  acceptance_required        = false 
  gateway_load_balancer_arns = [aws_lb.PAVM_GWLB.id]
   
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM2_EndPt_Service"
  }
}
  
# create two VPC endpoints for the GWLB
resource "aws_vpc_endpoint" "PAVM_VPCe_az1" {
  service_name          = aws_vpc_endpoint_service.vpc_ep_svc.service_name  #sample: com.amazonaws.vpce.us-west-2.vpce-svc-0f68bde741e93d0c6
  subnet_ids            = [module.vpc["secvpc"].intra_subnets[4]]  
  vpc_endpoint_type     = aws_vpc_endpoint_service.vpc_ep_svc.service_type
  vpc_id                = module.vpc["secvpc"].vpc_id
    
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM_VPCe_az1"
  }
}

resource "aws_vpc_endpoint" "PAVM_VPCe_az2" {
  service_name          = aws_vpc_endpoint_service.vpc_ep_svc.service_name  #sample: com.amazonaws.vpce.us-west-2.vpce-svc-0f68bde741e93d0c6
  subnet_ids            = [module.vpc["secvpc"].intra_subnets[10]]  
  vpc_endpoint_type     = aws_vpc_endpoint_service.vpc_ep_svc.service_type
  vpc_id                = module.vpc["secvpc"].vpc_id
    
  tags = {
    Owner = "dan-via-terraform"
    Name  = "PAVM_VPCe_az2"
  }
}    
