
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {}

provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.AWS_REGION}"
}

resource "aws_key_pair" "greg-key" {
  key_name   = "greg-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDf/pZJe2IPCdtBIbhbH9W+ntPPECAh+8DBg3tutPzjf6Pv0Tc9lS/u5HUT3TM0GuWNt9N/9vYR0qvL1efJ7gDN1g0KP01O4Z/YelcZL34ZnWYK8kbOcIQXk5hHzM2hIFpD6v7WLdVX6qoeJsJcZczEJ9cUQG2vhifT6Bt0PFoPZh7tqUOSPN9C1CRImDgFsj042N2YMbIBGbDvEsqL7p7SxfedeSvGtoJOS+zpJl6yJn5bnjPLi5Sk8B1FHpxeTnGnjSHQxOwYZEb7a0NA7oilK9e9Damj1LK5kp/UPN4ZdyA8FBYJRo0hdVmGsDpzogTOFGLknZ8BEEaiMjR7tY/p greggel@fugitive.home"
}

resource "aws_instance" "example" {
  ami           = "ami-26950f4f"
  instance_type = "t1.micro"
  key_name = "${aws_key_pair.greg-key.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-role.name}"
  tags {
   Name = "Test Instance"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allowLimited"
  description = "Allow all inbound traffic to http, https and ssh to a specific user"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["67.82.67.17/32"]  
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "raise-s3" {
    image_id = "ami-26950f4f"
    instance_type = "t1.micro"
    lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_policy" "raise-policy" {
  name = "raise-policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.raise-group.name}"
  lifecycle { create_before_destroy = true }
}

resource "aws_autoscaling_group" "raise-group" {
  availability_zones        = ["us-east-1a"]
  name                      = "raise-test1"
  max_size                  = 5
  min_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.raise-s3.name}"
  force_delete = true
}

