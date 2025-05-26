
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


resource "aws_security_group" "worker_sg" {
  name        = "${var.environment}-worker-sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = aws_vpc.main.id

  # SSH allowed only from Control Node or your IP range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # or your admin IP range
  }

  # Allow kubelet API from Control Node (port 10250)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow communication from worker nodes themselves (Pod networking, if using host networking)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow communication to Kubernetes API Server (TCP 6443)
  egress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "worker_nodeport" {
  security_group_id = aws_security_group.worker_sg.id
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Restrict to your IP for security, e.g., ["<your-ip>/32"]
  description       = "Allow NodePort range for Kubernetes services"
}

resource "aws_security_group_rule" "control_nodeport" {
  security_group_id = aws_security_group.control_sg.id
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Restrict to your IP, e.g., ["<your-ip>/32"]
  description       = "Allow NodePort range for Kubernetes services"
}