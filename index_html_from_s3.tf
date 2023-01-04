# Terraform script to build an S3 bucket and store index files for the Apache to be installed on my web servers. 
#    to create a multi-subnet VPC with PAN firewall between outside and the internal subnets. Will also create IAM 
#    to allow the instances to retrieve these file(s). 
#         -- Dan Edeen, dan@dsblue.net, 2022  --   

#	To do next 1/1/23 - redefine the main and per subnet route tables  
#

#  Creating an S3 bucket for files that can be retrieved by instances
resource "aws_s3_bucket" "file-store-for-tf" {
  bucket = aws_s3_bucket.tf-copy-file-s3.id
  acl    = "private"
  tags = {
    Name = "S3-filestore"
    Owner = "dan-via-terraform"
  }
}


##
