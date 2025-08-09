provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu" {
  ami           = "ami-0dba2cb6798deb6d8" # Ubuntu 22.04 LTS in us-east-1 (change if needed)
  instance_type = "t2.micro"
  key_name      = "your-ec2-keypair" # Make sure this key pair exists in AWS

  tags = {
    Name = "Ubuntu-Apache-Server"
  }
}

output "public_ip" {
  value = aws_instance.ubuntu.public_ip
}
