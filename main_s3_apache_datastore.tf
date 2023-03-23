# Terraform script to build an S3 bucket and store configuration files for the Apache webservers in this environment. 

#  Creating an S3 bucket for files to be retrieved by instances
resource "aws_s3_bucket" "webserver-s3-ds" {
  bucket = "webserver-s3-ds"
  
    tags = {
    Name = "webserver-s3-ds"
    Owner = "dan-via-terraform"
  }
}

resource "aws_s3_bucket_acl" "acl-websrv-s3-ds" {
  bucket = aws_s3_bucket.webserver-s3-ds.id
  acl    = "private"
 }

# Set up directories for webserver configuration files:
#    /HTML-80   -> html files for the HTTP servers serving on port 80
#    /HTML-443  -> html files for the HTTPS servers serving on port 443
#    /scripts   -> script repo for multiple purposes 
#    /reserved  -> spare subdirectory for future use without making big changes in scripts 

resource "aws_s3_object" "slash_80" {
  bucket                    = aws_s3_bucket.webserver-s3-ds.id
  key                       = "/HTML-80/"
  content                   = "application/x-directory"
}

resource "aws_s3_object" "slash_443" {
  bucket                    = aws_s3_bucket.webserver-s3-ds.id
  key                       = "/HTML-443/"
  content                   = "application/x-directory"
}

resource "aws_s3_object" "slash_scripts" {
  bucket                    = aws_s3_bucket.webserver-s3-ds.id
  key                       = "/scripts/"
  content                   = "application/x-directory"
}

resource "aws_s3_object" "slash_reserved" {
  bucket                    = aws_s3_bucket.webserver-s3-ds.id
  key                       = "/reserved/"
  content                   = "application/x-directory"
}

# Copy the files from local (pulled down when repo cloned), to the s3 bucket and directories created above

# index.html for port 80/http servers
resource "aws_s3_object" "index80_html" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-80/index.html"
  source                   = "./Webservers/HTML-80/index80.html"
  force_destroy            = true
}

# index.html for port 443/https servers
resource "aws_s3_object" "index443_html" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-443/index.html"
  source                   = "./Webservers/HTML-443/index443.html"
  force_destroy            = true
}

# Palo Alto logo used on both versions of web server
resource "aws_s3_object" "panlogo1" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-443/panlogo.png"
  source                   = "./Webservers/HTML-443/panlogo.png"
  force_destroy            = true
}

# " " " 
resource "aws_s3_object" "panlogo2" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-80/panlogo.png"
  source                   = "./Webservers/HTML-80/panlogo.png"
  force_destroy            = true
}

# Script(s) to pull ec2 metadata and put into www directory to be displayed on web pages 
resource "aws_s3_object" "metascript1" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/scripts/getmetadata.sh"
  source                   = "./Webservers/scripts/getmetadata.sh"
  force_destroy            = true
}
# 
resource "aws_s3_object" "metascriptwhite" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/scripts/getmetadata_white.sh"
  source                   = "./Webservers/scripts/getmetadata_white.sh"
  force_destroy            = true
}
# 
resource "aws_s3_object" "metascriptblack" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/scripts/getmetadata_black.sh"
  source                   = "./Webservers/scripts/getmetadata_black.sh"
  force_destroy            = true
}

# Two config files for apache/httpd to set up ssl/443
resource "aws_s3_object" "sslconf" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-443/ssl.conf"
  source                   = "./Webservers/HTML-443/ssl.conf"
  force_destroy            = true
}
resource "aws_s3_object" "httpdconf" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/HTML-443/httpd.conf"
  source                   = "./Webservers/HTML-443/httpd.conf"
  force_destroy            = true
}
# startup config files for 2 Splunk SIEM servers
resource "aws_s3_object" "splunk1script" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/scripts/splunk1_cfg.sh"
  source                   = "./Webservers/splunk-scripts/splunk1_cfg.sh"
  force_destroy            = true
}
resource "aws_s3_object" "splunk2script" {
  bucket                   = aws_s3_bucket.webserver-s3-ds.id
  key                      = "/scripts/splunk2_cfg.sh"
  source                   = "./Webservers/splunk-scripts/splunk2_cfg.sh"
  force_destroy            = true
}
