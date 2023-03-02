# Terraform script to build an S3 bucket and store configuration files for the Palo Alto firewalls. 

#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "pavm-s3-ds" {
  bucket = "pavm-sd-ds"
  
    tags = {
    Name = "pavm-s3-ds"
    Owner = "dan-via-terraform"
  }
}

resource "aws_s3_bucket_acl" "acl-pavm-s3-ds" {
  bucket = aws_s3_bucket.pavm-s3-ds.id
  acl    = "private"
 }

## Copy bootstrap files to the S3 bucket, firewalls will load from there
resource "aws_s3_object" "init_cfg" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = each.value.init_file_key
      source                = each.value.init_file
      source_hash           = filemd5(each.value.init_file)
      etag                  = filemd5(each.value.init_file) # checked on each tf apply and will replace file if changed
      force_destroy         = true     
}

resource "aws_s3_object" "bootstrap_xml" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = each.value.bootstrap_file_key
      source                = each.value.bootstrap_file
      source_hash           = filemd5(each.value.bootstrap_file)
      etag                  = filemd5(each.value.bootstrap_file) # checked on each tf apply and will replace file if changed
      force_destroy         = true     
}


/*
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
