#  Terraform to create a multi-subnet VPC with PAN firewall between outside and the internal subnets. 
#         https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#         https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule
#         -- Dan Edeen, dan@dsblue.net, 2022  --   


##############	  
# Create web servers in the my subnets, install Apache, PHP, MariaDB 
#    Start up web server, open ports 80 and 443 
#    Also need to open ssh inbound for remote-exec (below), and 
#    outbound connection for linux to get software updates.  
	  
resource "aws_instance" "WebSrv1-edge-subnet" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  depends_on 				= [module.vpc,aws_key_pair.generated_key]
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  subnet_id                           = module.vpc["datacenter1"].public_subnets[0]	# public == edge
  vpc_security_group_ids              = [aws_security_group.SG-inbnd_http.id, aws_security_group.SG-inbnd_icmp.id, aws_security_group.SG-allow_ipv4.id]
  source_dest_check                   = false
  tags = {
        Owner = "dan-via-terraform"
        Name  = "WebSrv1-edge-subnet"
  }
  connection {
          type        	= "ssh"
          user        	= "ec2-user"
          timeout     	= "5m"
          #private_key        = file(local.keypair_name)
          private_key     	= "${tls_private_key.dev_key.private_key_pem}"
          host = aws_instance.WebSrv1-edge-subnet.public_ip
  }
            
 provisioner "remote-exec" {
         inline = ["sudo yum update -y", 
                 "sudo amazon-linux-extras install php8.0 mariadb10.5 -y", 
                 "sudo yum install -y httpd",
                 "sudo systemctl start httpd",
                 "sudo systemctl enable httpd"]
 }   
}

resource "aws_instance" "BastionHost-edge-subnet" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  depends_on 			      = [module.vpc,aws_key_pair.generated_key]
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = true
  subnet_id                           = module.vpc["datacenter1"].public_subnets[0]	# public == edge
  vpc_security_group_ids              = [aws_security_group.SG-inbnd_ssh.id, aws_security_group.SG-inbnd_icmp.id]  #Turn off icmp in production
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "BastionHost-edge-subnet"
    }
}
 	    
resource "aws_instance" "Linux1-server-subnet" {
  ami                                 = "ami-094125af156557ca2"
  instance_type                       = "t2.micro"
  depends_on 				= [module.vpc,aws_key_pair.generated_key]
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  subnet_id                           = module.vpc["datacenter1"].private_subnets[0]	# private == server
  vpc_security_group_ids              = [aws_security_group.SG-inbnd_http.id, aws_security_group.SG-inbnd_icmp.id, aws_security_group.SG-allow_ipv4.id]
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "Linux1-server-subnet"
    }
}
	  
