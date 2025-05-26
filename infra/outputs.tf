output "control_node_eip" {
  value       = aws_eip.control_node_eip.public_ip
  description = "Elastic IP address of the control node"
}

output "worker_nodes_private_ips" {
  value = [
    aws_instance.worker_node_1.private_ip,
    aws_instance.worker_node_2.private_ip
  ]
  description = "Private IPs of worker nodes"
}
