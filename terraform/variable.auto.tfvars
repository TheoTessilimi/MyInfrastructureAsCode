#create a file "secrets.tfvars" to configure private variables)
#and add the next lines
#access_key = "value"
#secret_key = "value"

#Global

region = "eu-west-2"
key_path = "../key/london1.pem"
key_name = "london1"

#VPC

vpc_name = "myVPC"
vpc_cidr = "192.168.0.0/16"

#Public Subnet

public_subnet_name = "myPublicSubnet"
public_subnet_cidr = "192.168.0.0/20"
public_subnet_availability_zone = "eu-west-2a"

#Private subnet 

private_subnet_name = "myPrivateSubnet"
private_subnet_cidr = "192.168.16.0/20"
private_subnet_availability_zone = "eu-west-2b"

#Public EC2 Instance

public_instance_name = "myPublicInstance"
public_instance_ami = "ami-0015a39e4b7c0966f"
public_instance_type = "t2.micro"

#Private EC2 Instance for Ansible

ansible_instance_name = "AnsibleControlPlane"
ansible_instance_ami = "ami-0015a39e4b7c0966f"
ansible_instance_type = "t2.micro"

#Private Instance for Website

website_instance_name = "myPrivateInstance_1"
website_instance_ami = "ami-0015a39e4b7c0966f"
website_instance_type = "t2.micro"