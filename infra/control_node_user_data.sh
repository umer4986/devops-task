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

# Install Helm
curl https://baltocdn.com/helm/signing.asc | apt-key add -
apt-get install -y apt-transport-https --no-install-recommends
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

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

# Create ansible directory and download playbooks from S3
ANSIBLE_DIR="/home/ubuntu/ansible"
mkdir -p "$ANSIBLE_DIR"
aws s3 cp --recursive s3://eb-do-ansible-playbooks/playbooks/ "$ANSIBLE_DIR/"

# Set ownership for the ansible directory
chown -R ubuntu:ubuntu "$ANSIBLE_DIR"

# Optional logging
echo "[INFO] AWS CLI v2, Ansible, Helm, PEM key, and Ansible playbooks setup completed" >> /var/log/user-data.log
