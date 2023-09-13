terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

resource "aws_key_pair" "my_public_key" {
  key_name   = "my-public-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtb1Gbc6x9BWjeB2Vko8oo2VwqT5QOaEsXD2q/H0cAp jameswork@helenanamessair.lan"
}

resource "aws_instance" "amazon_linux" {
  count         = 1
  ami           = "ami-04cb4ca688797756f"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_public_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname amazon-${count.index}
    echo 'export PS1="\h$ "' >> /home/ec2-user/.bashrc
    sudo dnf install pip -y
    sudo dnf install git -y
    pip3 install ansible
    cd /home/ec2-user/
    git clone https://github.com/james-borwick/aws-sandbox.git
    EOF

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    "Name" = "amazon-${count.index}"
  }
}

resource "aws_instance" "ubuntu" {
  count         = 1
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.my_public_key.key_name

  # user_data = <<-EOF
  #   #!/bin/bash
  #   hostnamectl set-hostname ubuntu-${count.index}
  #   echo 'export PS1="\h$ "' >> /home/ec2-user/.bashrc
  #   sudo dnf install pip -y
  #   sudo dnf install git -y
  #   pip3 install ansible
  #   cd /home/ec2-user/
  #   git clone https://github.com/james-borwick/aws-sandbox.git
  #   EOF

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    "Name" = "ubuntu-${count.index}"
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Allow SSH"
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
    Name = "allow-ssh"
  }
}
