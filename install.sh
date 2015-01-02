#!/bin/bash
# Last Updated - 1/1/15
# Chris Stokes - https://github.com/stokes84/Teamspeak-Installer
#
# Install Latest
# wget --no-check-certificate https://raw.githubusercontent.com/stokes84/Teamspeak-Installer/master/install.sh; bash install.sh; rm -f install.sh
#
# Usage (with license / multiple instances)
# service teamspeak-yourserver start
# service teamspeak-yourserver stop
# service teamspeak-yourserver restart
# service teamspeak-yourserver status
#
# Usage (without license / single instance)
# service teamspeak start
# service teamspeak stop
# service teamspeak restart
# service teamspeak status

# Set some styles
bold=`tput bold`
info=`tput setaf 3`
normal=`tput sgr0`

# Ensure this script is run as root
if [ "$(id -u)" != "0" ]; then
	echo "${bold}This script must be run as root${normal}" 1>&2
	exit 1
fi

# Install variables
serverdir='/home/teamspeak'
bit=$(uname -a)
serverip=$(wget -qO- http://ipecho.net/plain ; echo)
# Backup Public IP Service
# serverip=$(wget -qO- checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')

# Clear it in case of previous mistake
unset license

# Install dependencies, currently only lsof for port checking
if [ -f /etc/redhat-release ]; then
	printf "\n${bold}Installing dependencies...${normal}\n"
	yum -y -q install lsof
else
	printf "${bold}Installing dependencies...${normal}"
	apt-get -y -q install lsof
fi

# Let's check to see if you have a license to install multiple instances
read -p $'\x0aDo you have a TeamSpeak 3 license and wish to install multiple instances? (y/n) ' -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	license=1
	printf "\n${bold}Paste your license file here.${normal}\n"
	read -e -p "TeamSpeak 3 Server License Company Name: " -i "" licensename
	read -e -p "TeamSpeak 3 Server License Key: " -i "" licensefile
	printf "\nProceeding with multi instance install process...\n"
fi

# Check if user exists in case of previous install or multi instance install
if id -u teamspeak >/dev/null 2>&1; then

	printf "\n${bold}TeamSpeak 3 service account(teamspeak) already exists${normal}\n"
	
	# If you don't have a license and we see an existing install you gotta go remove that first
	if [ -z "$license" ]; then 
		if ls -d /home/teamspeak/*/ 1> /dev/null 2>&1; then
			printf "\n${bold}Existing TeamSpeak3 install(s) detected.\n"
			printf "\nFurther installations will not function without a license\n"
			printf "\nPlease remove the following installations then restart the installer: ${normal}\n"
			ls -d1 /home/teamspeak/*/ | xargs -n1 basename
			exit 0
		fi
	fi
        
	# Go to the TeamSpeak directory
    	cd ${serverdir}
    
	# If you have a license we'll prompt for a custom server name
	if [ -n "$license" ]; then 
		# Set TeamSpeak server name
		printf "\n${bold}${info}Note:${normal} Alphanumeric only, everything else will be trimmed.\n"
		read -e -p "Teamspeak 3 Server Name: " -i "ServerName" inputservername
	
		# Only alphanumeric names with dashes, we'll make sure of that
		servername="`echo -n "${inputservername}" | tr -cd '[:alnum:] [:space:]' | tr '[:space:]' '-'  | tr '[:upper:]' '[:lower:]'`"
	fi
else
	# Create TS3 user account
	printf "\n${bold}Creating TeamSpeak 3 service account (teamspeak)${normal}\n"
	useradd -d ${serverdir} -m teamspeak

	# Go to the Teamspeak directory
	cd ${serverdir}
	
	# If you have a license we'll prompt for a custom server name
	if [ -n "$license" ]; then
		# Set TeamSpeak server name
		printf "\n${bold}${info}Note:${normal} Alphanumeric only, everything else will be trimmed.\n"
		read -e -p "TeamSpeak 3 Server Name: " -i "ServerName" inputservername
	
		# Only alphanumeric names, we'll make sure of that
		servername="`echo -n "${inputservername}" | tr -cd '[:alnum:] [:space:]' | tr '[:space:]' '-'  | tr '[:upper:]' '[:lower:]'`"
	fi
fi

# Set chklicense now that we have a license status and server name
chklicense=$([ $license ] && echo "${servername}" || echo "teamspeak")

# Function to display download progress bar and hide everything else
progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

# Download, unpack, and install the TeamSpeak application
if [[ ${bit} == *x86_64* ]]; then
	# You're running 64 bit
	printf "\n${bold}Downloading latest 64bit version of TeamSpeak 3${normal}\n"
	wget --progress=bar:force http://dl.4players.de/ts/releases/3.0.11.2/teamspeak3-server_linux-amd64-3.0.11.2.tar.gz -O teamspeak3-64.tar.gz 2>&1 | progressfilt
	tar xzf teamspeak3-64.tar.gz
	rm -f teamspeak3-64.tar.gz
	if [ -n "$license" ]; then
		# If installer was run previously but did not complete
		if [ -d "${servername}" ]; then
			printf "${bold}Removing existing directory: ${normal}${servername}\n\n"
			rm -rf ${servername}
		fi
	fi
	mv teamspeak3-server_linux-amd64 ${chklicense}
	cd ${chklicense}
	chmod +x ts3server_startscript.sh
else 
	# You're running 32 bit
	printf "\n${bold}Downloading latest 32bit version of TeamSpeak 3${normal}\n"
	wget --progress=bar:force http://dl.4players.de/ts/releases/3.0.11.2/teamspeak3-server_linux-x86-3.0.11.2.tar.gz -O teamspeak3-32.tar.gz 2>&1 | progressfilt
	tar xzf teamspeak3-32.tar.gz
	rm -f teamspeak3-32.tar.
	if [ -n "$license" ]; then
		# If installer was run previously but did not complete
		if [ -d "${servername}" ]; then
			printf "${bold}Removing existing directory: ${normal}${servername}\n\n"
			rm -rf ${servername}
		fi
	fi
	mv teamspeak3-server_linux-x86 ${chklicense}
	cd ${chklicense}
	chmod +x ts3server_startscript.sh
fi

printf "${bold}Generating TeamSpeak 3 config file @ ${serverdir}/${chklicense}/server.ini${normal}\n\n"

# Create the default ini file
echo "machine_id=
default_voice_port=9987
voice_ip=0.0.0.0
licensepath=
filetransfer_port=30033
filetransfer_ip=0.0.0.0
query_port=10011
query_ip=0.0.0.0
query_ip_whitelist=query_ip_whitelist.txt
query_ip_blacklist=query_ip_blacklist.txt
dbplugin=ts3db_sqlite3
dbpluginparameter=
dbsqlpath=sql/
dbsqlcreatepath=create_sqlite/
dbconnections=10
logpath=logs
logquerycommands=0
dbclientkeepdays=30
logappend=0
query_skipbruteforcecheck=0" >> ${serverdir}/${chklicense}/server.ini

# We'll make sure a whitelist file is ready
touch ${serverdir}/${chklicense}/query_ip_whitelist.txt

# Generate the license file
touch ${serverdir}/${servername}/licensekey.dat
cat <<EOF > ${serverdir}/${servername}/licensekey.dat
Company name : ${licensename}

==key==
${licensefile}
EOF

# Let's make a directory for backups
mkdir ${serverdir}/${chklicense}/backups

# Insert machine id into the machine_id field
# useful when running multiple TeamSpeak 3 Server instances on the same database
printf "${info}${bold}Note:${normal} Leave this blank unless you know what you're doing.\n"
read -e -p "TeamSpeak 3 Machine ID: " -i "" machineid
sed -i -e "s|machine_id=|machine_id=$machineid|g" ${serverdir}/${chklicense}/server.ini

# Double check we're grabbing the IP you want
printf "\n${info}${bold}Note:${normal} If installing on a machine with a dynamic IP use 0.0.0.0\n"

# Insert IP into the voice_ip field
# IP on which the server instance will listen for incoming voice connections
read -e -p "TeamSpeak 3 Voice IP: " -i "$serverip" voiceip
sed -i -e "s|voice_ip=0.0.0.0|voice_ip=$voiceip|g" ${serverdir}/${chklicense}/server.ini

# Insert IP into the filetransfer_ip field
# IP on which the file transfers are bound to
read -e -p "TeamSpeak 3 File Transfer IP: " -i "$serverip" fileip
sed -i -e "s|filetransfer_ip=0.0.0.0|filetransfer_ip=$fileip|g" ${serverdir}/${chklicense}/server.ini

# Insert IP into the query_ip field
# IP bound for incoming ServerQuery connections
read -e -p "TeamSpeak 3 Query IP: " -i "$serverip" queryip
sed -i -e "s|query_ip=0.0.0.0|query_ip=$queryip|g" ${serverdir}/${chklicense}/server.ini

# Edits the startup script to load the ini file
sed -i 's|COMMANDLINE_PARAMETERS="${2}"|COMMANDLINE_PARAMETERS="${2} inifile=server.ini"|g' ${serverdir}/${chklicense}/ts3server_startscript.sh

# Set Teamspeak 3 voice port & make sure it's not being used
# UDP port open for clients to connect to
while read -e -p "TeamSpeak 3 Server Voice Port: " -i "9987" ts3voiceport; do
	if [[ -z $(lsof -i :${ts3voiceport}) ]]; then
		sed -i -e "s|default_voice_port=9987|default_voice_port=$ts3voiceport|g" ${serverdir}/${chklicense}/server.ini
		break
	else 
		printf "${bold}Port ${ts3voiceport} in use, try another port\n${normal}"
	fi
done

# Set Teamspeak 3 server file transfer port & make sure it's not being used
# TCP Port opened for file transfers
while read -e -p "TeamSpeak 3 Server File Transfer Port: " -i "30033" ts3fileport; do
	if [[ -z $(lsof -i :${ts3fileport}) ]]; then
		sed -i -e "s|filetransfer_port=30033|filetransfer_port=$ts3fileport|g" ${serverdir}/${chklicense}/server.ini
		break
	else 
		printf "${bold}Port ${ts3fileport} use, try another port\n${normal}"
	fi
done

# Set Teamspeak 3 ServerQuery port & make sure it's not being used
# TCP Port opened for ServerQuery connections
while read -e -p "TeamSpeak 3 ServerQuery Port: " -i "10011" ts3queryport; do
	if [[ -z $(lsof -i :${ts3queryport}) ]]; then
		sed -i -e "s|query_port=9987|query_port=$ts3queryport|g" ${serverdir}/${chklicense}/server.ini
		break
	else 
		printf "${bold}Port ${ts3queryport} in use, try another port\n${normal}"
	fi
done

# Setup the TeamSpeak service file
# If CentOS / Fedora
if [ -f /etc/redhat-release ]; then
printf "\n${bold}Generating TeamSpeak 3 service @ /etc/rc.d/init.d/teamspeak$([ $license ] && echo "-${servername}")${normal}\n"
cat <<EOF > /etc/rc.d/init.d/teamspeak$([ $license ] && echo "-${servername}")
#!/bin/sh
# chkconfig: 2345 95 20
# description: TeamSpeak 3 Server
# processname: teamspeak$([ $license ] && echo "-${servername}")
cd ${serverdir}/${chklicense}
case "\$1" in
	'start')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh start";;
	'stop')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh stop";;
	'restart')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh restart";;
	'status')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh status";;
	'monitor')
		watch -n 5 "service teamspeak$([ $license ] && echo "-${servername}") start" &>/dev/null &;;
	'backup')
		name=backup-\$(date '+%Y-%m-%d-%H%M%S').tar
		printf "\n"
		service teamspeak$([ $license ] && echo "-${servername}") stop
		cd /home/teamspeak/${chklicense}
		printf "\n\$(tput bold)Backing up @ /home/teamspeak/${chklicense}/backups\$(tput sgr0)\n"
		tar -cf \${name} query_ip_blacklist.txt ts3server.sqlitedb query_ip_whitelist.txt server.ini
		printf "\n"
		service teamspeak$([ $license ] && echo "-${servername}") start
		mv \${name} /home/teamspeak/${chklicense}/backups/\${name}	
		printf "\n\$(tput bold)Backup \${name} Complete!\$(tput sgr0)\n"
	;;
	*)
	echo "Usage: teamspeak-${servername} start|stop|restart|status|monitor|backup"
	exit 1;;
