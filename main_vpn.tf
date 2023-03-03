#  Terraform to add infrastructure configuration to 1 or more Palo Alto VM-NGFWs already deployed from other .tf scripts in this repo. 

resource "aws_instance" "PA-VM-1" {
  ami                                 = local.panos_ami
  #ami                                = local.aws_linux_ami
  instance_type                       = local.panos_inst_type           
  #instance_type                      = local.aws_linux_inst_type           
  key_name                            = "${aws_key_pair.generated_key.key_name}"
  associate_public_ip_address         = false
  private_ip                          = "10.100.0.10"
  subnet_id                           = module.vpc["secvpc"].intra_subnets[0]           #PA-VM mgmt submet
  vpc_security_group_ids              = [aws_security_group.SG-allow_ipv4["secvpc"].id]  
  source_dest_check                   = false
  iam_instance_profile                = aws_iam_instance_profile.ec2_profile.id   # Allow this firewall to get bootstrap config from S3 bucket
  user_data = <<EOF
vmseries-bootstrap-aws-s3bucket=pavm-s3-ds/PA-VM-1
EOF
# didnt work: plugin-op-commands=aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable
  tags = {
          Owner = "dan-via-terraform"
          Name  = "PA-VM-1"
    }
}
  
resource "aws_network_interface" "eth-PA-VM1-vpn" {
  subnet_id             = module.vpc["secvpc"].intra_subnets[2]                 #public subnet side of PA-VM-1(az1), if PA-VM-2 needed, index is [8]
  security_groups       = [aws_security_group.SG-allow_ipv4["secvpc"].id]
  private_ips           = ["10.100.2.11"]  
  source_dest_check     = false                                                 #need this for firewall interfaces
    
  attachment  {
    instance            = aws_instance.PA-VM-1.id
    device_index        = 2
  }
}
  
# Create two EIPs for each PA-VM, one for the mgmt interface, and one for the public-side interface for outbound traffic flows from app-vpcs. 
resource "aws_eip" "PA1-eip-mgmt-int" {
  vpc                   = true
}
resource "aws_eip" "PA1-eip-public-int" {
  vpc                   = true
}

# Associate these EIPs with the specific firewall NICs 
resource "aws_eip_association" "pa1-mgt-assoc" {
  allocation_id         = aws_eip.PA1-eip-mgmt-int.id
  network_interface_id  = aws_instance.PA-VM-1.primary_network_interface_id
}
resource "aws_eip_association" "pa1-pub-assoc" {
  allocation_id         = aws_eip.PA1-eip-public-int.id
  network_interface_id  = aws_network_interface.eth2.id
}

  
