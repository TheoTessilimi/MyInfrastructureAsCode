output "public_ip" {
  description = "Public Ip of myPublicInstance"
  value = aws_instance.web.public_ip
}
output "private_ip" {
  description = "Private Ip of myPrivateInstance"
  value = aws_instance.private.private_ip
}
output "Ansible_ip" {
  description = "Private Ip of AnsibleControlPlane"
  value = aws_instance.AnsibleControlPlane.private_ip 
}