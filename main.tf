resource "aws_vpc" "vpc_one" {
  cidr_block = var.cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name="my-first-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc_one.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc_one.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "internet_1" {
  vpc_id = aws_vpc.vpc_one.id
}

resource "aws_route_table" "route_1" {
  vpc_id = aws_vpc.vpc_one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_1.id
  }
}

resource "aws_route_table_association" "rta1234" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_1.id

}

resource "aws_route_table_association" "rtb1" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.route_1.id

}

resource "aws_security_group" "sg_1" {
  name_prefix = "web-sg"
  vpc_id      = aws_vpc.vpc_one.id
  ingress {
    description = "this is for http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port          = 0
    from_port        = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "web-app"
  }
}

resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "portfolio-bucket-123-demoproject-xyz" # More unique identifier
}

resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file("/Users/pratibhapatil/Desktop/Projects/AWSTerraformProject/my-key.pub")
}

resource "aws_instance" "ec2_1" {
  ami                    = "ami-053a45fff0a704a47"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_1.id]
  subnet_id              = aws_subnet.subnet_1.id
  user_data              = file("/Users/pratibhapatil/Desktop/Projects/AWSTerraformProject/data1.sh")
  key_name               = aws_key_pair.my-key.key_name
}

resource "aws_instance" "ec2_2" {
  ami                    = "ami-053a45fff0a704a47"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_1.id]
  subnet_id              = aws_subnet.subnet_2.id
  user_data              = file("/Users/pratibhapatil/Desktop/Projects/AWSTerraformProject/data.sh")
  key_name               = aws_key_pair.my-key.key_name
}

resource "aws_lb" "myalb" {
  name = "myalb"

  security_groups    = [aws_security_group.sg_1.id]
  internal           = false
  load_balancer_type = "application"

  subnets = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "web"
  }

}

resource "aws_lb_target_group" "target1" {
  name     = "mytarget"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_one.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "targetatt1" {
  target_group_arn = aws_lb_target_group.target1.arn
  target_id        = aws_instance.ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "targetatt2" {
  target_group_arn = aws_lb_target_group.target1.arn
  target_id        = aws_instance.ec2_2.id
  port             = 80
}

resource "aws_lb_listener" "listerner1" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.target1.arn
    type             = "forward"
  }
}