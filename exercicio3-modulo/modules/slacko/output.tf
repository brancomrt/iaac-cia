output "slacko-app" {
    value = aws_instance.slacko-app.public_ip
}

output "slacko-mongodb" {
    value = aws_instance.slacko-mongodb.private_ip
}