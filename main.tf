provider "aws" {
  region = "us-east-1"
}

# 1. Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# 2. Subnets
resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublicSubnet"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "MyPrivateSubnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# 4. Public Route Table and Association
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "my_public_route_table_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

# 5. Elastic IP (corrected)
resource "aws_eip" "my_eip" {
  domain = "vpc"
  tags = {
    Name = "MyEIP"
  }
}

# 6. NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_public_subnet.id

  tags = {
    Name = "MyNATGateway"
  }
}

# 7. Private Route Table and Association
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "my_private_route_table_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_private_route_table.id
}

# 8. Security Groups

resource "aws_security_group" "my_public_sg" {
  name   = "my-public-sg"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyPublicSecurityGroup"
  }
}

resource "aws_security_group" "my_private_sg" {
  name   = "my-private-sg"
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyPrivateSecurityGroup"
  }
}

# Ingress Rules (correct security group IDs)
resource "aws_security_group_rule" "allow_http" {
  security_group_id = aws_security_group.my_public_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https" {
  security_group_id = aws_security_group.my_public_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_from_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my_private_sg.id
  source_security_group_id = aws_security_group.my_public_sg.id
}

# 9. EC2 Instances

resource "aws_instance" "my_public_instance" {
  ami                         = "ami-08a6efd148b1f7504"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.my_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.my_public_sg.id]
  associate_public_ip_address = true
  key_name                    = "my-key" # make sure this key exists in your AWS account

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "MyPublicInstance"
  }
}

resource "aws_instance" "my_private_instance" {
  ami                    = "ami-08a6efd148b1f7504"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_private_subnet.id
  vpc_security_group_ids = [aws_security_group.my_private_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Private Instance!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "MyPrivateInstance"
  }
}
