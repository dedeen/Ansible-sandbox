# Terraform script to build an S3 bucket and store index files for the Apache to be installed on my web servers. 
#    to create a multi-subnet VPC with PAN firewall between outside and the internal subnets. Will also create IAM 
#    to allow the instances to retrieve these file(s). 
#    	Key insights from https://gmusumeci.medium.com/how-to-upload-files-to-private-or-public-aws-ec2-instances-using-terraform-e62d3c4dd3a6  
#         -- Dan Edeen, dan@dsblue.net, 2022  --   
#

#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "terraform-filestore" {
  bucket = "terraform-filestore"
  
    tags = {
    Name = "S3-filestore"
    Owner = "dan-via-terraform"
  }
}

resource "aws_s3_bucket_acl" "terraform-filestore" {
  bucket = aws_s3_bucket.terraform-filestore.id
  acl    = "private"
 }

locals {
  index_file      = "source_files/index.html"
  launch_script   = "source_files/launch_script.sh"
}

#  Copy the files to the bucket created above
resource "aws_s3_object" "file1" {
  bucket                  = aws_s3_bucket.terraform-filestore.id
  key                     = "index.html"
  source                  = local.index_file
  source_hash             = filemd5(local.index_file)
  etag                    = filemd5(local.index_file)   # checked on each tf apply and will replace file if changed
  force_destroy           = true 
}
 
#  Copy the files to the bucket created above
resource "aws_s3_object" "file2" {
  bucket                  = aws_s3_bucket.terraform-filestore.id
  key                     = "launch_script.sh"
  source                  = local.launch_script
  source_hash             = filemd5(local.launch_script)
  etag                    = filemd5(local.launch_script)    # " " " 
  force_destroy           = true 
}

#  IAM policy & role for the EC2 instances to access files on the datastore 
data "aws_iam_policy_document" "ec2_assume_role" { 
  statement {
     actions = ["sts:AssumeRole"]
    
     principals {
       type        = "Service"
       identifiers = ["ec2.amazonaws.com"]
     }
   }
 }

# IAM Role associated with the policy document created above 
 resource "aws_iam_role" "ec2_iam_role" {
   name                = "ec2-iam-role"
   path                = "/"
   assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role.json
 }



##
