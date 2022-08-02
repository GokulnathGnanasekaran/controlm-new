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

export PATH=/usr/local/bin/aws:$PATH
# Fetch passwords from the AWS parameter store
export dbpass=$(aws ssm get-parameters --names "ctmsrvdbpass" --with-decryption --region eu-west-1 --query Parameters[0].Value | sed -e 's/^"//' -e 's/"$//')
export password=$(aws ssm get-parameters --names "ctmsrvpassword" --with-decryption --region eu-west-1 --query Parameters[0].Value | sed -e 's/^"//' -e 's/"$//')

while [[ 1 -eq 1 ]]
do
	let cnt=$count+1
	newDev=`lsblk -l | grep disk | grep xvdb | awk '{print $1}'`
	if [[ $newDev == "" ]]
	then
		logger -p local0.info "Failed to find EBS volume - sleeping"
		sleep 60
		partprobe
	else
		break
	fi
	if [[ $count -eq 10 ]]
	then
		logger -p local0.err "Timed out waiting for volume to become available - aborting"
		exit 1
	fi
done
logger -p local0.info "Creating SWAP volume"
$(mkswap /dev/xvdb && swapon /dev/xvdb && cat /etc/fstab | grep swap || $(cp /etc/fstab /root/fstab.bak.$(date +"%d%m%Y") && echo $(blkid /dev/xvdb | grep -o 'UUID=".*"' | cut -d' ' -f1 | tr -d '"') swap swap 0 0  >> /etc/fstab) && mount -a && echo "Swap file mount completed successfully" > /tmp/swap_mount.txt)
mkdir -p /mnt/cdrom
mkdir -p /opt/bmc/controlm/shrdrive
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns}:/ /opt/bmc/controlm/shrdrive/
mkdir -p /opt/bmc/cdrom/
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${software_efs_dns}:/ /opt/bmc/cdrom/
mkdir -p /opt/bmc/controlm/${username}
export filesys=$( lsblk -l | grep xvdf | awk '{print $1}')
disk_uuid_cnt=`ls -l /dev/disk/by-uuid/ | grep -c $filesys`
fs_check=`file -s /dev/$filesys | awk -F: '{print $2}' | awk '{print $1}'`
if [[ $fs_check == "data" ]] # No file-system found
then
	logger -p local0.info "No file-system found on volume, so formating it"
	mkfs -t xfs -f /dev/$filesys
	partprobe
	sleep 10
	disk_uuid_cnt=`ls -l /dev/disk/by-uuid/ | grep -c $filesys`
	while [[ $disk_uuid_cnt -eq 0 ]]
	do
		disk_uuid_cnt=`ls -l /dev/disk/by-uuid/ | grep -c $filesys`
		if [[ $disk_uuid_cnt -eq 0 ]]
		then
			# uuid identifier can take a few seconds to appear
			sleep 5
		fi
	done
