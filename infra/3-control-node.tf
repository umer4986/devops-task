resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_instance_profile"
  role = aws_iam_role.ec2_ssm_role.name
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2_ssm_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ssm_policy" {
  name = "ssm_full_access_policy"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:PutParameter",
        "ssm:DeleteParameter",
        "ssm:DeleteParameters"
      ]
      Resource = "*"
    }]
  })
}


resource "aws_security_group" "control_sg" {
  name        = "${var.environment}-control-sg"
  description = "Security group for Kubernetes control plane"
  vpc_id      = aws_vpc.main.id

  # SSH from anywhere (you can restrict to your IP or VPN)
 # Allow all inbound traffic from the VPC CIDR (replace with your actual VPC CIDR)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # e.g. "10.0.0.0/16"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "control_node" {
  ami                    = "ami-03250b0e01c28d196"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.control_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name
  root_block_device {
    volume_size = 45
  }

user_data = <<-EOF
            #!/bin/bash
            set -euo pipefail

            # Update and install dependencies
            apt-get update -y
            apt-get install -y \
              unzip \
              curl \
              software-properties-common \
              gnupg \
              sudo

            # Install AWS CLI v2 (latest)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            ./aws/install
            rm -rf awscliv2.zip aws

            # Install Ansible
            add-apt-repository --yes --update ppa:ansible/ansible
            apt-get install -y ansible

            # Fetch PEM from SSM Parameter Store and write to file
            KEY_PATH="/home/ubuntu/devops-task.pem"
            /usr/local/bin/aws ssm get-parameter \
              --region eu-central-1 \
              --name "/dev/devops-task/private" \
              --with-decryption \
              --query "Parameter.Value" \
              --output text > "$KEY_PATH"

            # Set correct permissions
            chmod 400 "$KEY_PATH"
            chown ubuntu:ubuntu "$KEY_PATH"

            # Optional logging
            echo "[INFO] AWS CLI v2, Ansible, and PEM key setup completed" >> /var/log/user-data.log
            EOF


  tags = {
    Name = "${var.environment}-control-node"
  }
}
