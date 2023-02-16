# Terraform script to build an S3 bucket for OVA to make an AMI for the firewalls:
#    - create an S3 bucket 
#    - import OVA into the bucket
#You will need to do the following: 
#  1. Run this script to create an S3 bucket for the OVA file
#  2. Upload the source OVA into the S3 bucket (may take a while for a big file)
#       .... 
#  3. There is a IAM role policy file in the ./AMI-Builder directory named vmimport-trust-policy.json 
#  3a. Run this command to add the role to your account: 
#         aws iam create-role --role-name vmimport --assume-role-policy-document file:///..current dir../AMI_Builder/vmimport-trust-policy.json
#  4. There is another json file in the ./AMI-Builder directory named vmimport-role-policy.json 
#  4a. Run this command to assign it to the vmimport role created previously
#         aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file:///var/tmp/role-policy.json

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
