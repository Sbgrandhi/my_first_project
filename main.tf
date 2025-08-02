provider "aws" {
  region = "us-east-1"
}

# create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}
# create a subnet in the VPC
resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MyPublicSubnet"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MyPrivateSubnet"
  }
}
# create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}
# create a route table for the public subnet
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
# associate the route table with the public subnet
resource "aws_route_table_association" "my_public_route_table_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}
tags = {
  Name = "MyPublicRouteTable"
}
# create a security group for the public subnet
resource "aws_security_group" "my_public_sg" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyPublicSecurityGroup"
  }
}
# allow inbound HTTP and HTTPS traffic
resource "aws_security_group_rule" "allow_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# create a security group for the private subnet
resource "aws_security_group" "my_private_sg" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyPrivateSecurityGroup"
  }
}
# allow inbound SSH traffic from the public security group
resource "aws_security_group_rule" "allow_ssh_from_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my_private_sg.id
  cidr_blocks       = [aws_security_group.my_public_sg.id]
}
# create a NAT gateway in the public subnet
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id    = aws_subnet.my_public_subnet.id
  tags = {
    Name = "MyNATGateway"
  }
}
# create an Elastic IP for the NAT gateway
resource "aws_eip" "my_eip" {
  vpc = true
  tags = {
    Name = "MyEIP"
  }
}
# create a route table for the private subnet
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}
# associate the route table with the private subnet
resource "aws_route_table_association" "my_private_route_table_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}

# create an EC2 instance in the public subnet
resource "aws_instance" "my_public_instance" {
  ami           = "ami-08a6efd148b1f7504"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_public_subnet.id
  security_groups = [aws_security_group.my_public_sg.name]
  associate_public_ip_address = true
  key_name = "my-key" # Ensure you have created this key pair in AWS
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
              systemctl restart httpd
              EOF
  tags = {
    Name = "MyPublicInstance"
  }
}
# create an EC2 instance in the private subnet
resource "aws_instance" "my_private_instance" {
  ami           = "ami-08a6efd148b1f7504"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.my_private_subnet.id
  security_groups = [aws_security_group.my_private_sg.name]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Private Instance!</h1>" > /var/www/html/index.html
              systemctl restart httpd
              EOF
  tags = {
    Name = "MyPrivateInstance"
  }
}