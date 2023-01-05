# Terraform script to build an S3 bucket and store index files for the Apache to be installed on my web servers. 
#    to create a multi-subnet VPC with PAN firewall between outside and the internal subnets. Will also create IAM 
#    to allow the instances to retrieve these file(s). 
#         -- Dan Edeen, dan@dsblue.net, 2022  --   
#    	https://gmusumeci.medium.com/how-to-upload-files-to-private-or-public-aws-ec2-instances-using-terraform-e62d3c4dd3a6  
#

#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "terraform-filestore" {
  bucket = aws_s3_bucket.terraform-filestore.id
  
    tags = {
    Name = "S3-filestore"
    Owner = "dan-via-terraform"
  }
}

resource "aws_s3_bucket_acl" "terraform-filestore_acl" {
  bucket = aws_s3_bucket.terraform-filestore.id
  acl    = "private"
  
  tags = {
    Name = "S3-filestore"
    Owner = "dan-via-terraform"
  }
}

locals {
  index_file = "source_files/index.html"
  launch_script   = "source_files/launch.sh"
}


##
