output "instance_public_ip" {
  value = aws_instance.ec2-server.public_ip
}

output "instance_private_ip" {
  value = aws_instance.ec2-server.private_ip
}