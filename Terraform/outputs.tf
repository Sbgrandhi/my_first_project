outputs "alb_dns_name" {
  value = aws_load_balancer.app_alb.dns_name
}
  description = "The DNS name of the Application Load Balancer"
}