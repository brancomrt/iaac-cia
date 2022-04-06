module "slackoapp" {
  source = "./modules/slacko"
  vpc_id = "vpc-0115ba491a1259899"
  vpc_cidr = "10.0.0.0/16"
  subnet_cidr = "10.0.101.0/24"  
  ami = "ami-0a7142c6caf12ec25"
  shape_slacko = "t2.micro"
  shape_mongodb = "t2.small"
  subnet_id = "subnet-0741b0e1f0ad7cae7"
  var_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRnlssVs43Ksq5fKDeOl6kaB3FwlUcXYRbrM79bCJCb1wq3PNPOukyjYms2mYJD+yqYnz4947Jvqsfv6u3tX0K8x1O+xDHkdYN5N1qKBQN6IrtLy+qL8WWHNLW/LMXlMhzOz7OaHVoRyFDbwrlBDWqQ5CbZonVuLTjYlBrmcSSsmApHcDeyWI0TqPS9rB7GcOEONuoKUUyKSKWFo5SHIZv/au/+t4mWCzipZwHccfPOMygeo6npEjZBLJdgwCQkn3dF8EtwCeHDwWicEX8A2tYDLFzg3Q+hTV+WjyQnm+tIOQOcOYYHOp48s+eiyAD0w0N0rC8I+Hm3DaBUmB9xpjt slacko"
}

output "slacko-ip" {
  value = module.slackoapp.slacko-app
}

output "mongodb-ip" {
  value = module.slackoapp.slacko-mongodb
}
