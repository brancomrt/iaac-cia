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

resource "aws_route_table" "rtb_priv_lab01" {
  vpc_id = aws_vpc.vpc_lab01.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_lab01.id
      }  

  tags = {
    Name = "rtb_priv_lab01"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.100.0/24"
  availability_zone_id     = data.aws_availability_zones.az1a.zone_ids[0]

  tags = {
    Name = "subnet_private_1a"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.101.0/24"
  availability_zone_id     = data.aws_availability_zones.az1b.zone_ids[0]

  tags = {
    Name = "subnet_private_1b"
  }
}
resource "aws_subnet" "subnet_public_1a" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.102.0/24"
  availability_zone_id     = data.aws_availability_zones.az1a.zone_ids[0]

  tags = {
    Name = "subnet_public_1a"
  }
}
resource "aws_subnet" "subnet_public_1b" {
  vpc_id                = aws_vpc.vpc_lab01.id
  cidr_block            = "10.0.103.0/24"
  availability_zone_id     = data.aws_availability_zones.az1b.zone_ids[0]

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

resource "aws_route_table_association" "priv1a_lab01" {
  subnet_id      = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.rtb_priv_lab01.id
}

resource "aws_route_table_association" "priv1b_lab01" {
  subnet_id      = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.rtb_priv_lab01.id
}
#data "aws_subnet" "subnet_public_1a" {
#   cidr_block = "10.0.103.0/24"
#}

resource "aws_key_pair" "slacko-key-ssh" {
 key_name = "slacko-ssh-key"
 public_key = "ssh-rsa MIIEpAIBAAKCAQEAkZ5bLFbONyrKuXyg3jpepGgdxcJVHF2EW6zO/WwiQm9cKtzzTzrpMo2JrNpmCQ/sqmJ8+PeOyb6rH7+rt7V9CvMdTvsQx5HWDeTdaigUDeiK7S8vqi/FlhzS1vyzF5TIczs+zmh1aEchQ28K5QQ1qkOQm2aJ1bi042JQa5nEkrJgKR3A3sliNE6j0vawexnDhDjbqClFMikilhaOUhyGb/2rv/reJlgs4qWcB3HHzzjMoHqOp6RI2QSyXYMAkJJ93RfBLcAnhw8FonBF/ANrWAyxc4N0PoU1flo8kJ5vrSDkDnDmGBzqePLPnosgA9MNDdKwvCPh5tw2gVJgfcaY7QIDAQABAoIBAGPGloAeBnREbN2FaJB8fCa4dFXxnvGtnihWkwmP0zWkKgnwlQJfwjNySbhXePySnb3td+X7cioH7Cb35QgeYcxj4lwgqVGlOn8Qpym6xmr1QGPeJhG9Y+xEWa8XPPtWZbaXDKTPbEsEGeWjq1padQ7x9p6UNrNrOP5oeeQQW2GLrCLc50LRZye9qSgncmN6H5mayWFGLa8i3Gjvjz0X7wiyAiciqnLkPg5zqgOOUrUouoB7aL1azqn/o60HjuCqJiSqhgnwY4ldkGErKaXPhj1UeyS/qrYmEhDLwLaz1IFRl0VM052puJcxBPgpg0vSGa+PHrhjXqLdrGSZFjq2qr0CgYEA6LWLZkknYu2wc3X6d8qRC/oaG/FFzpOtMQawtkGvJ779Cc5Jw4d2tvOuKgCB3ZLY3uyKHJj+BD4AlEBojTwgFJzi1CvtIQQsucTeMUDY7xb/0yr6I87+zjFKWjHpHhmIJUy5XijHxVJ+YWQ8Pj0fW4qE3Z4ZJsLnFzFcAJDaJvMCgYEAoDFiPMJEaqnQp3H3hsgB7ffCEa0eoiwe2Z+FLN+DJwM6BlBSjni80jXafN524gMp2IXTMV1OxprU+QxUclBXk/aTVD+LuKTMVnzkKfebLlLDvtvJYOmQ4W7EVqHLLMDg6Od9naQnECd6PSisJAfJgJP/VqVr1yXTXZxKEip/+J8CgYEAioyEGXsWexz/AE9Ot4GgSBw47UgCAtMDu3u7PFfxG93nM65hVovRj22X1SQGLdCfVGJKfGpOWmI74AhU9znD8+HQXvhkL1MX+eaPT43HWto7qBMfaLB2HndUSE0M+UHEQEjk2H25Ku9JlVyjTX8Aq3TWVEgru1sxUSqvFxsm9ycCgYA/qEAsetprNH4o/B3r3nD92pWxJoVk1nmP61clpNBeYWbeeW7FFO+b7TCcrF67o5wuYcex9y1FuONm8GJiZtDWiIa1VOc2Aa79s3WLw8xT1SnaH0bgDxC2tKiq8HJnn2IAy3Tcfw3S2o013oLBcqK9SJKQIP5AqdRbf67jlyXxawKBgQDWC+XyRvbCeGoGW3JBpf3OmtUIPdzcJhXLvRcfVJh7uBHeGPMeBWBre9LvR95y4NbF7EdRPzXmT1sa1GYLHpIRtt8amp/jGfE2WOonqSWv0gsHUE9ae0/dGifn0xkoVG5ukw4ZlpBtxQO2THx9lryCDYYSEuta7r8M2addddBP1g== slacko"
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
vpc_id = "vpc-0c07086c5f321dfd6"

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

output "slacko-app-IP" {
  value = aws_instance.slacko-app.public_ip
}

output "slacko-mongodb-ip" {
 value = aws_instance.slacko-mongodb.private_ip
}