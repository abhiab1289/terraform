#!/bin/bash
sudo yum install httpd git -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo git clone https://github.com/keyspaceits/project-html-blue-website.git /var/www/html
sudo systemctl restart httpd
