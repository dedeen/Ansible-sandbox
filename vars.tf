/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2022 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "app_vpcs" {
	description = "DC parms for Oregon VPCs"
	type		= map(any)

	default = {
		datacenter1 = {
			region_dc		= 	"App01-VPC"
			cidr			= 	"10.104.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			vpc_subnets		= 	["10.104.0.0/18","10.104.64.0/18"]
			subnet_names		= 	["subnet_104_0_0","subnet_104_64_0"]
			 
		} ;
		
		datacenter2 = {
			region_dc		= 	"App02-VPC"
			cidr			= 	"10.105.0.0/16"
			az_list			= 	["us-west-2a","us-west-2b"]
			vpc_subnets		= 	["10.105.0.0/18","10.105.64.0/18"]
			subnet_names		= 	["subnet_105_0_0","subnet_105_64_0"]
		}  
	}   
}
##



