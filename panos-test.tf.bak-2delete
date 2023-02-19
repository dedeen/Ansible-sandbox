#  Terraform to create EC2s as Palo Alto VM-NGFWs
#    To test all the routes in this environment, run the main_pa-vms_awslinux.tf script. 
#    To build the PAN-OS version for actual firewalls, run this version (main_pa-vms_panos.tf). 
#      The main difference is the AMI used to build the EC2 instances. 
#          Generic AWS linux: "ami-094125af156557ca2"
#          Palo Alto PA-VM firewall: ami-081f4bfe293d7f414

locals {
  panos_ami11           = "ami-081f4bfe293d7f414"
  aws_linux_ami11       = "ami-094125af156557ca2"
  }

resource "aws_instance" "PA-VM-11" {
  #ami                                 = "ami-094125af156557ca2"
  ami                                 = local.panos_ami11
  #instance_type                       = "t2.small"                # max 4 NICs
  instance_type                       = "m5.2xlarge"               # PAN min recommendation
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.100.0.11"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[0]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = false
  tags = {
          Owner = "dan-via-terraform"
          Name  = "PA-VM-11"
    }
}
  
# Add two more NICs to the PA-VM instance 
resource "aws_network_interface" "eth111" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[1]                   #internal (app-vpc side) subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.1.11"]     
    
  attachment  {
    instance            = aws_instance.PA-VM-11.id
    device_index        = 1
  }
}

resource "aws_network_interface" "eth211" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[2]             #public subnet
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.2.11"]      
    
  attachment  {
    instance            = aws_instance.PA-VM-11.id
    device_index        = 2
  }
}
