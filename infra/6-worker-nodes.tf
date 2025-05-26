resource "aws_instance" "worker_node_1" {
  ami                    = "ami-03250b0e01c28d196"
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 25
  }

  tags = {
    Name = "${var.environment}-worker-node-1"
  }
}

resource "aws_instance" "worker_node_2" {
  ami                    = "ami-03250b0e01c28d196"
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 25
  }

  tags = {
    Name = "${var.environment}-worker-node-2"
  }
}
