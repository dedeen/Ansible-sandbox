#  Terraform to create a Splunk Enterprise SIEM server in my Mgmt VPC

locals {
  splunk_ami              = "ami-0b5cb59327b8d7e1f"    # Panorama 10.1.9 from AWS marketplace
  test_linux_ami          = "ami-094125af156557ca2"    # AMI for testing build, routes etc. 
  splunk_inst_type        = "c5.large"                 # Splunk recommendation
  test_linux_inst_type    = "t2.small"                 # max 4 NICs
  }

resource "aws_instance" "Splunk-1" {
  ami                                 = local.splunk_ami
  instance_type                       = local.splunk_inst_type
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.255.1.30"
  subnet_id                           = module.vpc["mgmtvpc"].intra_subnets[1]           #Mgmt VPC AZ1 public subnet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "Splunk-1"
    }
}
# Add one more NIC to the Panorama instance 
resource "aws_network_interface" "ethif-1" {
  subnet_id             = module.vpc["mgmtvpc"].intra_subnets[0]                   #Splunk AZ1 private (internal) subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["mgmtvpc"].id]
  private_ips           = ["10.255.0.30"]     
    
  attachment  {
    instance            = aws_instance.Splunk-1.id
    device_index        = 1
  }
}

################
# Create one EIPs for the public side, and the "Mgmt-public-subnets-RT" route table's default will be the IGW in the vpc
resource "aws_eip" "Splunk1-eip-mgmt-int" {
  vpc                   = true
}

# Associate the EIPs to the public side NICs of Splunk 
resource "aws_eip_association" "splunk-pub-assoc" {
  allocation_id         = aws_eip.Splunk1-eip-mgmt-int.id
  network_interface_id  = aws_instance.Splunk-1.primary_network_interface_id
}
 
