variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "us-west-2"
}

variables "ami_id" {
    description = "The AMI ID to use for the EC2 instances"
    type        = string
    default     = "ami-08a6efd148b1f7504" # Example AMI ID, replace with your own
}

variable "instance_type" {
    description = "The type of EC2 instance to launch"
    type        = string
    default     = "t3.micro"
}
