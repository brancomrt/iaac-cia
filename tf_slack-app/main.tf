data "aws_ami" "slacko-amazon" {
 most_recent      = true
 owners           = ["amazon"]

 filter {
   name   = "name"
   values = ["amzn2-ami*"]
 }


 filter {
   name   = "architecture"
   values = ["x86_64"]
 }

 filter {
   name   = "virtualization-type"
   values = ["hvm"]
 }

}

resource "aws_vpc" "vpc_lab01" {
  cidr_block            = "10.0.0.0/16"
  instance_tenancy      =   "default"
  enable_dns_support    =   true
  enable_dns_hostnames  =   true

  tags = {
    Name = "vpc_lab01"
  }
}

resource "aws_internet_gateway" "igw_lab01" {
  vpc_id = aws_vpc.vpc_lab01.id

  tags = {
    Name = "igw_lab01"
  }
}

resource "aws_nat_gateway" "nat_lab01" {
  allocation_id = aws_eip.eip_nat_lab01.id
  subnet_id     = aws_subnet.subnet_public_1a.id

  tags = {
    Name = "nat_lab01"
  }

  depends_on = [aws_internet_gateway.igw_lab01]
}

resource "aws_eip" "eip_nat_lab01" {
  vpc      = true
}

resource "aws_route_table" "rtb_pub_lab01" {
  vpc_id = aws_vpc.vpc_lab01.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_lab01.id
      }  

  tags = {
    Name = "rtb_pub_lab01"
  }
}

#resource "aws_route_table" "rtb_priv_lab01" {
#  vpc_id = aws_vpc.vpc_lab01.id
#
#  route {
#        cidr_block = "0.0.0.0/0"
#        gateway_id = aws_nat_gateway.nat_lab01.id
#      }  
#
#  tags = {
#    Name = "rtb_priv_lab01"
#  }
#}

#resource "aws_subnet" "subnet_private_1a" {
#  vpc_id                = aws_vpc.vpc_lab01.id
#  cidr_block            = "10.0.103.0/24"
#  availability_zone_id     = data.aws_availability_zones.az-us-east-1a.zone_ids[0]
#
#  tags = {
#    Name = "subnet_private_1a"
#  }
#}

#resource "aws_subnet" "subnet_private_1b" {
#  vpc_id                = aws_vpc.vpc_lab01.id
#  cidr_block            = "10.0.104.0/24"
#  availability_zone_id     = data.aws_availability_zones.az-us-east-1b.zone_ids[0]
#
#  tags = {
#    Name = "subnet_private_1b"
#  }
#}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.101.0/24"
  availability_zone_id     = data.aws_availability_zones.az-us-east-1a.zone_ids[0]

  tags = {
    Name = "subnet_public_1a"
  }
}
resource "aws_subnet" "subnet_public_1b" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.102.0/24"
  availability_zone_id     = data.aws_availability_zones.az-us-east-1b.zone_ids[0]

  tags = {
    Name = "subnet_public_1b"
  }
}

resource "aws_route_table_association" "pub1a_lab01" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.rtb_pub_lab01.id
}

resource "aws_route_table_association" "pub1b_lab01" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.rtb_pub_lab01.id
}

#resource "aws_route_table_association" "priv1a_lab01" {
#  subnet_id      = aws_subnet.subnet_private_1a.id
#  route_table_id = aws_route_table.rtb_priv_lab01.id
#}

#resource "aws_route_table_association" "priv1b_lab01" {
#  subnet_id      = aws_subnet.subnet_private_1b.id
#  route_table_id = aws_route_table.rtb_priv_lab01.id
#}

resource "aws_key_pair" "slacko-key-ssh" {
 key_name = "slacko-ssh-key"
 public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRnlssVs43Ksq5fKDeOl6kaB3FwlUcXYRbrM79bCJCb1wq3PNPOukyjYms2mYJD+yqYnz4947Jvqsfv6u3tX0K8x1O+xDHkdYN5N1qKBQN6IrtLy+qL8WWHNLW/LMXlMhzOz7OaHVoRyFDbwrlBDWqQ5CbZonVuLTjYlBrmcSSsmApHcDeyWI0TqPS9rB7GcOEONuoKUUyKSKWFo5SHIZv/au/+t4mWCzipZwHccfPOMygeo6npEjZBLJdgwCQkn3dF8EtwCeHDwWicEX8A2tYDLFzg3Q+hTV+WjyQnm+tIOQOcOYYHOp48s+eiyAD0w0N0rC8I+Hm3DaBUmB9xpjt slacko"
}

resource "aws_instance" "slacko-app" {
  ami = data.aws_ami.slacko-amazon.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_public_1a.id
  associate_public_ip_address = true
  key_name = aws_key_pair.slacko-key-ssh.key_name
  user_data = file("ec2.sh")
  tags = {
      Name = "slacko-app"
    }  
}

resource "aws_instance" "slacko-mongodb" {
  ami = data.aws_ami.slacko-amazon.id
  instance_type = "t2.small"
  subnet_id = aws_subnet.subnet_public_1a.id
  associate_public_ip_address = true
  key_name = aws_key_pair.slacko-key-ssh.key_name
  user_data = file("mongodb.sh")  
  tags = {
      Name = "slacko-mongodb"
    }  
}

resource "aws_security_group" "allow-http-ssh" {
name = "allow_http_ssh"
description = "Security group allows SSH and HTTP"
vpc_id = "vpc-039acd663a35661f4"

 ingress = [
    {
      description = "Allowe SSH"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = null
    },

    {
      description = "Allowe HTTP"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = null
    }
 ]

egress = [
 {
   description = "Allowe HTTP"
   from_port = 0
   to_port = 0
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
   ipv6_cidr_blocks = []
   prefix_list_ids = []
   security_groups = []
   self = null
 }      
 ]

 tags = {
      Name = "allow_ssh_http"
  }
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
  security_group_id = aws_security_group.allow-http-ssh.id
  network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

output "slacko-app-ip" {
  value = aws_instance.slacko-app.public_ip
}

output "slacko-mongodb-ip" {
 value = aws_instance.slacko-mongodb.private_ip
}