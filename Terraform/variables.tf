variable "aws_region" {
  default = "us-east-1"
}

<<<<<<< HEAD
variables "ami_id" {
    description = "The AMI ID to use for the EC2 instances"
    type        = string
    default     = "ami-08a6efd148b1f7504" # Example AMI ID, replace with your own
}

variable "instance_type" {
    description = "The type of EC2 instance to launch"
    type        = string
    default     = "t3.micro"
=======
variable "ami_id" {
  description = "AMI for EC2 instance"
  default     = "ami-0c55b159cbfafe1f0" # Change for your region
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Your EC2 key pair name"
  default     = "my-key" # Replace with your actual key pair
>>>>>>> 67b96f7 (Added Terraform VPC + ALB + ASG deployment)
}
