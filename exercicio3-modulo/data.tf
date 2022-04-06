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