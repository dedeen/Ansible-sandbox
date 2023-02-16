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

locals {
  ova_inbound      = "source_files/PA-VM-ESX-10.1.0"
 }

#  Copy the files to the bucket created above
resource "aws_s3_object" "file1" {
  bucket                  = aws_s3_bucket.ova-filestore.id
  key                     = "firewall_ova"
  source                  = local.ova_inbound
  source_hash             = filemd5(local.ova_inbound)
  etag                    = filemd5(local.ova_inbound)   # checked on each tf apply and will replace file if changed
  force_destroy           = true 
}
##
