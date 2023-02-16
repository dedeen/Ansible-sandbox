# Terraform script to build an S3 bucket for OVA to make an AMI for the firewalls:
#    - create an S3 bucket 
#    - import OVA into the bucket
#You will need to do the following: 
#  1. Run this script to create an S3 bucket for the OVA file
#  2. Copy the source OVA into the S3 bucket
#  3. 
#  ....
#  (later)


#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "ova-filestore" {
  bucket = "ova-filestore"
  
    tags = {
    Name = "ova-filestore"
    Owner = "dan-via-terraform"
  }
}

resource "aws_s3_bucket_acl" "ova-filestore" {
  bucket = aws_s3_bucket.ova-filestore.id
  acl    = "private"
 }

##
