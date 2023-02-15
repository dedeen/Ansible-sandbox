# Terraform script to build an S3 bucket ans associate IAM role(s) to use it as follows: 
#    - import OVA into the bucket
#    - create EC2 instance 
#    - create AMI from EC2 instance. 
#         -- Dan Edeen, dan@dsblue.net, 2022  --   


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

# EC2 instance profile 
resource "aws_iam_instance_profile" "ec2_profile" {
   name = "ec2-profile"
   role = aws_iam_role.ec2_iam_role.name
 }

# Policy attachments (2) 
resource "aws_iam_policy_attachment" "ec2_attach1" {
  name       = "ec2-iam-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "ec2_attach2" {
  name       = "ec2-iam-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# S3 policy - allows all operations --> should tighten this for production use 
resource "aws_iam_policy" "s3-ec2-policy" {
  name        = "s3-ec2-policy"
  description = "S3 ec2 policy"
  
  policy = jsonencode({  
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attach S3 Policies to Instance Role
resource "aws_iam_policy_attachment" "s3_attach" {
  name       = "s3-iam-attachment"
  roles      = [aws_iam_role.ec2_iam_role.id]
  policy_arn = aws_iam_policy.s3-ec2-policy.arn
}
##
