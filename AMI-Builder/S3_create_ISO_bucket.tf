# Terraform script to build an S3 bucket for OVA to make an AMI for the firewalls:
#    - create an S3 bucket 
#    - import OVA into the bucket
#You will need to do the following: 
#  1. Copy this .tf file up a level to the terraform runtime location
#  2. Copy the source OVA into the .../source_files directory referenced below
#  3. Run this script
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
