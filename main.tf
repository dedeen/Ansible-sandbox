#  Terraform to create a multi-subnet VPC with PAN firewall between outside and the internal subnets. 
#         https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#         https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
#         -- Dan Edeen, dan@dsblue.net, 2022  --   
#

# Creating standalone EIPs for the NATGW - may use later or not, passed in via external_nat_id_ids in module "vpc"
resource "aws_eip" "nat" {
    count 	= 1 
    vpc 	= true
}
# 

#
# Build VPCs for DataCenters
module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"

  for_each = var.new_vpcs
    providers = {
      aws = aws.usw2  # Set region via provider alias
    }
    name              = each.value.region_dc
    cidr              = each.value.cidr
    azs              		= each.value.az_list
	
    # Create subnets: private get route through NATGW, intra do not
    private_subnets   		= [each.value.server_subnet]	# private subnets are created with route to I through NATGW
    private_subnet_names 	= ["server_subnet"]
    public_subnets    		= [each.value.edge_subnet]
    public_subnet_names 	= ["edge_subnet"]
    intra_subnets     		= [each.value.public_subnet]	# intra subnets are created without route to Internet
    intra_subnet_names 		= ["public_subnet"]
    enable_ipv6            	= false
	
    # Create single NATGW for each VPC, all private subnets must route through it to reach Internet 
    enable_nat_gateway     	= true
    one_nat_gateway_per_az  	= false # single_nat_gateway overrides this parameter
    single_nat_gateway      	= true	# only need to create 1 EIP above with this setting
    reuse_nat_ips	    	= true	# dont create EIPs here for NATGW, instead use from above 
    external_nat_ip_ids	    	= "${aws_eip.nat.*.id}"			# as per above 
}

# Create NACLs, can specify per subnet here 
resource "aws_network_acl" "NACL-edge" {
  vpc_id      		= module.vpc["datacenter1"].vpc_id
  depends_on 	= [module.vpc]
  
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
    Name = "NACL-edge"
  }
}

# Assoc NACL to subnet
resource "aws_network_acl_association" "edgeNACL_snet" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = module.vpc["datacenter1"].public_subnets[0]	#public == edge here
}
	
    
    # Create SecGrp to allow ICMP into attached subnet
resource "aws_security_group" "allow_inbound_icmp" {
  name          = "allow_inbound_icmp"
  description   = "allow_inbound icmp"
  depends_on 	= [module.vpc]
  vpc_id        = module.vpc["datacenter1"].vpc_id
  ingress {
    description         = "ICMP inbound"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 8
    to_port             = 0
    protocol            = "icmp"
  }
  tags = {
    Name = "allow_inbound_icmp"
    Owner = "dan-via-terraform"
  }
}

resource "aws_security_group" "allow_http_https" {
  name          = "allow_http_https"
  description   = "allow_http_https"
  depends_on 	= [module.vpc]
  vpc_id        = module.vpc["datacenter1"].vpc_id
  ingress {
    description         = "http"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 80
    to_port             = 80 
    protocol            = "tcp"
  }
	  
ingress {
    description         = "https"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 443
    to_port             = 443 
    protocol            = "tcp"
  }
	  
  tags = {
    Name = "allow_http_https" 
    Owner = "dan-via-terraform"
  }
}

# Create SecGrp to allow all IPv4 traffic into attached subnet
resource "aws_security_group" "allow_ipv4" {
  name                  = "allow_ipv4"
  description           = "allow_ipv4"
  depends_on 		= [module.vpc]
  vpc_id                = module.vpc["datacenter1"].vpc_id
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
    Name = "allow_ipv4"
    Owner = "dan-via-terraform"
  }
}

# Create SecGrp to allow inbound ssh, outbound all 
resource "aws_security_group" "allow_ssh" {
  name                  = "allow_ssh"
  description           = "All inbound ssh"
  depends_on 		= [module.vpc]
  vpc_id                = module.vpc["datacenter1"].vpc_id
  ingress {
    description         = "All inbound ssh"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
  }
  egress {
    description         = "All outbound v4"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
  }
  tags = {
    Name = "allow_ssh"
    Owner = "dan-via-terraform"
  }
}

