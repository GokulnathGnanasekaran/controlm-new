#!/bin/bash
touch /tmp/ssh_key.unlock
# Re-Configure SSM agent
cd /opt
yum install -y https://s3.eu-west-1.amazonaws.com/amazon-ssm-eu-west-1/latest/linux_amd64/amazon-ssm-agent.rpm
# Install pip and run the script with Python:
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
# This command adds a path, ~/.local/bin in this example, to the current PATH variable.
export PATH=~/.local/bin:$PATH
# Use pip to install the AWS CLI v1.
pip install awscli --upgrade --user
if [ -e /bin/aws ]; then
	chmod +x /bin/aws*
fi
yum update -y
# Install required software
yum install -y csh
yum install -y ksh
yum install -y psmisc
yum install -y libaio
yum install -y bc
yum install -y flex
yum install -y gcc
yum install -y httpd.x86_64
yum install -y nc
yum install -y nfs-utils
yum install -y bind-utils
yum install -y traceroute
yum install -y telnet
yum install -y mailx

# Setup NTP for Synchronising the time
yum install -y chrony
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
service chronyd restart
timedatectl set-timezone 'Europe/London'
# Set kernel settings
sysctl -w kernel.sem="256 32000 256 1000"
echo "kernel.sem=256 32000 256 1000" >> /etc/sysctl.conf
