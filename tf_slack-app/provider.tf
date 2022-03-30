provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "az-us-east-1a" {
   filter {
     name = "zone-name"
     values = ["us-east-1a"]
   }
}

data "aws_availability_zones" "az-us-east-1b" {
  filter {
     name = "zone-name"
     values = ["us-east-1b"]
   }
}