esac
EOF
else
# If Ubuntu / Debian
printf "\n${bold}Generating TeamSpeak 3 service @ /etc/init.d/teamspeak$([ $license ] && echo "-${servername}")${normal}\n"
cat <<EOF > /etc/init.d/teamspeak$([ $license ] && echo "-${servername}")
#!/bin/sh
### BEGIN INIT INFO
# Provides: teamspeak$([ $license ] && echo "-${servername}")
# Required-Start: networking
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: TeamSpeak Server Daemon
# Description: Starts/Stops/Restarts the TeamSpeak Server Daemon
### END INIT INFO
cd ${serverdir}/${chklicense}
case "\$1" in
	'start')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh start";;
	'stop')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh stop";;
	'restart')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh restart";;
	'status')
		su teamspeak -c "${serverdir}/${chklicense}/ts3server_startscript.sh status";;
	'monitor')
		watch -n 5 "service teamspeak$([ $license ] && echo "-${servername}") start" &>/dev/null &;;
	'backup')
		name=backup-\$(date '+%Y-%m-%d-%H%M%S').tar
		printf "\n"
		service teamspeak$([ $license ] && echo "-${servername}") stop
		cd /home/teamspeak/${chklicense}
		printf "\n\$(tput bold)Backing up @ /home/teamspeak/${chklicense}/backups\$(tput sgr0)\n"
		tar -cf \${name} query_ip_blacklist.txt ts3server.sqlitedb query_ip_whitelist.txt server.ini
		printf "\n"
		service teamspeak$([ $license ] && echo "-${servername}") start
		mv \${name} /home/teamspeak/${chklicense}/backups/\${name}	
		printf "\n\$(tput bold)Backup \${name} Complete!\$(tput sgr0)\n"
	;;
	*)
	echo "Usage: teamspeak-${servername} start|stop|restart|status|monitor|backup"
	exit 1;;
