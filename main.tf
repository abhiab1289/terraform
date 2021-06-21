provider "aws"  {
profile = "default"
region = "us-east-1"
}
resource "aws_vpc" "terravpc" {
cidr_block = "192.168.0.0/16"
enable_dns_support = "true"
enable_dns_hostnames = "true"
tags = { Name="teeravpc" }
}
resource "aws_subnet" "tvpc-sub1" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "192.168.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = "true"
tags = { Name= "tvpc-sub1" }
}
resource "aws_subnet" "tvpc-sub2" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "192.168.2.0/24"
availability_zone = "us-east-1b"
map_public_ip_on_launch = "true"
tags = { Name= "tvpc-sub2" }
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
subnet_id = aws_subnet.tvpc-sub1.id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_route_table_association" "rt_sub2" {
subnet_id = aws_subnet.tvpc-sub2.id
route_table_id = aws_route_table.rt_terravpc.id
}
resource "aws_subnet" "tvpc-sub3" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "192.168.3.0/24"
availability_zone = "us-east-1b"
map_public_ip_on_launch = "true"
tags = { Name= "tvpc-sub3" }
}
resource "aws_subnet" "tvpc-sub4" {
vpc_id = aws_vpc.terravpc.id
cidr_block = "192.168.4.0/24"
availability_zone = "us-east-1b"
map_public_ip_on_launch = "true"
tags = { Name= "tvpc-sub4" }
}
resource "aws_eip" "eipfornat" {
vpc = true
}
resource "aws_nat_gateway" "tnatgw" {
allocation_id = aws_eip.eipfornat.id
subnet_id = aws_subnet.tvpc-sub1.id
depends_on = [aws_internet_gateway.tigw]
}
resource "aws_route_table" "rtprivate_terravpc" {
vpc_id = aws_vpc.terravpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_nat_gateway.tnatgw.id
}
tags ={ Name = "rtprivate_terravpc" }
}
resource "aws_route_table_association" "rt_sub3" {
subnet_id = aws_subnet.tvpc-sub3.id
route_table_id = aws_route_table.rtprivate_terravpc.id
}
resource "aws_route_table_association" "rt_sub4" {
subnet_id = aws_subnet.tvpc-sub4.id
route_table_id = aws_route_table.rtprivate_terravpc.id
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
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags = { Name = "terravpcSG" }
}
resource "aws_security_group" "sgforLB" {
vpc_id = aws_vpc.terravpc.id
egress {
from_port = 0
to_port = 0
protocol = -1
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags = { Name = "LBSG" }
}
resource "tls_private_key" "terrakey" {
algorithm = "RSA"
}
resource "aws_key_pair" "terrakey" {
key_name = "terrakey"
public_key = "${tls_private_key.terrakey.public_key_openssh}"
depends_on = [tls_private_key.terrakey]
}
resource "local_file" "key" {
<<<<<<< HEAD
<<<<<<< HEAD
content =OB "${tls_private_key.terrakey.private_key_pem}"
=======
content = "${tls_private_key.terrakey.private_key_pem}"
>>>>>>> 862ad950a78d66f13d068652d3bb12003e9b0ae0
=======
content = "${tls_private_key.terrakey.private_key_pem}"
>>>>>>> 862ad950a78d66f13d068652d3bb12003e9b0ae0
filename = "terrakey.pem"
file_permission = "0400"
depends_on = [tls_private_key.terrakey]
}
resource "aws_instance" "web_server" {
ami = "ami-0d5eff06f840b45e9"
instance_type = "t2.micro"
subnet_id = aws_subnet.tvpc-sub1.id
key_name = "terrakey"
vpc_security_group_ids = ["${aws_security_group.sgforterravpc.id}"]
user_data = "${file("webserver.sh")}"
tags = { Name = "webserver" }
}
resource "aws_lb" "LB" {
name = "lb"
internal = false
load_balancer_type = "application"
security_groups =  ["${aws_security_group.sgforLB.id}"]
subnets 	=  ["${aws_subnet.tvpc-sub1.id}","${aws_subnet.tvpc-sub2.id}"]
ip_address_type = "ipv4" 
enable_http2 = "true"
enable_deletion_protection = "false"
  tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "Tgforalb" {
name = "Tgforalb"
 port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terravpc.id
}
resource "aws_lb_target_group_attachment" "test" {  
target_group_arn = "${aws_lb_target_group.Tgforalb.arn}"
   target_id = "${aws_instance.web_server.id}"
port     = 80
 
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.LB.arn
   port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"
  certificate_arn   = "arn:aws:acm:us-east-1:502434380454:certificate/15001810-b94e-4045-b0e9-813d101d0af8"
default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Tgforalb.arn
  }
}
resource "aws_lb_listener" "rediecthttps" {
  load_balancer_arn = aws_lb.LB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.Tgforalb.arn
    type = "redirect"
      redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_route53_zone" "primary" {
  name = "www.abhinavblog.ga"
}
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.abhinavblog.ga"
  type    = "A"
  alias {
    name                   = aws_lb.LB.dns_name
    zone_id                = aws_lb.LB.zone_id
    evaluate_target_health = true
  }
}
resource "aws_ami_from_instance" "Myweb_server" {
  name               = "Myweb_server"
  source_instance_id = "${aws_instance.web_server.id}"
}
resource "aws_launch_template" "mywebserver" {
  name_prefix   = "mywebserver"
  image_id      = aws_ami_from_instance.Myweb_server.id
  instance_type = "t2.micro"
key_name = "terrakey"
vpc_security_group_ids = ["${aws_security_group.sgforterravpc.id}"]
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1
health_check_grace_period = 60
  health_check_type         = "ELB"
vpc_zone_identifier = [aws_subnet.tvpc-sub1.id, aws_subnet.tvpc-sub2.id]
launch_template {
    id      = aws_launch_template.mywebserver.id
    version = "$Latest"
  }
target_group_arns = [aws_lb_target_group.Tgforalb.arn]
}
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  alb_target_group_arn = aws_lb_target_group.Tgforalb.arn
<<<<<<< HEAD
<<<<<<< HEAD
}
output "webserver_subnet_id"
value = aws_instance.web_server.subnet_id
}
output "webserver_public-ip"
value = aws_instance.web_server.public_ip
}

=======
} 
>>>>>>> 862ad950a78d66f13d068652d3bb12003e9b0ae0
=======
} 
>>>>>>> 862ad950a78d66f13d068652d3bb12003e9b0ae0
