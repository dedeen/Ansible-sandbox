/*  Terraform variables defined here. 
      Dan Edeen, dan@dsblue.net, 2023 
*/

# VPC parms, can build mutiple by passing in via this map 
variable "app_vpcs" {
	description = "VPC Variables"
	type		= map(any)

	default = {
		secvpc = {		
			map_key			= 	"secvpc"
			region_dc		= 	"Sec01-VPC"
			cidr			= 	"10.100.0.0/16"
			#az_list		= 	["us-west-2a","us-west-2a","us-west-2a","us-west-2a","us-west-2b","us-west-2b","us-west-2b","us-west-2b"]
			#vpc_subnets		= 	["10.100.0.0/24","10.100.1.0/24","10.100.2.0/24","10.100.3.0/24","10.100.64.0/24","10.100.65.0/24","10.100.66.0/24","10.100.67.0/24"]
			#subnet_names		= 	["sec-az1-pub","sec-az1-priv","sec-az1-dmz","sec-az1-mgmt","sec-az2-pub","sec-az2-priv","sec-az2-dmz","sec-az2-mgmt"]
			az_list			= 	["us-west-2a","us-west-2a","us-west-2a","us-west-2a"]
			vpc_subnets		= 	["10.100.0.0/24","10.100.1.0/24","10.100.2.0/24","10.100.3.0/24"]
			subnet_names	= 		["sec-az1-pub","sec-az1-priv","sec-az1-dmz","sec-az1-mgmt"]
		
		}
		
	}   
}

