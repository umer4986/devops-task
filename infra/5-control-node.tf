resource "aws_instance" "control_node" {
  ami                    = "ami-03250b0e01c28d196"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.control_sg.id]
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_instance_profile.name

  root_block_device {
    volume_size = 45
  }

  user_data = file("control_node_user_data.sh")

  tags = {
    Name = "${var.environment}-control-node"
  }
}

resource "aws_eip" "control_node_eip" {
  instance = aws_instance.control_node.id
  tags = {
    Name = "${var.environment}-control-node-eip"
  }
}
