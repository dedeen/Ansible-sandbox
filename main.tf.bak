/*  Terraform to create a single VPC in specified region, using vpc module: 
      - Two subnets, one public and one private 
      - NAT GW, IGW with EIP, routes needed 
      
      Use at your own peril, and be mindful of the AWS costs of 
      building this environment.  
        -- Dan Edeen, dan@dsblue.net, 2022  --
	   
*/
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
    azs               = each.value.az_list
    private_subnets   = [each.value.priv_subnet]
    public_subnets    = [each.value.publ_subnet]
    intra_subnets     = [each.value.intra_subnets]
    enable_ipv6             = false
    enable_nat_gateway      = true
    one_nat_gateway_per_az  = false
    single_nat_gateway      = true
}

# Create SecGrp to allow ICMP into attached subnet
resource "aws_security_group" "allow_inbound_icmp" {
  name          = "allow_inbound_icmp"
  description   = "allow_inbound icmp"
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

# Create web server in the public subnet, install Apache, PHP, MariaDB 
#    Start up web server, open ports 80 and 443 
#    Also need to open ssh inbound for remote-exec (below), and 
#    outbound connection for linux to get software updates.  

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