fi
mount -t xfs /dev/$filesys /opt/bmc/controlm/${username}
# Add it to /etc/fstab
echo "${efs_dns}:/ /opt/bmc/controlm/shrdrive/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
echo "${software_efs_dns}:/ /opt/bmc/cdrom/ nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
echo "$(blkid /dev/$filesys | grep -o 'UUID=".*"'|cut -d' ' -f1 | tr -d '"') /opt/bmc/controlm/${username}/ xfs noatime,nodev,nosuid 1 3" >> /etc/fstab
mount -a
# Setup NTP for Synchronising the time
#yum erase 'ntp*'
#yum install -y chrony
echo "server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4" >> /etc/chrony.conf
service chronyd restart
timedatectl set-timezone 'Europe/London'
# Set kernel settings
sysctl -w kernel.sem="256 32000 256 1000"
echo "kernel.sem=256 32000 256 1000" >> /etc/sysctl.conf
# Set resolver search
nmcli con mod 'System eth0' ipv4.dns-search "eu-west-1.compute.internal,bc.jsplc.net,stbc2.jstest2.net,stbc3.jstest3.net,argosretailgroup.com,dmz.jsplc.net"
systemctl restart NetworkManager
# Write log to /var/log/messages
logger -p local0.info "Defining Control-M/Server user - ${username}"
# Add controlm group, create user and add to that group
groupadd -g 6040 controlm
useradd -m -d /opt/bmc/controlm/${username} -g controlm -s /bin/csh ${username}
chage -M 99999 ${username}
echo -e "$password\n$password" | passwd ${username}
chmod -R 755 /opt/bmc/controlm/${username}/
chown -R ${username}:controlm /opt/bmc/controlm/${username}
export userpath=`getent passwd ${username} | cut -d : -f6`
# Create host variables
export host=`hostname -s`
export host_fqdn=`hostname -f`
export host_ip=`hostname -i`
#hostnamectl set-hostname $host
# Create .pgpass file
echo "$host:5432:ctrlm900:${username}:$dbpass" > ~${username}/.pgpass
chown ${username}:controlm ~${username}/.pgpass
chmod 600 ~${username}/.pgpass
echo "$dbpass" > ~${username}/.ctmdbpass
chmod 600 ~${username}/.ctmdbpass
chown -R ${username}:controlm /opt/bmc/controlm/shrdrive/
chown -R ${username}:controlm /opt/bmc/cdrom
chmod -R 755 /opt/bmc/cdrom/
chmod -R 755 /opt/bmc/controlm/shrdrive/
# iso file has already been mounted via Control-M/EM stack
cd /opt/bmc/cdrom
if [[ ${inst_count} -eq 0 ]]
then

	aws s3 cp s3://js-software-files/controlm-v9.0.0/ctms_install_config/ /opt/bmc/cdrom/ --recursive --region eu-west-1
	aws s3 cp s3://js-software-files/controlm-v9.0.0/PACTV.9.0.00.400_Linux-x86_64_INSTALL.BIN /opt/bmc/cdrom/ --region eu-west-1
	chmod 755 PACTV.9.0.00.400_Linux-x86_64_INSTALL.BIN
    cd /opt/bmc/controlm/shrdrive
    mkdir scripts
    chmod -R 755 /opt/bmc/controlm/shrdrive/
	mkdir /opt/bmc/cdrom/scripts_tmp
	mkdir /opt/bmc/controlm/shrdrive/db_sync
	aws s3 cp s3://js-software-files/controlm-v9.0.0/ctms_scripts/ /opt/bmc/cdrom/scripts_tmp/ --recursive --region eu-west-1
	cd /opt/bmc/cdrom/scripts_tmp
	for filename in $(ls -1 /opt/bmc/cdrom/scripts_tmp/); do
		awk '{ sub("\r$", ""); print }' $filename > /opt/bmc/controlm/shrdrive/scripts/$filename
	done
	chown ${username}:controlm -R /opt/bmc/controlm/shrdrive/
	chmod +x /opt/bmc/controlm/shrdrive/scripts/*
	#rm -Rf /opt/bmc/controlm/scripts_tmp
	if [[ ! -e /opt/bmc/cdrom/DROST.9.0.00_Linux-x86_64.iso ]]; then
		aws s3 cp s3://js-software-files/controlm-v9.0.0/DROST.9.0.00_Linux-x86_64.iso /opt/bmc/cdrom/ --region eu-west-1
	fi
else
	# Second instance to wait until iso file has been downloaded
	let loop_cnt=0
	while [[ ! -e /opt/bmc/cdrom/DROST.9.0.00_Linux-x86_64.iso ]];
	do
    	sleep 3m
    	((loop_cnt++))
    	if [[ $loop_cnt -gt 10 ]]; then
    	  logger -p local3.error "CTM/Server Secondary - failed to identify installation iso file"
    	fi
	done
fi
# Mount iso file
cd /opt/bmc/cdrom
mount -o loop DROST.9.0.00_Linux-x86_64.iso /mnt/cdrom
# Install Control-M/Server
echo "${inst_count} ${datacenter}" > $userpath/ctms_inst_count.txt
logger -p local0.notice "User_Data count ${inst_count} - Installing Control-M/Server"
if [[ ${inst_count} -eq 0 ]]
then
	### Primary CTMS ###
	\rm -f /opt/bmc/controlm/shrdrive/primary_ctmhost.txt
	logger -p local0.notice "Installing Primary Control-M/Server"
	sed -e "s/hostname/$host/" /opt/bmc/cdrom/ctms900_silent_install_${datacenter}_primary.xml > $userpath/ctms_silent_install.xml
	sed -ie "s/username/${username}/" $userpath/ctms_silent_install.xml
	chown ${username}:controlm $userpath/ctms_silent_install.xml
	su - ${username} -c "/mnt/cdrom/Setup_files/components/ctm/setup.sh -silent $userpath/ctms_silent_install.xml"
	logger -p local0.notice "Installation of Primary Control-M/Server completed"
	#printf "$host_ip \t ${service_agt} \t $host" >> /etc/hosts
	# Now add Startup/Shutdown scripts for the Primary CTMS service and enable for the primary only.
	su ${username} -c "$userpath/ctm_server/scripts/create_rc_file"
	tee -a /usr/lib/systemd/system/ctmsrv.service > /dev/null <<EOT
[Unit]
Description=Control-M/Server
After=systemd-user-sessions.service multi-user.target network.target
[Service]
ExecStart=/bin/sh -c /opt/bmc/controlm/ctmsrv/ctm_server/data/rc.ctmsrv
Type=forking
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOT
	systemctl daemon-reload
	systemctl disable ctmsrv.service
	systemctl enable /usr/lib/systemd/system/ctmsrv.service
	# Install the FixPack 400
	su - ${username} -c "shut_ca && shut_ctm"
	su - ${username} -c "mkdir tmp && /opt/bmc/cdrom/PACTV.9.0.00.400_Linux-x86_64_INSTALL.BIN -s -f -d /opt/bmc/controlm/ctmsrv/tmp"
	su - ${username} -c "printf \"$host_ip \t $host_fqdn \t $host\" > /opt/bmc/controlm/shrdrive/primary_ctmhost.txt"
	echo "AGENT_TO_SERVER_HOSTNAME ${r53_dc1}" >> ~${username}/ctm_server/data/local_config.dat
	chown ${username}:controlm ~${username}/ctm_server/data/local_config.dat
	su - ${username} -c "chmod +x ~${username}/ctm_agent/ctm/exe_900/ctmcfg"
	su - ${username} -c "start_ca && start_ctm"
	su - ${username} -c "~${username}/ctm_agent/ctm/exe_900/ctmcfg -TABLE CONFIG -ACTION UPDATE -PARAMETER CTMSHOST -VALUE ${r53_dc1} -QUIET_MODE Y"
	su - ${username} -c "~${username}/ctm_agent/ctm/exe_900/ctmcfg -TABLE CONFIG -ACTION UPDATE -PARAMETER CTMPERMHOSTS -VALUE ${r53_dc1}\|${r53_dc2} -QUIET_MODE Y"
	~${username}/ctm_agent/ctm/scripts/start-ag -u ${username} -p all
	su - ${username} -c "ctmcreate -jobname firstjob -application CTM -tasktype command -cmdline 'uname -a' -run_as ${username}"
	# Create directory for database backups
	su - ${username} -c "mkdir -p /opt/bmc/controlm/shrdrive/db_bkup/hot_bkup"
	su - ${username} -c "mkdir -p /opt/bmc/controlm/shrdrive/db_bkup/cold_bkup"
	su - ${username} -c "mkdir -p /opt/bmc/controlm/shrdrive/db_bkup/Journals"
	for ((i=1;i<=7;i++));
		do
		   day=$( date -d "+$i days" +%a )
		   su - ${username} -c "mkdir -p /opt/bmc/controlm/shrdrive/db_bkup/Journals/$day"
		done
else
	# Secondary CTMS
	sleep 5m
	logger -p local0.notice "Installing Secondary Control-M/Server"
	# Check first install has completed by checking the existance of /opt/bmc/controlm/shrdrive/primary_ctmhost.txt
	let loop_cnt=0
	while [[ ! -e /opt/bmc/controlm/shrdrive/primary_ctmhost.txt ]];
	do
		sleep 5m
		((loop_cnt++))
		if [[ $loop_cnt -gt 10 ]]; then
			logger -p local3.error "CTM/Server Secondary - failed to identify Primary host, user_data terminated"
			exit 12
		fi
	done
	export primary_ctms=$(cat /opt/bmc/controlm/shrdrive/primary_ctmhost.txt | awk -F" " '{print $3}' | tr -d '[:space:]')
	export pri_host_ip=$(cat /opt/bmc/controlm/shrdrive/primary_ctmhost.txt | awk -F" " '{print $1}' | tr -d '[:space:]')
	export pri_host=$(cat /opt/bmc/controlm/shrdrive/primary_ctmhost.txt | awk -F" " '{print $3}' | tr -d '[:space:]')
	logger -p local0.notice "Primary Control-M/Server host found - $pri_host"
	#     printf "$pri_host_ip \t $pri_host\n" >> /etc/hosts
	#     printf "$host_ip \t ${service_agt} \t $host" >> /etc/hosts
	# The following 4 lines are for setting up High-Availability on the secondary CTMS server.
	sed -e "s/hostname/$host/" /opt/bmc/cdrom/ctms900_silent_install_${datacenter}_secondary.xml > $userpath/ctmsrv_secondary_install.xml
	sed -ie "s/primary_host/$primary_ctms/" $userpath/ctmsrv_secondary_install.xml
	sed -ie "s/username/${username}/" $userpath/ctmsrv_secondary_install.xml
	\rm -f $userpath/ctmsrv_secondary_install.xmle
	cd $userpath
	su - ${username} -c "/mnt/cdrom/setup.sh -silent $userpath/ctmsrv_secondary_install.xml"
	su - ${username} -c "printf \"$host_ip \t $host_fqdn \t $host\" > /opt/bmc/controlm/shrdrive/secondary_ctmhost.txt"
	logger -p local0.notice "Installation of Secondary Control-M/Server completed"
	# Install the FixPack 400
	su - ${username} -c "shut_ca"
	su - ${username} -c "mkdir tmp && /opt/bmc/cdrom/PACTV.9.0.00.400_Linux-x86_64_INSTALL.BIN -s -f -d /opt/bmc/controlm/ctmsrv/tmp"
	su - ${username} -c "chmod +x ~${username}/ctm_agent/ctm/exe_900/ctmcfg"
	echo "AGENT_TO_SERVER_HOSTNAME ${r53_dc2}" >> ~${username}/ctm_server/data/local_config.dat
	chown ${username}:controlm ~${username}/ctm_server/data/local_config.dat
	su - ${username} -c "start_ca"
	su - ${username} -c "~${username}/ctm_agent/ctm/exe_900/ctmcfg -TABLE CONFIG -ACTION UPDATE -PARAMETER CTMSHOST -VALUE ${r53_dc1} -QUIET_MODE Y"
	su - ${username} -c "~${username}/ctm_agent/ctm/exe_900/ctmcfg -TABLE CONFIG -ACTION UPDATE -PARAMETER CTMPERMHOSTS -VALUE ${r53_dc1}\|${r53_dc2} -QUIET_MODE Y"
    ~${username}/ctm_agent/ctm/scripts/start-ag -u ${username} -p all
	# Now add Startup/Shutdown scripts for the Seconday CTMS but do not enable the CTMS service.
	su - ${username} -c "$userpath/ctm_server/scripts/create_rc_file"
	tee -a /usr/lib/systemd/system/ctmsrv.service > /dev/null <<EOT
[Unit]
Description=Control-M/Server
After=systemd-user-sessions.service multi-user.target network.target
[Service]
ExecStart=/bin/sh -c /opt/bmc/controlm/ctmsrv/ctm_server/data/rc.ctmsrv
Type=forking
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOT
	systemctl daemon-reload
	systemctl disable ctmsrv.service
	# Start the Database and Configuration Agent on the secondary server
	su - ${username} -c "startdb && start_ca"
fi
umount /mnt/cdrom
# Update SSM agent
cd /opt
yum install -y https://s3.eu-west-1.amazonaws.com/amazon-ssm-eu-west-1/latest/linux_amd64/amazon-ssm-agent.rpm
cd /etc/amazon/ssm/
sed '/Ssm/!b;n;c\\t\"Endpoint\"\: \"${ssm_endpoint}\",' amazon-ssm-agent.json.template > amazon-ssm-agent.json
systemctl stop amazon-ssm-agent && systemctl daemon-reload && systemctl start amazon-ssm-agent
sed -ie '/^PasswordAuthentication/s/no/yes/' /etc/ssh/sshd_config
systemctl restart sshd
# Add symbolic link for /opt/bmc/700/base/scripts to the shrdrive/scripts directory
mkdir -p /opt/bmc/700/base
ln -s /opt/bmc/controlm/shrdrive/scripts /opt/bmc/700/base/scripts
