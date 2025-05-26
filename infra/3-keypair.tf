resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "private_key" {
  name  = "/${var.environment}/${var.key_name}/private"
  type  = "SecureString"
  value = tls_private_key.key.private_key_pem
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.key.public_key_openssh
}
