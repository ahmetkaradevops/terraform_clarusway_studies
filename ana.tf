  terraform {
  required_providers {
     aws = {
      source = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow TLS inbound traffic"
  

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "ec2_sg"
  }
}
resource "aws_instance" "my_ec2" {
    ami = data.aws_ami.amazon_ami.id
    instance_type = var.instance_type
    tags = {
        "Name" = "proje_101"
    }
    security_groups = ["ec2_sg"]
    key_name = "seconkey"

    connection {
      host = self.public_ip
      type = "ssh"
      user = "ec2-user"
      private_key = file("seconkey.pem")

    }

    provisioner "remote-exec" {
        inline = [
          "sudo yum update -y",
          "sudo yum install httpd -y",
          "FOLDER=\"https://raw.githubusercontent.com/OsmanBen1681/myproject1.1/main/clarusway/projects/Project-101-kittens-carousel-static-website-ec2/static-web\"",
          "cd /var/www/html",
          "sudo wget $FOLDER/index.html",
          "sudo wget $FOLDER/cat0.jpg",
          "sudo wget $FOLDER/cat1.jpg",
          "sudo wget $FOLDER/cat2.jpg",
          "sudo wget $FOLDER/cat3.png",
          "sudo systemctl start httpd",
          "sudo systemctl enable httpd"
          

        ]
      
    }

    provisioner "local-exec" {
        command = "echo http://${self.public_ip} > public-ip.txt"
      
    }

    
  
}