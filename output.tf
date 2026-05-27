# print app instance ip
output "public_ip" {
  value = aws_instance.public_instance.public_ip
}

# print db instance ip
output "private_ip" {
  value = aws_instance.private_instance.private_ip
}

# print instance ids
output "public_instance_id" {
  value = aws_instance.public_instance.id
}
output "private_instance_id" {
  value = aws_instance.private_instance.id
}
