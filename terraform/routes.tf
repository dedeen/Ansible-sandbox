#  Terraform to create Route Tables for the ASAv configuration

#   RT for the mgmt subnet - via IGW
resource "aws_route_table" "RT-mgmt-subnet" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          
    gateway_id  = aws_internet_gateway.sec_vpc_igw.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "RT-mgmt-subnet"
  }
}

#  RT for private subnet/zone 
resource "aws_route_table" "RT-private-subnet" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          
    network_interface_id  = aws_network_interface.eth1_2.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "RT-private-subnet"
  }
}

#  RT for dmz subnet/zone 
resource "aws_route_table" "RT-dmz-subnet" {
  vpc_id                = module.vpc["secvpc"].vpc_id 
  route {                                                      
    cidr_block          = "0.0.0.0/0"                          
    network_interface_id  = aws_network_interface.eth1_3.id
  }
  tags = {
    Owner = "dan-via-terraform"
    Name  = "RT-dmz-subnet"
  }
}

