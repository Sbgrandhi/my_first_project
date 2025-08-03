variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
  default     = "ami-08a6efd148b1f7504" # Change this to match your AWS region
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Your EC2 key pair name"
  default     = "my-key" # Replace with your actual key pair name
}
