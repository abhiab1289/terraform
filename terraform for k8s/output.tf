output "subnetid"{
value = aws_instance.master.subnet_id
}
output "privateip"{
value = aws_instance.master.private_ip
}
output "worker_privateip"{
value = aws_instance.worker1.private_ip
}
output "workernode_privateip"{
value = aws_instance.worker2.private_ip
}
