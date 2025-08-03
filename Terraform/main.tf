provider "aws" {
    region = variable "aws_region"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id            = aws_vpc.my_vpc.id
    cidr_block        = "10.0.1.0/24"
    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my_igw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
}
resource "aws_route_table_association" "public_route_table_association" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ec2_sg" {
    vpc_id = aws_vpc.my_vpc.id
    name   = "ec2_sg"
    description = "Allow SSH and HTTP access"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_template" "app_lt" {
    name_prefix   = "app_lt_"
    image_id      = var.ami_id
    instance_type = var.instance_type
    key_name      = "my-key" # Replace with your key pair name
    user_data     = file("user_data.sh")
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}

resource "aws_load_balancer" "app_alb" {
    name               = "app_alb"
    load_balancer_type = "application"
    security_groups    = [aws_security_group.ec2_sg.id]
    subnets            = [aws_subnet.public_subnet.id]
}
resource "aws_lb_target_group" "app_tg" {
    name     = "app_tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.my_vpc.id

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}
resource "aws_lb_listener" "app_listener" {
    load_balancer_arn = aws_load_balancer.app_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}

resource "aws_autoscaling_group" "app_asg" {
    launch_template {
        id      = aws_launch_template.app_lt.id
        version = "$Latest"
    }
    vpc_zone_identifier = [aws_subnet.public_subnet.id]
    target_group_arns = [aws_lb_target_group.app_tg.arn]
    health_check_type   = "ELB"
    health_check_grace_period = 300
    min_size            = 1
    max_size            = 3
    desired_capacity    = 2

    tag {
        key                 = "Name"
        value               = "app_instance"
        propagate_at_launch = true
    }
}
