#Network Interface
resource "aws_network_interface" "public" {
  subnet_id       = aws_subnet.myPublicSubnet.id
  security_groups = [aws_security_group.myPublicSGSSH.id]

}
resource "aws_network_interface" "private" {
  subnet_id       = aws_subnet.myPrivateSubnet.id
  security_groups = [aws_security_group.myPrivateSGHTTP.id, aws_security_group.myPrivateSGSSH.id]

}
resource "aws_network_interface" "ansible" {
  subnet_id       = aws_subnet.myPrivateSubnet.id
  security_groups = [aws_security_group.myPrivateSGSSH.id]

}

###########################################################################


#public EC2
resource "aws_instance" "web" {
  ami           = "ami-0015a39e4b7c0966f"
  instance_type = "t2.micro"
  key_name      = "london1"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.public.id
  }

  tags = {
    Name = "myPublicInstance"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file("../key/london1.pem")
    }
    source      = "../key/london1.pem"
    destination = "/home/ubuntu/london1.pem"

  }
}


#Private EC2 for Ansible
resource "aws_instance" "AnsibleControlPlane" {
  ami           = "ami-0015a39e4b7c0966f"
  instance_type = "t2.micro"
  key_name      = "london1"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ansible.id
  }

  tags = {
    Name = "AnsibleControlPlane"
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = self.private_ip
      private_key         = file("../key/london1.pem")
      bastion_user        = "ubuntu"
      bastion_host        = aws_instance.web.public_ip
      bastion_private_key = file("../key/london1.pem")
    }
    source      = "../ansible"
    destination = "/home/ubuntu/ansible"
  }
  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = self.private_ip
      private_key         = file("../key/london1.pem")
      bastion_user        = "ubuntu"
      bastion_host        = aws_instance.web.public_ip
      bastion_private_key = file("../key/london1.pem")
    }
    source      = "../key/london1.pem"
    destination = "/home/ubuntu/london1.pem"
  }
  depends_on = [
    aws_instance.private,
  ]

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
  key_name      = "london1"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.private.id
  }

  tags = {
    Name = "myPrivateInstance_1"
  }

}

