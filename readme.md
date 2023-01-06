# AWS Sandbox Repo
This repo contains work in progress, multi-subnet, multi-vpc deployment with PAN-VM Firewalls. 

Dan Edeen, dan@dsblue.net, 2022 

## Overview (work in progress)
The functionality realized by these script so far. 
*  Build a VPC with 3 subnets, public, private w/NAT, private w/o NAT
*  Build a NACL for each of the 3 subnets 
*  Associate the NACLs to their subnets
*  Build several SecGrps to be used by EC2s 
*  Generate a keypair for EC2s, with a pseudo-random file name (helps with debugging)
*  Launch an EC2 in the public subnet
    *  Add LAMP stack to the instance in the public subnet and configure it to launch httpd. You can browse to the Apache default web page once everything initializes, using the public IP. This config is done by terraform ssh'ing to the EC2. 
*  Launch an EC2 in the private subnet. 
    * This is a bastion host. You can ssh-jump through this host to other VPC-internal resources. 
* Launch a private EC2 in the private subnet (no NAT). 
* Build an S3 bucket to hold files that will be used by the private EC2s. 

... All of the above works, more to follow ...
