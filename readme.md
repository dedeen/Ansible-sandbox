# IaC Scripts for AWS
This repo contains two sets of scripts to create resources in AWS, one set using CloudFormation, and one set using Terraform with AWS modules. 
Dan Edeen, dan@dsblue.net, 2022 

## Overview
The functionality realized by these script sets is as follows: 
*  Create (1) VPC in the AWS Region specified. 
    * Three subnets (public, private with NATGW routes, and intra without NATGW routes)
    * NAT gateway for private subnet to Internet 
    * IGW for public subnet to Internet
    * EIP associated with IGW
    * Routing tables and assocations for VPC
    
*  Generate AWS key pair (RSA) and store as a file in terraform exec directory. 
    * File: terraform_key_pairNNNN.pem (NNNN = random string per run)
    * You must save this file file to access the instances created with this key pair.  
    
*  Create multiple security groups within the VPC.
    * Allow ipv4 traffic to and from public subnet, plus inbound ICMP. 
    * Allow ssh into private subnet from public subnet - ~bastion-like setup. 
    * Allow traffic into intra subnet, only from other subnets in VPC.
    
*  Create (3) linux EC2s, one per subnet (public, private, intra), using keypair for each. 
    * ec2-inst1-public
    * ec2-inst1-private
    * ec2-inst1-intra

*  Create a linux-based webserver in the public subnet: ec2-webserver1, using the same keypair.
    * Via secgrps, allow inbound ssh and icmp, plus outbound ipv4 (needed to install s/w on server)
    * Update linux pkgs, install apache, php,  and mariadb - Terraform uses ssh to access 
      web server using the aforementioned keypair. 
    * Start httpd and configure to auto start via systemctl
    * After launching, you will be able to access Apache test page on the webserver via the instance's public IP address: http://z.y.x.w
    

----------------------------------


## Prerequisites
There are a a few steps to set up the environment: 
* Log in to your AWS environment and launch a CloudShell terminal window. 
* Clone repo to CloudShell, git is already installed. 
* Run *setup.sh*; this will install Terraform and a couple of other useful tools. 
Environment is ready to run Terraform scripts. 

## Running .tf Scripts to Build AWS Infrastructure
1. CD to the directory with .tf scripts and run the following commands. Follow the prompts. Run from the region specified in your provider.tf file. 
2. `$terraform init`
3. `$terraform apply`


## Cleaning up AWS Infrastructure

The scripts contained here apply tags in the provider.tf file. These tags can be searched from 
AWS console or CLI to confirm. When you are finished you should delete the resources created. 

`$terraform destroy`

You can confirm the resources have been deleted by again searching on the tags. 

