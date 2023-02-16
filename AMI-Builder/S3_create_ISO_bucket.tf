# Terraform script to build an S3 bucket for ISO to make an AMI for the firewalls:
#    - create an S3 bucket 
#    - import OVA into the bucket


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
dje
#  Copy the files to the bucket created above
resource "aws_s3_object" "file1" {
  bucket                  = aws_s3_bucket.terraform-filestore.id
  key                     = "index.html"
  source                  = local.index_file
  source_hash             = filemd5(local.index_file)
  etag                    = filemd5(local.index_file)   # checked on each tf apply and will replace file if changed
  force_destroy           = true 
}
##
