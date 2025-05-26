resource "aws_security_group" "control_sg" {
  name        = "${var.environment}-control-sg"
  description = "Security group for Kubernetes control plane"
  vpc_id      = aws_vpc.main.id

  # Allow all inbound traffic (can restrict to specific IPs or VPC CIDR)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP for security, e.g., ["<your-ip>/32"]
    description = "Allow all inbound traffic"
  }

  # Allow NodePort range for Kubernetes services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP, e.g., ["<your-ip>/32"]
    description = "Allow NodePort range for Kubernetes services"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-control-sg"
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "${var.environment}-worker-sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = aws_vpc.main.id

  # SSH from VPC CIDR or admin IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow SSH from VPC"
  }

  # Kubelet API from VPC CIDR
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow kubelet API from VPC"
  }

  # Pod networking from VPC CIDR
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow pod networking from VPC"
  }

  # Allow NodePort range for Kubernetes services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP, e.g., ["<your-ip>/32"]
    description = "Allow NodePort range for Kubernetes services"
  }

  # Allow communication to Kubernetes API Server
  egress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow access to Kubernetes API server"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-worker-sg"
  }
}