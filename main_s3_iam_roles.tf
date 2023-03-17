# Now that the bootstrap directories and files are in the s3 bucket, we need to allow the Palo Alto firewalls to access the bucket to bootstrap.
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
