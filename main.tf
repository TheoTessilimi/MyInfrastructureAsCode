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
    region = "eu-west-2"
    access_key = var.access_key
    secret_key = var.secret_key

}

# Create a VPC
resource "aws_vpc" "myVPC" {
    cidr_block = "192.168.0.0/16"

    tags = {
        Name = "myVPC"
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
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "192.168.0.0/20"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "myPublicSubnet"
  }
}

#Create private subnet

resource "aws_subnet" "myPrivateSubnet" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "192.168.16.0/20"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "myPrivateSubnet"
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

#private security group
resource "aws_security_group" "myPrivateSG" {
  name        = "privateSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.myVPC.cidr_block]

  }
    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.myVPC.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "privateSG"
  }
}

#public security group 

resource "aws_security_group" "myPublicSG" {
  name        = "publicSG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
    ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "publicSG"
  }
}
resource "aws_network_interface" "public" {
  subnet_id       = aws_subnet.myPublicSubnet.id
  security_groups = [aws_security_group.myPublicSG.id]

}
resource "aws_network_interface" "private" {
  subnet_id       = aws_subnet.myPrivateSubnet.id
  security_groups = [aws_security_group.myPrivateSG.id]

}
resource "aws_network_interface" "ansible" {
  subnet_id       = aws_subnet.myPrivateSubnet.id
  security_groups = [aws_security_group.myPrivateSG.id]

}

#public EC2

resource "aws_instance" "web" {
    ami           = "ami-0015a39e4b7c0966f"
    instance_type = "t2.micro"
    key_name = "london1"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.public.id
    }

    tags = {
        Name = "myPublicInstance"
    }

}

#Private EC2 for Ansible
resource "aws_instance" "AnsibleControlPlane" {
    ami           = "ami-0015a39e4b7c0966f"
    instance_type = "t2.micro"
    key_name = "london1"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.ansible.id
    }

    tags = {
        Name = "AnsibleControlPlane"
    }
    user_data = <<-EOF
                    #!/bin/bash
                    sudo apt update -y
                    sudo apt install software-properties-common -y
                    sudo add-apt-repository --yes --update ppa:ansible/ansible-2.9 -y
                    sudo apt install ansible=2.9.6+dfsg-1 -y        
                    EOF
}


#Private EC2

resource "aws_instance" "private" {
    ami           = "ami-0015a39e4b7c0966f"
    instance_type = "t2.micro"
    key_name = "london1"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.private.id
    }

    tags = {
        Name = "myPrivateInstance_1"
    }
    user_data = <<-EOF
                    #!/bin/bash
                    sudo apt update -y
                    sudo apt install nginx -y
                    sudo systemctl restart nginx
                    sudo bash -c 'echo Coucou je m'appelle theo' > /var/www/html/index.html
                    EOF
}


#target group
resource "aws_lb_target_group" "test" {
  name     = "PrivateTargetInstance"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myVPC.id
  target_type = "instance"
  health_check {
    interval = 30
    matcher = "200,202"
    port = 80
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 3
  }
}
#Attach target to lb
resource "aws_alb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.private.id
  port             = 80
}

#LoadBalancer
resource "aws_lb" "test" {
  name               = "PrivateLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myPublicSG.id]
  subnets            = [aws_subnet.myPublicSubnet.id, aws_subnet.myPrivateSubnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

#listenerLB
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.test.arn
  port = 80

  default_action {
    target_group_arn = aws_lb_target_group.test.arn
    type             = "forward"
  }
}