esac
EOF
fi

# Change ownership of all TeamSpeak files to TeamSpeak user and make start script executable
chown -R teamspeak:teamspeak ${serverdir}
chmod +x ${serverdir}/${chklicense}/ts3server_startscript.sh

# Fixing common error @ http://forum.teamspeak.com/showthread.php/68827-Failed-to-register-local-accounting-service
if ! mount|grep -q "/dev/shm"; then
	echo "tmpfs /dev/shm tmpfs defaults 0 0" >> /etc/fstab
	mount -t tmpfs tmpfs /dev/shm
fi

# Initiate the TeamSpeak service and set to run @ boot
printf "\n${bold}Adding TeamSpeak 3 to boot sequence and setting runlevels${normal}\n"
if [ -f /etc/redhat-release ]; then
	chmod +x /etc/rc.d/init.d/teamspeak$([ $license ] && echo "-${servername}")
	chkconfig --add teamspeak$([ $license ] && echo "-${servername}")
	chkconfig --level 2345 teamspeak$([ $license ] && echo "-${servername}") on
else
	chmod +x /etc/init.d/teamspeak$([ $license ] && echo "-${servername}")
	update-rc.d teamspeak$([ $license ] && echo "-${servername}") defaults
fi

printf "\n${bold}Starting TeamSpeak 3 for the first time${normal}\n"
# Start the server for the first time and display the loginname, password, and token
service teamspeak$([ $license ] && echo "-${servername}") start
# Wait 3 seconds and display some useful info
sleep 3
printf "\nInstall Complete"
printf "\nTeamSpeak 3 is running @ ${bold}$serverip:$ts3voiceport${normal}"
printf "\n${bold}Usage:${normal} service teamspeak"$([ $license ] && echo "-${servername}")" start|stop|restart|status|monitor\n"
