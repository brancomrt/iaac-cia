module "slackoapp" {
  source = "./modules/slacko"
  vpc_id = "aws_vpc.vpc_lab01.id"
  ami = "data.aws_ami.slacko-amazon.id"
  shape_slacko = "t2.micro"
  shape_mongodb = "t2.small"
  subnet_id = "aws_subnet.subnet_public_1a.id"
  var_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRnlssVs43Ksq5fKDeOl6kaB3FwlUcXYRbrM79bCJCb1wq3PNPOukyjYms2mYJD+yqYnz4947Jvqsfv6u3tX0K8x1O+xDHkdYN5N1qKBQN6IrtLy+qL8WWHNLW/LMXlMhzOz7OaHVoRyFDbwrlBDWqQ5CbZonVuLTjYlBrmcSSsmApHcDeyWI0TqPS9rB7GcOEONuoKUUyKSKWFo5SHIZv/au/+t4mWCzipZwHccfPOMygeo6npEjZBLJdgwCQkn3dF8EtwCeHDwWicEX8A2tYDLFzg3Q+hTV+WjyQnm+tIOQOcOYYHOp48s+eiyAD0w0N0rC8I+Hm3DaBUmB9xpjt slacko"
  cidr_block_1a = "10.0.101.0/24"  
}

output "slacko-ip" {
  value = module.slackoapp.slacko-app
}

output "mongodb-ip" {
  value = module.slackoapp.slacko-mongodb
}