output "control_node_public_ip" {
  value       = aws_instance.control_node.public_ip
  description = "Public IP of the control node"
}

output "worker_nodes_private_ips" {
  value = [
    aws_instance.worker_node_1.private_ip,
    aws_instance.worker_node_2.private_ip
  ]
  description = "Private IPs of worker nodes"
}
