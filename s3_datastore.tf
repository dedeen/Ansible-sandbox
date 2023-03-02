# Terraform script to build an S3 bucket and store configuration files for the Palo Alto firewalls. 

#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "pavm-s3-ds" {
  bucket = "pavm-s3-ds"
  
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

# Set up required bootstrap directory structure 
resource "aws_s3_object" "init_config" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${var.fw_name}/${pan_config_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_content" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${var.fw_name}/${pan_content_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_license" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${var.fw_name}/${pan_license_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_software" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${var.fw_name}/${pan_software_dir}"
      content               = "application/x-directory"
}


#resource "aws_s3_object" "init_cfg" {
#  bucket                  = aws_s3_bucket.pavm-s3-ds.id
#    for_each                = var.pavm_firewalls 
#      key                   = each.value.init_file_key
#      source                = each.value.init_file
#      source_hash           = filemd5(each.value.init_file)
#      etag                  = filemd5(each.value.init_file) # checked on each tf apply and will replace file if changed
#      force_destroy         = true     
#}

#resource "aws_s3_object" "bootstrap_xml" {
#  bucket                  = aws_s3_bucket.pavm-s3-ds.id
#    for_each                = var.pavm_firewalls 
#      key                   = each.value.bootstrap_file_key
#      source                = each.value.bootstrap_file
#      source_hash           = filemd5(each.value.bootstrap_file)
#      etag                  = filemd5(each.value.bootstrap_file) # checked on each tf apply and will replace file if changed
#      force_destroy         = true     
#}



##
