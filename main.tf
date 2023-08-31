terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtb1Gbc6x9BWjeB2Vko8oo2VwqT5QOaEsXD2q/H0cAp jameswork@helenanamessair.lan"
}

resource "aws_instance" "my_instance" {
  count         = 2
  ami           = "ami-051f7e7f6c2f40dc1"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname my-instance-${count.index}
    echo 'export PS1="\h$ "' >> /home/ec2-user/.bashrc
    sudo dnf install pip -y
    sudo dnf install git -y
    pip3 install ansible
    EOF

  tags = {
    "Name" = "my-instance-${count.index}"
  }
}
