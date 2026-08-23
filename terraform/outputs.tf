output "instance_id" {
  description = "ID of the webtext-app EC2 instance."
  value       = aws_instance.webtext_app.id
}

output "public_ip" {
  description = "Public IP address of the webtext-app VM."
  value       = aws_instance.webtext_app.public_ip
}

