#!/bin/bash

# Last Updated - 5/8/14
# Chris Stokes - https://github.com/stokes84/Teamspeak-Installer
#
# Install
# wget -q https://raw.githubusercontent.com/stokes84/Teamspeak-Installer/master/install.sh && bash install.sh && rm -f install.sh
#
# Usage
# service teamspeak start
# service teamspeak stop
# service teamspeak restart
# service teamspeak status

# Set some styles
bold=`tput bold`
alert=`tput setaf 1`
info=`tput setaf 3`
normal=`tput sgr0`

bit=$(uname -a)
serverip=$(wget -qO- http://ipecho.net/plain ; echo)

# Create TS3 user account
printf "\n${bold}Creating Teamspeak 3 system account${normal}\n"
useradd ts3user

# Set TS3 account password
printf "\n${bold}Creating Teamspeak 3 system account password${normal}\n"
passwd ts3user

# Set permissions on the new ts3user directory
chmod 755 /home/ts3user

# Go to the ts3user directory
cd /home/ts3user
cd /home/ts3user

if [[ ${bit} == *x86_64* ]]; then
	# You're running 64 bit CentOS
	printf "\n${bold}64 bit install running...${normal}\n"
	wget http://dl.4players.de/ts/releases/3.0.10.3/teamspeak3-server_linux-amd64-3.0.10.3.tar.gz -O ts3server-64.tar.gz
	tar -zxvf ts3server-64.tar.gz
	rm ts3server-64.tar.gz
	mv teamspeak3-server_linux-amd64 ts3-server
	cd ts3-server
	printf "\nMake sure to copy your ${bold}loginname, password, and token${normal} during the next step"
	printf "\n${bold}Note:${normal} The installer will not continue until you copy the token (CTRL+C)\n"
	read -p "Press ${bold}[Enter]${normal} to continue..."
else 
	# You're running 32 bit CentOS
	printf "\n${bold}32 bit install running...${normal}\n"
	wget http://dl.4players.de/ts/releases/3.0.10.3/teamspeak3-server_linux-x86-3.0.10.3.tar.gz -O ts3server-32.tar.gz
	tar -zxvf ts3server-32.tar.gz
	rm ts3server-32.tar.gz
	mv teamspeak3-server_linux-x86 ts3-server
	cd ts3-server
	printf "\nMake sure to copy your ${bold}loginname, password, and token${normal} during the next step"
	printf "\n${bold}Note:${normal} The installer will not continue until you copy the token (CTRL+C)\n"
	read -p "Press ${bold}[Enter]${normal} to continue..."
fi

# Create ini file
/home/ts3user/ts3-server/ts3server_minimal_runscript.sh createinifile=1

# Change machine_id to 1
sed -i -e "s|machine_id=|machine_id=1|g" /home/ts3user/ts3-server/ts3server.ini

# Insert this machine's IP into the voice_ip field
sed -i -e "s|voice_ip=0.0.0.0|voice_ip=$serverip|g" /home/ts3user/ts3-server/ts3server.ini

# Insert this machine's IP into the filetransfer_ip field
sed -i -e "s|filetransfer_ip=0.0.0.0|filetransfer_ip=$serverip|g" /home/ts3user/ts3-server/ts3server.ini

# Insert this machine's IP into the query_ip field
sed -i -e "s|query_ip=0.0.0.0|query_ip=$serverip|g" /home/ts3user/ts3-server/ts3server.ini

# Edits the startup script to load the ini file
sed -i 's|COMMANDLINE_PARAMETERS="${2}"|COMMANDLINE_PARAMETERS="${2} inifile=ts3server.ini"|g' /home/ts3user/ts3-server/ts3server_startscript.sh

read -e -p "Teamspeak 3 Server Voice Port: " -i "9987" ts3voiceport
sed -i -e "s|default_voice_port=9987|default_voice_port=$ts3voiceport|g" /home/ts3user/ts3-server/ts3server.ini

read -e -p "Teamspeak 3 Server File Transfer Port: " -i "30033" ts3fileport
sed -i -e "s|filetransfer_port=30033|filetransfer_port=$ts3fileport|g" /home/ts3user/ts3-server/ts3server.ini

read -e -p "Teamspeak 3 Server Query Port: " -i "10011" ts3queryport
sed -i -e "s|query_port=9987|query_port=$ts3queryport|g" /home/ts3user/ts3-server/ts3server.ini

printf "\n${bold}Creating Teamspeak 3 service file${normal}\n"

echo "#!/bin/sh
# chkconfig: 2345 99 10
cd /home/ts3user/ts3-server
case \"\$1\" in
'start')
su ts3user -c \"/home/ts3user/ts3-server/ts3server_startscript.sh start\"
;;
'stop')
su ts3user -c \"/home/ts3user/ts3-server/ts3server_startscript.sh stop\"
;;
'restart')
su ts3user -c \"/home/ts3user/ts3-server/ts3server_startscript.sh restart\"
;;
'status')
su ts3user -c \"/home/ts3user/ts3-server/ts3server_startscript.sh status\"
;;
*)
echo \"Usage \$0 start|stop|restart|status\"
esac" > /etc/rc.d/init.d/teamspeak

# Change permissions on Teamspeak service file
chmod 755 /etc/rc.d/init.d/teamspeak

# Change permissions and ownership on the teamspeak files
chown -R ts3user:ts3user /home/ts3user
chmod +x /home/ts3user/ts3-server/ts3server_startscript.sh

# Fixing common error @ http://forum.teamspeak.com/showthread.php/68827-Failed-to-register-local-accounting-service
echo "tmpfs /dev/shm tmpfs defaults 0 0" >> /etc/fstab
mount -t tmpfs tmpfs /dev/shm

# Make Teamspeak a service and boot at startup
chkconfig --add teamspeak
chkconfig --level 2345 teamspeak on
service teamspeak start
printf "\n${bold}Install Complete!${normal}\n"
printf "\n${bold}Teamspeak 3 is running @ $serverip:$ts3voiceport${normal}\n"