# Create SecGrp to allow traffic from within the public and private subnets, blocked outside of these 
resource "aws_security_group" "allow_intra_vpc" {
  name                  = "allow_intra_vpc"
  description           = "All intra_vpc"
  depends_on 	= [module.vpc]
  vpc_id                = module.vpc["datacenter1"].vpc_id
  ingress {
    description         = "All intra vpc v4"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
  }
  egress {
    description         = "All intra vpc v4"
    cidr_blocks         = ["0.0.0.0/0"]
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
  }
  tags = {
    Name = "allow_intra_vpc"
    Owner = "dan-via-terraform"
  }
}
/*
# Create EC2 Instance(s) in the public subnet - allow inbound icmp and other ipv4
resource "aws_instance" "ec2-public-subnet" {
    ami                                 = "ami-094125af156557ca2"
    instance_type                       = "t2.micro"
    key_name                            = "${aws_key_pair.generated_key.key_name}"
    associate_public_ip_address         = true
    subnet_id                           = module.vpc["datacenter1"].public_subnets[0]
    vpc_security_group_ids              = [aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_ipv4.id]
    source_dest_check                   = false
    tags = {
          Owner = "dan-via-terraform"
          Name  = "ec2-inst1-public"
    }
}
 
# Create EC2 Instance(s) in the private subnet 
#    No public IP, so must connect through an instance in the public subnet, ssh only, outbound v4 allowed 
resource "aws_instance" "ec2-private-subnet" {
    ami                                 = "ami-094125af156557ca2"
    instance_type                       = "t2.micro"
    key_name                            = "${aws_key_pair.generated_key.key_name}"
    associate_public_ip_address         = false
    subnet_id                           = module.vpc["datacenter1"].private_subnets[0]
    vpc_security_group_ids              = [aws_security_group.allow_ssh.id]
    source_dest_check                   = false
    tags = {
          Owner = "dan-via-terraform"
          Name  = "ec2-inst1-private"
    }
}

# Create EC2 Instance(s) in the intra subnet 
#    Only allowing traffic from the private subnet in this VPC
resource "aws_instance" "ec2-intra-subnet" {
    ami                                 = "ami-094125af156557ca2"
    instance_type                       = "t2.micro"
    key_name                            = "${aws_key_pair.generated_key.key_name}"
    associate_public_ip_address         = false
    subnet_id                           = module.vpc["datacenter1"].intra_subnets[0]
    vpc_security_group_ids              = [aws_security_group.allow_intra_vpc.id]
    source_dest_check                   = false
    tags = {
          Owner = "dan-via-terraform"
          Name  = "ec2-inst1-intra"
    }
}
*/
# Create web server in the public subnet, install Apache, PHP, MariaDB 
#    Start up web server, open ports 80 and 443 
#    Also need to open ssh inbound for remote-exec (below), and 
#    outbound connection for linux to get software updates.  

/*
  resource "aws_instance" "ec2-webserver1" {
    ami                                 = "ami-094125af156557ca2"
    instance_type                       = "t2.micro"
    key_name                            = "${aws_key_pair.generated_key.key_name}"
    associate_public_ip_address         = true
    subnet_id                           = module.vpc["datacenter1"].public_subnets[0]
    vpc_security_group_ids              = [aws_security_group.allow_http_https.id, aws_security_group.allow_inbound_icmp.id, aws_security_group.allow_ipv4.id]
    source_dest_check                   = false
    tags = {
          Owner = "dan-via-terraform"
          Name  = "ec2-webserver1"
    }
    connection {
            type        	= "ssh"
            user        	= "ec2-user"
            timeout     	= "5m"
            #private_key        = file(local.keypair_name)
            private_key     	= "${tls_private_key.dev_key.private_key_pem}"
            host = aws_instance.ec2-webserver1.public_ip
    }
            
   provisioner "remote-exec" {
           inline = ["sudo yum update -y", 
                   "sudo amazon-linux-extras install php8.0 mariadb10.5 -y", 
                   "sudo yum install -y httpd",
                   "sudo systemctl start httpd",
                   "sudo systemctl enable httpd"]
   }   
}

*/
