/*  Terraform provider for AWS defined here. 
      Dan Edeen, dan@dsblue.net, 2022 
*/

provider "aws" {
  alias = "usw2"
  region = "us-west-2"

  default_tags {
    tags = {
      Owner = "dan-via-terraform"
    }
  }
}




