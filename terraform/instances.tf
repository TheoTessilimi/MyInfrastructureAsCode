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
  ami           = var.public_instance_ami
  instance_type = var.public_instance_type
  key_name      = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.public.id
  }

  tags = {
    Name = var.public_instance_name
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.key_path)
    }
    source      = var.key_path
    destination = "/home/ubuntu/${var.key_name}.pem"

  }
}


#Private EC2 for Ansible
resource "aws_instance" "AnsibleControlPlane" {
  ami           = var.ansible_instance_ami
  instance_type = var.ansible_instance_type
  key_name      = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ansible.id
  }

  tags = {
    Name = var.ansible_instance_name
  }

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = self.private_ip
      private_key         = file(var.key_path)
      bastion_user        = "ubuntu"
      bastion_host        = aws_instance.web.public_ip
      bastion_private_key = file(var.key_path)
    }
    source      = "../ansible"
    destination = "/home/ubuntu/ansible"
  }
  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = self.private_ip
      private_key         = file(var.key_path)
      bastion_user        = "ubuntu"
      bastion_host        = aws_instance.web.public_ip
      bastion_private_key = file(var.key_path)
    }
    source      = var.key_path
    destination = "/home/ubuntu/${var.key_name}.pem"
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
  ami           = var.website_instance_ami
  instance_type = var.ansible_instance_type
  key_name      = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.private.id
  }

  tags = {
    Name = var.website_instance_name
  }

}
resource "null_resource" "playbook" {
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/${var.key_name}.pem",
      "export ANSIBLE_HOST_KEY_CHECKING=false",
      "ansible-playbook  -i ${aws_instance.private.private_ip}, --private-key /home/ubuntu/${var.key_name}.pem /home/ubuntu/ansible/nginx.yaml"]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      host                = aws_instance.AnsibleControlPlane.private_ip
      private_key         = file(var.key_path)
      bastion_user        = "ubuntu"
      bastion_host        = aws_instance.web.public_ip
      bastion_private_key = file(var.key_path)
    }
  }
  depends_on = [
    aws_instance.AnsibleControlPlane,
    aws_instance.private,
    aws_instance.web
  ]
}

