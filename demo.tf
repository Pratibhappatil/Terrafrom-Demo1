

resource "aws_vpc" "demovpc" {
   tags = {
    Name="my-vpc-1"
   }
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sb1" {
  vpc_id = aws_vpc.demovpc.id
  cidr_block="10.0.0.0/32"
  availability_zone="us-east-1a"
  map_public_ip_on_launch=true
}

resource "aws_security_group" "sg1" {
  name="my-sg1"
  vpc_id = aws_vpc.demovpc.id

  ingress = {
   from_port=80
   to_port=80
   cidr_block="10.0.0.0/32"
   protocol="tcp"
  }

  egress = {
   from_port=0
   to_port=0
   protocol="-1"
   cidr_block=["0.0.0.0/0"]
   ipv6_cidr_blocks=["::/0"]
  }
}

resource "aws_internet_gateway" "ig1" {
  vpc_id = aws_vpc.demovpc.id
}

resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.demovpc.id
  route = {
    cidr_block=["0.0.0.0/0"]
    gateway_id=aws_internet_gateway.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sb1.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_instance" "myec2" {
    ami = "ami-123"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sg1.id]
    subnet_id = aws_subnet.sb1.id
    key_name = "my.key.pem"
}

resource "aws_lb" "lb1" {
  subnets = [ aws_subnet.sb1.id ]
  security_groups = [ aws_security_group.sg1.id ]
  load_balancer_type = "application"
  internal = false
  tags = {
    Name="my-lb"
  }
}

resource "aws_lb_target_group" "t1" {
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.demovpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "ta1" {
  target_group_arn = aws_lb_target_group.t1.arn
  target_id = aws_instance.myec2.id
  port=80
  
}

resource "aws_lb_listener" "ll1" {
  port = 80
  load_balancer_arn = aws_lb.lb1.arn
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.t1.arn
    type = "forward"
  }
}