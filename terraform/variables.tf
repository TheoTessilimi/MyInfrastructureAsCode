##################################
#          Global
##################################
variable "region" {
  type        = string
  nullable    = false
  description = "name of the region in aws"
}
variable "key_path" {
  type        = string
  nullable    = false
  description = "Relative or absolute key_path for your instance"
}
variable "key_name" {
  type        = string
  nullable    = false
  description = "The name of the key for your instance (take care tyo have the key in your possesion)"
}
##################################
#          VPC
##################################
variable "vpc_name" {
  type        = string
  nullable    = false
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  nullable    = false
  description = "cidr block of the vpc "
}
##################################
#        Public Subnet
##################################
variable "public_subnet_name" {
  type        = string
  nullable    = false
  description = "Name of the public subnet"
}
variable "public_subnet_cidr" {
  type        = string
  nullable    = false
  description = "cidr block of the public subnet"
}
variable "public_subnet_availability_zone" {
  type        = string
  nullable    = false
  description = "availability zone of the public subnet"
}
##################################
#        Private Subnet
##################################
variable "private_subnet_name" {
  type        = string
  nullable    = false
  description = "Name of the private subnet"
}
variable "private_subnet_cidr" {
  type        = string
  nullable    = false
  description = "cidr block of the private subnet"
}
variable "private_subnet_availability_zone" {
  type        = string
  nullable    = false
  description = "availability zone of the private subnet"
}
##################################
#        Public EC2 Instance
##################################
variable "public_instance_ami" {
  type        = string
  nullable    = false
  description = "ami of the public instance"
}
variable "public_instance_type" {
  type        = string
  nullable    = false
  description = "Type of the public instance"
}
variable "public_instance_name" {
  type        = string
  nullable    = false
  description = "Name of your public instance"
}

##################################
#Private EC2 Instance for Ansible
##################################
variable "ansible_instance_ami" {
  type        = string
  nullable    = false
  description = "ami of the ansible instance"
}
variable "ansible_instance_type" {
  type        = string
  nullable    = false
  description = "Type of the ansible instance"
}
variable "ansible_instance_name" {
  type        = string
  nullable    = false
  description = "Name of your ansible instance"
}

##################################
#Private EC2 Instance for Website
##################################
variable "website_instance_ami" {
  type        = string
  nullable    = false
  description = "ami of the website instance"
}
variable "website_instance_type" {
  type        = string
  nullable    = false
  description = "Type of the website instance"
}
variable "website_instance_name" {
  type        = string
  nullable    = false
  description = "Name of your website instance"
}
