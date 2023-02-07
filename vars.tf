/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2022 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "app_vpcs" {
	description = "VPC Variables"
	type		= map(any)

	default = {
		datacenter1 = {
			region_dc		= 	"App01-VPC"
			cidr			= 	"10.104.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			vpc_subnets		= 	["10.104.0.0/18","10.104.64.0/18"]
			subnet_names		= 	["app1-az1-subnet0","app1-az2-subnet0"]
		},
		datacenter2 = {
			region_dc		= 	"App02-VPC"
			cidr			= 	"10.105.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			vpc_subnets		= 	["10.105.0.0/18","10.105.64.0/18"]
			subnet_names		= 	["app2-az1-subnet0","app2-az2-subnet0"]
		},  
		datacenter3 = {
			region_dc		= 	"Mgmt-VPC"
			cidr			= 	"10.255.0.0/16"
			az_list			= 	["us-west-2a"]
			vpc_subnets		= 	["10.255.0.0/18"]
			subnet_names		= 	["mgmt-az1-subnet0"]
		}  
		datacentersec = {
			region_dc		= 	"Sec01-VPC"
			cidr			= 	"10.100.0.0/16"
			az_list			= 	["us-west-2a","us-west-2a","us-west-2a","us-west-2b","us-west-2b","us-west-2b"]
			vpc_subnets		= 	["10.100.0.0/24","10.100.1.0/24","10.100.2.0/24","10.100.64.0/24","10.100.65.0/24","10.100.66.0/24"]
			subnet_names	= 	["sec-az1-mgt-snet","sec-az1-int-snet","sec-az1-pub-snet","sec-az2-mgt-snet","sec-az2-int-snet","sec-az2-pub-snet"]
		}
	}   
}
##
