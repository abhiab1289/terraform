provider "aws" {
profile = "default"
region = "${var.region}"
}
resource "aws_vpc" "terravpc" {
cidr_block = "${var.vpc_cidr}"
enable_dns_support = "true"
enable_dns_hostnames = "true"
tags = { Name="teeravpc" }
}
resource "aws_subnet" "public_subnets" {
count = length(var.public_subnets)
vpc_id = aws_vpc.terravpc.id
cidr_block = var.public_subnets[count.index]
availability_zone = var.az_list[count.index]
map_public_ip_on_launch = "true"
tags = { Name= "tvpc-sub" }
}
resource "aws_internet_gateway" "tigw" {
vpc_id = aws_vpc.terravpc.id
tags = { Name = "tigw" }
}
resource "aws_route_table" "rt_terravpc" {
vpc_id = aws_vpc.terravpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.tigw.id
}
tags ={ Name = "rt_terravpc" }
}
resource "aws_route_table_association" "rt_sub1" {
count = length(var.public_subnets)
subnet_id = aws_subnet.public_subnets[count.index].id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_route_table_association" "rt_sub2" {
count = length(var.public_subnets)
subnet_id = aws_subnet.public_subnets[count.index].id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_route_table_association" "rt_sub3" {
count = length(var.public_subnets)
subnet_id = aws_subnet.public_subnets[count.index].id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_route_table_association" "rt_sub4" {
count = length(var.public_subnets)
subnet_id = aws_subnet.public_subnets[count.index].id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_security_group" "sgforterravpc" {
vpc_id = aws_vpc.terravpc.id
egress {
from_port = 0
to_port = 0
protocol = -1
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 1
to_port = 65534
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags = { Name = "terravpcSG" }
}
resource "tls_private_key" "terrakey" {
algorithm = "RSA"
}
resource "aws_key_pair" "terra-key" {
key_name = "terra-key"
public_key = "${tls_private_key.terrakey.public_key_openssh}"
depends_on = [tls_private_key.terrakey]
}
resource "local_file" "key" {
content = "${tls_private_key.terrakey.private_key_pem}"
filename = "terra-key.pem"
file_permission = "0400"
depends_on = [tls_private_key.terrakey]
}
resource "aws_instance" "master" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = "${element(aws_subnet.public_subnets.*.id,0)}"
key_name = "terra-key"
vpc_security_group_ids = ["${aws_security_group.sgforterravpc.id}"]
provisioner "file" {
source = "masternode.sh"
destination = "/home/ubuntu/masternode.sh"
connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
provisioner "remote-exec" {
inline = [
"chmod +x /home/ubuntu/masternode.sh",
"sudo  /bin/bash /home/ubuntu/masternode.sh",
]
connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
tags = { Name = "masternode" }
depends_on= [tls_private_key.terrakey]
}
resource "aws_eip" "eipmaster" {
  vpc = true
  instance = "${aws_instance.master.id}"
depends_on = [aws_instance.master]
}
resource "aws_instance" "worker1" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = "${element(aws_subnet.public_subnets.*.id,1)}"
key_name = "terra-key"
vpc_security_group_ids = ["${aws_security_group.sgforterravpc.id}"]
provisioner "file" {
source = "terra-key.pem"
destination = "/home/ubuntu/terra-key.pem"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
provisioner "file" {
source = "workernode.sh"
destination = "/home/ubuntu/workernode.sh"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}

provisioner "remote-exec" {
inline = [
"chmod +x /home/ubuntu/workernode.sh",
"sudo /bin/bash /home/ubuntu/workernode.sh",
"sudo chmod 600 /home/ubuntu/terra-key.pem",
"sudo scp -i terra-key.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${aws_eip.eipmaster.public_ip}:~/token.sh ~ubuntu/ ",
"sudo chmod u+x ~ubuntu/token.sh",
"sudo /bin/bash /home/ubuntu/token.sh"
]
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
 tags = { Name = "workernode1" }
depends_on = [aws_instance.master]
}
 
resource "aws_instance" "worker2" {
ami = "ami-09e67e426f25ce0d7"
instance_type = "t2.medium"
subnet_id = "${element(aws_subnet.public_subnets.*.id,2)}"
key_name = "terra-key"
vpc_security_group_ids = ["${aws_security_group.sgforterravpc.id}"]
provisioner "file" {
source = "terra-key.pem"
destination = "/home/ubuntu/terra-key.pem"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
provisioner "file" {
source = "workernode.sh"
destination = "/home/ubuntu/workernode.sh"
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}

provisioner "remote-exec" {
inline = [
"chmod +x /home/ubuntu/workernode.sh",
"sudo /bin/bash /home/ubuntu/workernode.sh",
"sudo chmod 600 /home/ubuntu/terra-key.pem",
"sudo scp -i terra-key.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ubuntu@${aws_eip.eipmaster.public_ip}:~/token.sh ~ubuntu/ ",
"sudo chmod u+x ~ubuntu/token.sh",
"sudo /bin/bash /home/ubuntu/token.sh"
]
connection {
type     = "ssh"
user = "ubuntu"
host = "${self.public_ip}"
private_key = "${file("${aws_key_pair.terra-key.key_name}.pem")}"
}
}
 tags = { Name = "workernode2" }
}
