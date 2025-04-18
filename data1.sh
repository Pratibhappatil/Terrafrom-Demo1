#!/bin/bash

# Update the system using yum (Amazon Linux uses yum instead of apt)
sudo yum update -y

# Install Apache HTTP Server (httpd) on Amazon Linux
sudo yum install -y httpd

# Install AWS CLI using yum
sudo yum install -y aws-cli

# Optionally, download images from S3 bucket
# Uncomment the next line if you want to download the image from S3

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>My Portfolio</title>
  <style>
    /* Add animation and styling for the text */
    @keyframes colorChange {
      0% { color: red; }
      50% { color: green; }
      100% { color: blue; }
    }
    h1 {
      animation: colorChange 2s infinite;
    }
  </style>
</head>
<body>
  <h1>Terraform Project Server 1</h1>
  <h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
  <p>THIS IS SERVER1</p>
</body>
</html>
EOF

# Start Apache (httpd) and enable it to start on boot
sudo systemctl start httpd
sudo systemctl enable httpd

# Confirm Apache is running
sudo systemctl status httpd