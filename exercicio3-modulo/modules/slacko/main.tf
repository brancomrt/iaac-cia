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
  vpc_id = var.vpc_id

  tags = {
    Name = "igw_lab01"
  }
}

resource "aws_nat_gateway" "nat_lab01" {
  allocation_id = aws_eip.eip_nat_lab01.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "nat_lab01"
  }

  depends_on = [aws_internet_gateway.igw_lab01]
}

resource "aws_eip" "eip_nat_lab01" {
  vpc      = true
}

resource "aws_route_table" "rtb_pub_lab01" {
  vpc_id = var.vpc_id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_lab01.id
      }  

  tags = {
    Name = "rtb_pub_lab01"
  }
}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr
  availability_zone_id = data.aws_availability_zones.az-us-east-1a.zone_ids[0]

  tags = {
    Name = "subnet_public_1a"
  }
}

resource "aws_route_table_association" "pub1a_lab01" {
  subnet_id = var.subnet_id
  route_table_id = aws_route_table.rtb_pub_lab01.id
}

resource "aws_key_pair" "slacko-key-ssh" {
 key_name = "slacko-ssh-key"
 public_key = var.var_public_key
}

resource "aws_instance" "slacko-app" {
  ami = var.ami
  instance_type = var.shape_slacko
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.slacko-key-ssh.key_name
  user_data = file ("${path.module}/files/ec2.sh") 
  tags = {
      Name = "slacko-app"
    }  
}

resource "aws_instance" "slacko-mongodb" {
  ami = var.ami
  instance_type = var.shape_mongodb
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  key_name = aws_key_pair.slacko-key-ssh.key_name
  user_data = file ("${path.module}/files/ec2.sh")   
  tags = {
      Name = "slacko-mongodb"
    }  
}

resource "aws_security_group" "allow-http-ssh" {
name = "allow_http_ssh"
description = "Security group allows SSH and HTTP"
vpc_id = var.vpc_id

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

resource "aws_security_group" "allow-mongodb"{
    name = "allow_mongodb"
    description = "Allow MongoDb"
    vpc_id = var.vpc_id

    ingress = [
        {
            description = "Allow MOngoDB"
            from_port = 27017
            to_port = 27017
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null

        }
    ]
    egress = [
        {
            description = "Allow all"
            from_port = 0
            to_port = 0
            protocol = "all"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null

        }

    ]

    tags = {
        Name = "allow_mongodb"
    }
}

resource "aws_network_interface_sg_attachment" "slacko-sg" {
  security_group_id = aws_security_group.allow-http-ssh.id
  network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "mongo-sg" {
    security_group_id = aws_security_group.allow-mongodb.id
    network_interface_id = aws_instance.slacko-mongodb.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
    name = "iaac07.com.br"
    vpc{
        vpc_id = var.vpc_id
    }

}

resource "aws_route53_record" "mongodb" {
    zone_id = aws_route53_zone.slack_zone.id
    name = "mongodb.iaac07.com.br"
    type = "A"
    ttl = "3600"
    records = [aws_instance.slacko-mongodb.private_ip]
}
