terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

}

# Create a VPC
resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}
#Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "main"
  }
}

#Create public subnet

resource "aws_subnet" "myPublicSubnet" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.public_subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnet_name
  }
}

#Create private subnet

resource "aws_subnet" "myPrivateSubnet" {
  vpc_id            = aws_vpc.myVPC.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_subnet_availability_zone

  tags = {
    Name = var.private_subnet_name
  }
}
#elasticIP
resource "aws_eip" "one" {
  vpc = true

}

#Nat Gateway
resource "aws_nat_gateway" "natPrivate" {
  allocation_id = aws_eip.one.id
  subnet_id     = aws_subnet.myPublicSubnet.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [
    aws_internet_gateway.gw
  ]
}

#public routing table

resource "aws_route_table" "publicRoutingTable" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "publicRoutingTable"
  }
}

#private routing table

resource "aws_route_table" "privateRoutingTable" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natPrivate.id

  }


  tags = {
    Name = "privateRoutingTable"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.myPublicSubnet.id
  route_table_id = aws_route_table.publicRoutingTable.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.myPrivateSubnet.id
  route_table_id = aws_route_table.privateRoutingTable.id
}


#private allow HTTP security group
resource "aws_security_group" "myPrivateSGHTTP" {
  name        = "privateSGHTTP"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.myVPC.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "privateSG Allow HTTP"
  }
}

#private allow SSH security group
resource "aws_security_group" "myPrivateSGSSH" {
  name        = "privateSGSSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.myVPC.cidr_block]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "privateSG Allow SSH"
  }
}

#public allow SSH security group 

resource "aws_security_group" "myPublicSGSSH" {
  name        = "publicSGSSH"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "publicSG Allow SSH"
  }
}

#public security group 

resource "aws_security_group" "myPublicSGHTTP" {
  name        = "publicSGHTTP"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "publicSG Allow HTTP"
  }
}




