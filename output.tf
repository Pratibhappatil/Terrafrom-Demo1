output "aws_ec21_ip" {
  value = aws_instance.ec2_1.public_ip
}

output "aws_ec22_ip" {
  value = aws_instance.ec2_2.public_ip
}

output "loadbalance" {
  value = aws_lb.myalb.dns_name
}