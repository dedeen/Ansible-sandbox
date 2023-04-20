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

# Set up required bootstrap directory structure: /config, /content, /license, /software are mandatory dirs for PAN bootstrap to function 
resource "aws_s3_object" "init_config" {
  bucket                    = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${each.value.fw_name}/${each.value.config_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_content" {
  bucket                    = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${each.value.fw_name}/${each.value.content_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_license" {
  bucket                    = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${each.value.fw_name}/${each.value.license_dir}"
      content               = "application/x-directory"
}

resource "aws_s3_object" "init_software" {
  bucket                    = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "${each.value.fw_name}/${each.value.software_dir}"
      content               = "application/x-directory"
}

# Copy the (2) bootstrap files to the S3 bucket, and firewalls will use to bootstrap their configs
resource "aws_s3_object" "init_cfg_txt" {
  bucket                    = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "/${each.value.fw_name}/${each.value.config_dir}${each.value.init_file_key}"
      source                = "${each.value.init_file}"
      force_destroy         = true     
}

resource "aws_s3_object" "bootstrap_xml" {
  bucket                  = aws_s3_bucket.pavm-s3-ds.id
    for_each                = var.pavm_firewalls 
      key                   = "/${each.value.fw_name}/${each.value.config_dir}${each.value.bootstrap_file_key}"
      source                = "${each.value.bootstrap_file}"
      force_destroy         = true     
}

##
