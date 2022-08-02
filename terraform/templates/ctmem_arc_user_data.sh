#!/bin/bash
touch /tmp/ssh_key.unlock

yum install -y nfs-utils.x86_64
yum install -y python3.x86_64

#  Install pip and run the script with Python:
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
# This command adds a path, ~/.local/bin in this example, to the current PATH variable.
export PATH=~/.local/bin:$PATH
# Use pip to install the AWS CLI v1.
pip3 install awscli --upgrade --user

while [[ 1 -eq 1 ]]
do
	let count=$count+1
	newDev=$( lsblk -l | grep disk | grep -c nvme1n1 )
	if [[ $newDev -eq 0 ]]
	then
		logger -p local3.info "Failed to find EBS volume - sleeping"
		sleep 60
		partprobe
	else
		break
	fi
	if [[ $count -eq 10 ]]
	then
		logger -p local3.err "Timed out waiting for volume to become available - aborting"
		exit 1
	fi
done
logger -p local0.info "Creating SWAP volume"
sudo $(mkswap /dev/nvme1n1 && swapon /dev/nvme1n1 && cat /etc/fstab | grep swap || $(/bin/cp /etc/fstab /root/fstab.bak.$(date +"%d%m%Y") && echo "$(blkid /dev/nvme1n1 | grep -o 'UUID=".*"'|cut -d ' ' -f 1 | tr -d '"') swap swap 0 0" >> /etc/fstab) && mount -a  -t nfs4 && echo "Swap file mount completed successfully" > /tmp/swap_mount.txt)
#filesys2=$( lsblk -l | grep 60G | grep nvme | awk '{print $1}')
#disk_uuid_cnt=$( ls -l /dev/disk/by-uuid/ | grep -c $filesys2 )
#fs_check=$( file -s /dev/$filesys2 | awk '{print $2}' )
#if [[ $fs_check == "data" ]]; then
#	logger -p local0.info "No file-system found on volume, so formating it"
#	mkfs -t xfs -f /dev/$filesys2
#	partprobe
#	sleep 10
#fi
#disk_uuid_cnt=$( ls -l /dev/disk/by-uuid/ | grep -c $filesys2 )
#while [[ $disk_uuid_cnt -eq 0 ]]
#do
#	disk_uuid_cnt=$( ls -l /dev/disk/by-uuid/ | grep -c $filesys2 )
#	if [[ $disk_uuid_cnt -eq 0 ]]
#	then
#		logger -p local0.info "... waiting for uuid identifier, can take a few seconds to appear"
#		sleep 10
#	fi
#done
mkdir -p /opt/bmc/controlm/
#mount -t xfs /dev/$filesys2 /opt/bmc/controlm/

#mkdir -p /opt/bmc/controlm/archive
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /opt/bmc/controlm/
mkdir -p /opt/bmc/cdrom/
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${software_efs_dns}:/ /opt/bmc/cdrom/

mkdir -p /mnt/cdrom
mkdir -p /opt/bmc/controlm/shrdrive/scripts
mkdir -p /opt/bmc/cdrom/tmp
chmod -R 755 /opt/bmc/controlm/

# Add it to /etc/fstab
echo "${efs_dns}:/ /opt/bmc/controlm/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
echo "${software_efs_dns}:/ /opt/bmc/cdrom/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
#echo "$(blkid /dev/$filesys2 | grep -o 'UUID=".*"'| cut -d' ' -f1 | tr -d '"') /opt/bmc/controlm/ xfs noatime,nodev,nosuid 1 3" >> /etc/fstab
mount -a

# Setup NTP for Synchronising the time
timedatectl set-timezone 'Europe/London'
# Set kernel settings
sysctl -w kernel.sem="256 32000 256 1000"
echo "kernel.sem=256 32000 256 1000" >> /etc/sysctl.conf
# Set resolver search
nmcli con mod 'System eth0' ipv4.dns-search "eu-west-1.compute.internal,bc.jsplc.net,stbc2.jstest2.net,stbc3.jstest3.net,argosretailgroup.com,dmz.jsplc.net"
systemctl restart NetworkManager

# Fetch passwords from the AWS parameter store
export password=$(aws ssm get-parameters --names "ctmempassword" --with-decryption --region eu-west-1 | awk -F'"Value":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '"')
export dbpass=$(aws ssm get-parameters --names "ctmemdbpass" --with-decryption --region eu-west-1 | awk -F'"Value":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '"')
# Add controlm group, create user and add to that group
groupadd -g 6040 controlm
useradd -m -d /opt/bmc/controlm/${username} -g controlm -s /bin/ksh ${username}
chage -M 99999 ${username}
echo -e "$password\n$password" | passwd ${username}
chmod 755 /opt/bmc/controlm/${username}
export host_ip=`hostname -i`
export host_fqdn=`hostname -f`
#if [[ "${environment}" = "dev" ]]; then
#	if [[ ${inst_count} -eq 0 ]]; then
#		export host="awsdctmarc01"
#	else
#		export host="awsdctmarc02"
#	fi
#    export host_fqdn="$host.stbc2.jstest2.net"
#    export domain="stbc2.jstest2.net"
#else
#	if [[ ${inst_count} -eq 0 ]]; then
#		export host="awspctmarc01"
#	else
#		export host="awspctmarc02"
#	fi
#    export host_fqdn="$host.bc.jsplc.net"
#    export domain="bc.jsplc.net"
#fi

#hostnamectl --static set-hostname $host
#echo "$host_ip	$host_fqdn	$host" >> /etc/hosts
#systemctl restart systemd-hostnamed

chown -R ${username}:controlm /opt/bmc/cdrom/
chown -R ${username}:controlm /opt/bmc/controlm/

chmod 750 /opt/bmc/cdrom
export userpath="/opt/bmc/controlm/${username}"
# Install Control-M/EM
logger -p local0.info "Control-M/EM about to be installed"
cd /opt/bmc/cdrom
aws s3 cp s3://js-software-files/controlm-v9.0.0/em900_additional_em_silent_install.xml /opt/bmc/cdrom/ --region eu-west-1
aws s3 cp s3://js-software-files/controlm-v9.0.0/arc900_silent_install.xml /opt/bmc/cdrom/ --region eu-west-1
sed -ie "s/em_user/${ctmem_user}/g" /opt/bmc/cdrom/em900_additional_em_silent_install.xml
if [[ ${inst_count} -eq 0 ]]; then
    export ctmem_dns=${ctmem_primary_dns}
    sed -ie "s/em_host/${ctmem_primary_dns}/g" /opt/bmc/cdrom/em900_additional_em_silent_install.xml
    sed -ie "s/em_host/${ctmem_primary_dns}/g" /opt/bmc/cdrom/arc900_silent_install.xml
else
    export ctmem_dns=${ctmem_failover_dns}
    sed -ie "s/em_host/${ctmem_failover_dns}/g" /opt/bmc/cdrom/em900_additional_em_silent_install.xml
    sed -ie "s/em_host/${ctmem_failover_dns}/g" /opt/bmc/cdrom/arc900_silent_install.xml
fi
chmod 644 /opt/bmc/cdrom/em900_additional_em_silent_install.xml
aws s3 cp s3://js-software-files/controlm-v9.0.0/ns_add_config.xml /opt/bmc/cdrom/ --region eu-west-1
aws s3 cp s3://js-software-files/controlm-v9.0.0/arc_SystemParameters.xml /opt/bmc/cdrom/ --region eu-west-1
if [ ! -e /opt/bmc/cdrom/DROST.9.0.00_Linux-x86_64.iso ]; then
	aws s3 cp s3://js-software-files/controlm-v9.0.0/DROST.9.0.00_Linux-x86_64.iso /opt/bmc/cdrom/ --region eu-west-1
fi
if [ ! -e /opt/bmc/cdrom/PANFT.9.0.00.500_Linux-x86_64.iso ]; then
	aws s3 cp s3://js-software-files/controlm-v9.0.0/PANFT.9.0.00.500_Linux-x86_64.iso /opt/bmc/cdrom/ --region eu-west-1
fi
if [ ! -e /opt/bmc/cdrom/PANFT.9.0.00.512_Linux-x86_64_INSTALL.BIN ]; then
	aws s3 cp s3://js-software-files/controlm-v9.0.0/PANFT.9.0.00.512_Linux-x86_64_INSTALL.BIN /opt/bmc/cdrom/ --region eu-west-1
	chmod 755 /opt/bmc/cdrom/PANFT.9.0.00.512_Linux-x86_64_INSTALL.BIN
fi
mkdir -p /opt/bmc/cdrom/Archive/
aws s3 cp s3://js-software-files/controlm-v9.0.0/DRARB.9.0.00.iso /opt/bmc/cdrom/Archive/ --region eu-west-1
# wait until iso file has been downloaded
while [[ ! -e /opt/bmc/cdrom/Archive/DRARB.9.0.00.iso ]];
do
  sleep 10
done
# If required, insert application installation commands/instructions after this point
# Mount iso file
cd /opt/bmc/cdrom
export timeNow=`date '+%F_%H:%M:%S'`
echo "$timeNow Mounting initial iso file" >> $userpath/ctmem_install_progress.txt
mount -o loop DROST.9.0.00_Linux-x86_64.iso /mnt/cdrom
if [ $? -ne 0 ]; then
	echo "$timeNow Mount of initial iso file failed" >> $userpath/ctmem_install_progress.txt
fi

# Copy user scripts from s3
mkdir -p /opt/bmc/cdrom/scripts/
aws s3 cp s3://js-software-files/controlm-v9.0.0/em_scripts/ /opt/bmc/cdrom/scripts/ --recursive --region eu-west-1
cd /opt/bmc/cdrom/scripts/
for filename in *; do
	awk '{ sub("\r$", ""); print }' $filename > /opt/bmc/controlm/shrdrive/scripts/$filename
done
cd /opt/bmc/controlm/shrdrive/
chown -R ${username}:controlm .
chmod +x /opt/bmc/controlm/shrdrive/scripts/*

cd $userpath
chown -R ${username}:controlm .

# Re-Configure SSM agent to use ssm Endpoint
cd /opt
yum install -y https://s3.eu-west-1.amazonaws.com/amazon-ssm-eu-west-1/latest/linux_amd64/amazon-ssm-agent.rpm
cd /etc/amazon/ssm/
sed '/Ssm/!b;n;c\\t\"Endpoint\"\: \"${ssm_endpoint}\",' amazon-ssm-agent.json.template > amazon-ssm-agent.json
systemctl stop amazon-ssm-agent && systemctl daemon-reload && systemctl start amazon-ssm-agent
sed -ie '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Install the EM service
su - ${username} -c "/mnt/cdrom/setup.sh -silent /opt/bmc/cdrom/em900_additional_em_silent_install.xml"
# Create .pgpass file
export dbpass="$( echo $dbpass | tr -d '[:space:]')"
echo "$ctmem_dns:5432:em900:${ctmem_user}:$dbpass" > $userpath/.pgpass
chown ${username}:controlm $userpath/.pgpass
chmod 600 $userpath/.pgpass
echo "$dbpass" > $userpath/ctm_em/data/rhc_pf.dat
chown ${username}:controlm $userpath/ctm_em/data/rhc_pf.dat
chmod 600 $userpath/ctm_em/data/rhc_pf.dat
pkill -9 emmaintag

# Replace the Naming Server config file to limit component ports to 13100-13123
\cp -f /opt/bmc/cdrom/ns_add_config.xml $userpath/ctm_em/etc/domains/ns_config.xml
\cp -f /opt/bmc/cdrom/arc_SystemParameters.xml $userpath/ctm_em/archive/config/arc_SystemParameters.xml
if [[ ${inst_count} -eq 0 ]]; then
    export ctmem_fqdn=${ctmem_primary_dns}
    export ctmem_host=$(echo ${ctmem_primary_dns} | awk -F'.' '{print $1}')
else
    export ctmem_fqdn=${ctmem_failover_dns}
    export ctmem_host=$(echo ${ctmem_primary_dns} | awk -F'.' '{print $1}')
fi

sed -ie "s/em_host_fqdn/$ctmem_fqdn/" $userpath/ctm_em/etc/domains/ns_config.xml
sed -ie "s/em_user/${username}/" $userpath/ctm_em/etc/domains/ns_config.xml
chown ${username}:controlm $userpath/ctm_em/etc/domains/ns_config.xml
chmod 755 $userpath/ctm_em/etc/domains/ns_config.xml
\mv -f $userpath/ctm_em/etc/domains/config.xml $userpath/ctm_em/etc/domains/config.xml.tmp
\cp -f $userpath/ctm_em/etc/domains/ns_config.xml $userpath/ctm_em/etc/domains/config.xml
chown ${username}:controlm $userpath/ctm_em/etc/domains/config.xml

sed -ie "s/em_host_fqdn/$ctmem_fqdn/" $userpath/ctm_em/archive/config/arc_SystemParameters.xml
sed -ie "s/em_host/$ctmem_host/" $userpath/ctm_em/archive/config/arc_SystemParameters.xml
sed -ie "s/host_fqdn/$host_fqdn/" $userpath/ctm_em/archive/config/arc_SystemParameters.xml
chown ${username}:controlm $userpath/ctm_em/archive/config/arc_SystemParameters.xml
chmod 755 $userpath/ctm_em/archive/config/arc_SystemParameters.xml
\mv -f $userpath/ctm_em/archive/config/SystemParameters.xml $userpath/ctm_em/archive/config/SystemParameters.xml.tmp
\cp -f $userpath/ctm_em/archive/config/arc_SystemParameters.xml $userpath/ctm_em/archive/config/SystemParameters.xml
chown ${username}:controlm $userpath/ctm_em/archive/config/SystemParameters.xml

echo "user=${ctmem_user}" > ~${username}/.empass
echo "password=$dbpass" >> ~${username}/.empass
chown ${username}:controlm ~${username}/.empass
chmod 600 ~${username}/.empass
su - ${username} -c "stop_config_agent"
#su - ${username} -c "/opt/bmc/controlm/shrdrive/scripts/em_stop_all && start_server"
# Mount iso file and remount with FP500
cd /opt/bmc/cdrom
umount /mnt/cdrom
mount -o loop PANFT.9.0.00.500_Linux-x86_64.iso /mnt/cdrom
su - ${username} -c "/mnt/cdrom/PANFT.9.0.00.500_Linux-x86_64_INSTALL.BIN -s -f -d /opt/bmc/cdrom/tmp"
## Check all installations have completed
panft_installed=$( grep -c PANFT $userpath/installed-versions.txt )
count=0
while [[ $panft_installed -eq 0 ]]
do
	let count=$count+1
	panft_installed=$( grep -c PANFT $userpath/installed-versions.txt )
	export timeNow=`date '+%F_%H:%M:%S'`
	if [[ $panft_installed -eq 0 ]]
	then
		logger -p local3.info "EM FixPack 500 still installing - sleeping"
		echo "$timeNow EM FixPack 500 still installing - sleeping" >> $userpath/ctmem_install_progress.txt
		sleep 3m
	else
		logger -p local3.info "EM FixPack 500 installation completed"
		echo "$timeNow EM FixPack 500 installation completed" >> $username/ctmem_install_progress.txt
		echo $host > $userpath/ctm_em_existing_host.txt
        \rm -rf /opt/bmc/controlm/shrdrive/tmp/*
		su - ${username} -c "/opt/bmc/cdrom/PANFT.9.0.00.512_Linux-x86_64_INSTALL.BIN -s -f -d /opt/bmc/cdrom/tmp"
	fi
	if [[ $count -eq 10 ]]
	then
		logger -p local3.err "Timed out waiting for EM FixPack 500 install to complete - aborting"
		echo "$timeNow Timed out waiting for EM FixPack 500 install to complete - aborting" >> $userpath/ctmem_install_progress.txt
		exit 1
	fi
done
umount /mnt/cdrom
cd $userpath
echo 'if [ -f $HOME/ctm_em/.PGenv.sh ]; then' >> $userpath/.profile
echo '        . $HOME/ctm_em/.PGenv.sh' >> $userpath/.profile
echo 'fi' >> $userpath/.profile
echo 'set -o vi' >> $userpath/.profile
\cp -f $userpath/.profile $userpath/.kshrc
chown ${username}:controlm $userpath/.kshrc
su - ${username} -c "source .kshrc"
su - ${username} -c "sed -ie '/^\[jvm_properties.*/a HeapUTIL=560 1' $userpath/ctm_em/ini/EMSiteConfig.ini"

# Install the Control-M/Archive component

mount -o loop /opt/bmc/cdrom/Archive/DRARB.9.0.00.iso /mnt/cdrom
###
### The silent installation of 'Control-M Workload Archiving' does not work and can only be
### installed manually.
### Run the command below from the ctmarc userid and reply to the prompts as appropriate:
###    /mnt/cdrom/setup.sh
###
# # su - ${username} -c "/mnt/cdrom/setup.sh -silent /opt/bmc/cdrom/arc900_silent_install.xml"
# # ## Check all installations have completed
# # drarb_installed=$( grep -c DRARB $userpath/installed-versions.txt )
# # sleep 3m
# # count=0
# # while [[ $drarb_installed -eq 0 ]]
# # do
# # 	let count=$count+1
# # 	drarb_installed=$( grep -c DRARB $userpath/installed-versions.txt )
# # 	export timeNow=`date '+%F_%H:%M:%S'`
# # 	if [[ $drarb_installed -eq 0 ]]
# # 	then
# # 		logger -p local3.info "EM Archive still installing - sleeping"
# # 		echo "$timeNow EM Archive still installing - sleeping" >> $userpath/ctmem_install_progress.txt
# # 		sleep 3m
# # 	else
# # 		logger -p local3.info "EM Archive installation completed"
# # 		echo "$timeNow EM Archive installation completed" >> $username/ctmem_install_progress.txt
# # 		echo $host > $userpath/ctm_em_existing_host.txt
# # 	fi
# # 	if [[ $count -eq 10 ]]
# # 	then
# # 		logger -p local3.err "Timed out waiting for EM Archive install to complete - aborting"
# # 		echo "$timeNow Timed out waiting for EM Archive install to complete - aborting" >> $userpath/ctmem_install_progress.txt
# # 		exit 1
# # 	fi
# # done
# # su - ${username} -c "start_config_agent"
# # umount /mnt/cdrom
