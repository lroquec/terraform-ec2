#!/bin/bash
yum update -y
yum install wget ruby httpd docker -y

# Configure Apache modules
echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/httpd/conf/httpd.conf
echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/httpd/conf/httpd.conf

# Create index page
echo "<h1>Deployed via Terraform</h1><br>Hostname: $(hostname)<br>Private IP: $(hostname -I | awk '{print $1}')" > /var/www/html/index.html

# Configure reverse proxy
cat <<EOT > /etc/httpd/conf.d/reverse-proxy.conf
<VirtualHost *:80>
    ServerAlias *
    ProxyPreserveHost On
    ProxyPass /docker http://localhost:5000/
    ProxyPassReverse /docker http://localhost:5000/
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Port "80"
    ErrorLog /var/log/httpd/docker_error.log
    CustomLog /var/log/httpd/docker_access.log combined
</VirtualHost>
EOT

# Start and enable services
systemctl enable httpd --now
systemctl enable docker --now
usermod -aG docker ec2-user

# Install CodeDeploy agent
cd /home/ec2-user 
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install 
chmod +x ./install
./install auto
systemctl enable codedeploy-agent --now