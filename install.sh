#!/bin/bash
# Last Updated - 1/6/15
# Chris Stokes - https://github.com/stokes84/TeamSpeak-Installer
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
	echo "${bold}This script must be run as root${normal}" &> /dev/null
	exit 1
fi

# Install variables
installs_dir='/home/teamspeak'
architecture=$(uname -m)
server_wan_ip=$(wget -qO- checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')

# Backup Public IP Service
# server_wan_ip=$(wget -qO- http://ipecho.net/plain ; echo)

# Configuration variables
has_license=
licensed_server_name=
server_dir=
server_name=
monitor_name=
machine_id=
voice_ip=
file_ip=
query_ip=
voice_port=
file_port=
query_port=


# Function to display download progress bar @ wget and hide everything else
wget_filter ()
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

# Let's check to see if you have a license to install multiple instances
read -p $'\x0aDo you have a license and wish to install multiple instances? (y/n)' -n 1 -r
printf "\n"

if [[ $REPLY =~ ^[Yy]$ ]]
then
	has_license=1
	printf "\nProceeding with multi instance install process...\n"
fi

# Check if user exists in case of previous install or multi instance install
if id -u teamspeak &> /dev/null; then

	printf "\n${bold}TeamSpeak 3 service account(teamspeak) already exists${normal}\n"
else
	# Create TS3 user account
	printf "\n${bold}Creating TeamSpeak 3 service account (teamspeak)${normal}\n"
	useradd -d ${installs_dir} -m teamspeak
fi
	
# If you don't have a license and we see an existing install you gotta go remove that first
if [ -z "$has_license" ]; then 
	if ls -d /home/teamspeak/*/ &> /dev/null; then
		printf "\n${bold}Existing TeamSpeak3 install(s) detected.\n"
		printf "\nFurther installations will not function without a license.\n"
		printf "\nPlease remove the following installations then restart the installer: ${normal}\n"
		ls -d1 /home/teamspeak/*/ | xargs -n1 basename
		exit 0
	fi
fi
        
# Go to the TeamSpeak directory
cd ${installs_dir}
    
# If you have a license we'll prompt for a custom server name
if [ -n "$has_license" ]; then 
	# Set TeamSpeak server name
	printf "\n${bold}${info}Note:${normal} Alphanumeric only, everything else will be trimmed.\n"
	while read -e -p "Teamspeak 3 Server Name: " -i "" inputlicensed_server_name; do

		# Only alphanumeric names with dashes, we'll make sure of that
		licensed_server_name="`echo -n "${inputlicensed_server_name}" | tr -cd '[:alnum:] [:space:]' | tr '[:space:]' '-'  | tr '[:upper:]' '[:lower:]'`"

		# Make sure that server name doesn't already exist
		if [ -d "$licensed_server_name" ]; then
			printf "\n${bold}That server name already exists, try again.${normal}\n"
			
		# Make sure you didn't enter a blank server name
		elif [ -z "$licensed_server_name" ]; then
			printf "\n${bold}Server names cannot be blank, try again.${normal}\n"
			
		# Good name, let's move on
		else
			# Set server_dir and related variables now that we have a license status and server name
			printf "\n${bold}Creating TeamSpeak 3 server ${licensed_server_name}.${normal}\n"
			break
		fi
	done
fi

# Set server name based variables now that we have all the info
server_dir=$([ $has_license ] && echo "${licensed_server_name}" || echo "teamspeak")
server_name=$([ $has_license ] && echo "teamspeak-${licensed_server_name}" || echo "teamspeak")
monitor_name=$([ $has_license ] && echo "monitor_${licensed_server_name}" || echo "monitor_teamspeak")

# Download, unpack, and install the TeamSpeak application
if [[ ${architecture} == "x86_64" ]]; then
	# You're running 64-bit
	printf "\n${bold}Downloading latest 64-bit version of TeamSpeak 3${normal}\n"
	wget --tries=5 --progress=bar:force http://dl.4players.de/ts/releases/3.0.13.6/teamspeak3-server_linux_amd64-3.0.13.6.tar.bz2 -O teamspeak3-64.tar.bz2 2>&1 | wget_filter
	tar xjf teamspeak3-64.tar.bz2
	rm -f teamspeak3-64.tar.bz2
	if [ -n "$has_license" ]; then
		# If installer was run previously but did not complete
		if [ -d "${licensed_server_name}" ]; then
			printf "${bold}Removing existing directory: ${normal}${licensed_server_name}\n\n"
			rm -rf ${licensed_server_name}
		fi
	fi
	mv teamspeak3-server_linux_amd64 ${server_dir}
	cd ${server_dir}
	chmod +x ts3server_startscript.sh
else 
	# You're running 32-bit
	printf "\n${bold}Downloading latest 32-bit version of TeamSpeak 3${normal}\n"
	wget --tries=5 --progress=bar:force http://dl.4players.de/ts/releases/3.0.13.6/teamspeak3-server_linux_x86-3.0.13.6.tar.bz2 -O teamspeak3-32.tar.bz2 2>&1 | wget_filter
	tar xjf teamspeak3-32.tar.bz2
	rm -f teamspeak3-32.tar.bz2
	if [ -n "$has_license" ]; then
		# If installer was run previously but did not complete
		if [ -d "${licensed_server_name}" ]; then
			printf "${bold}Removing existing directory: ${normal}${licensed_server_name}\n\n"
			rm -rf ${licensed_server_name}
		fi
	fi
	mv teamspeak3-server_linux_x86 ${server_dir}
	cd ${server_dir}
	chmod +x ts3server_startscript.sh
fi

printf "${bold}Generating TeamSpeak 3 config file @ ${installs_dir}/${server_dir}/server.ini${normal}\n\n"

# Create the default ini file
echo "machine_id=
default_voice_port=
voice_ip=0.0.0.0
licensepath=
filetransfer_port=
filetransfer_ip=0.0.0.0
query_port=
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
query_skipbruteforcecheck=0" >> ${installs_dir}/${server_dir}/server.ini

# We'll make sure a whitelist file is ready
touch ${installs_dir}/${server_dir}/query_ip_whitelist.txt

# Let's make a directory for backups
mkdir ${installs_dir}/${server_dir}/backups

# Insert machine id into the machine_id field
# useful when running multiple TeamSpeak 3 Server instances on the same database
printf "${info}${bold}Note:${normal} Leave this blank unless you know what you're doing.\n"
read -e -p "TeamSpeak 3 Machine ID: " -i "" machine_id
sed -i -e "s|machine_id=|machine_id=$machine_id|g" ${installs_dir}/${server_dir}/server.ini

# Double check we're grabbing the IP you want
printf "\n${info}${bold}Note:${normal} If installing on a machine with a dynamic IP use 0.0.0.0\n"

# Insert IP into the voice_ip field
# IP on which the server instance will listen for incoming voice connections
while read -e -p "TeamSpeak 3 Voice IP: " -i "$server_wan_ip" voice_ip; do
	if [[ $voice_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		sed -i -e "s|voice_ip=0.0.0.0|voice_ip=$voice_ip|g" ${installs_dir}/${server_dir}/server.ini
		break
	else
		printf "\n${bold}Not a valid IP address, try again${normal}\n"
	fi
done

# Insert IP into the filetransfer_ip field
# IP on which the file transfers are bound to
while read -e -p "TeamSpeak 3 File Transfer IP: " -i "$server_wan_ip" file_ip; do
	if [[ $file_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		sed -i -e "s|filetransfer_ip=0.0.0.0|filetransfer_ip=$file_ip|g" ${installs_dir}/${server_dir}/server.ini
		break
	else
		printf "\n${bold}Not a valid IP address, try again${normal}\n"
	fi
done

# Insert IP into the query_ip field
# IP bound for incoming ServerQuery connections
while read -e -p "TeamSpeak 3 ServerQuery IP: " -i "$server_wan_ip" query_ip; do
	if [[ $query_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		sed -i -e "s|query_ip=0.0.0.0|query_ip=$query_ip|g" ${installs_dir}/${server_dir}/server.ini
		break
	else
		printf "\n${bold}Not a valid IP address, try again${normal}\n"
	fi
done

# Edits the startup script to load the ini file
sed -i 's|COMMANDLINE_PARAMETERS="${2}"|COMMANDLINE_PARAMETERS="${2} inifile=server.ini"|g' ${installs_dir}/${server_dir}/ts3server_startscript.sh

# Set Teamspeak 3 voice port & make sure it's not being used
# UDP port open for clients to connect to
while read -e -p "TeamSpeak 3 Server Voice Port: " -i "9987" voice_port; do
	if [[ $voice_port =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
		s=0
		for each_install in "${installs_dir}/"*; do
			while grep -cq default_voice_port=${voice_port} ${each_install}/server.ini; do
				let "s++"
				break
			done
		done
		[ ${s} != 0 ] && printf "\n${bold}Port ${voice_port} in use, try another port${normal}\n"
		[ ${s} == 0 ] && sed -i -e "s|default_voice_port=|default_voice_port=$voice_port|g" ${installs_dir}/${server_dir}/server.ini && break
	else
		printf "\n${bold}Not a valid port number, try again${normal}\n"
	fi
done

# Set Teamspeak 3 server file transfer port & make sure it's not being used
# TCP Port opened for file transfers
while read -e -p "TeamSpeak 3 Server File Transfer Port: " -i "30033" file_port; do
	if [[ $file_port =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
		s=0
		for each_install in "${installs_dir}/"*; do
			while grep -cq filetransfer_port=${file_port} ${each_install}/server.ini; do
				let "s++"
				break
			done
		done
		[ ${s} != 0 ] && printf "\n${bold}Port ${file_port} in use, try another port${normal}\n"
		[ ${s} == 0 ] && sed -i -e "s|filetransfer_port=|filetransfer_port=$file_port|g" ${installs_dir}/${server_dir}/server.ini && break
	else
		printf "\n${bold}Not a valid port number, try again${normal}\n"
	fi
done

# Set Teamspeak 3 ServerQuery port & make sure it's not being used
# TCP Port opened for ServerQuery connections
while read -e -p "TeamSpeak 3 ServerQuery Port: " -i "10011" query_port; do
	if [[ $query_port =~ ^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$ ]]; then
		s=0
		for each_install in "${installs_dir}/"*; do
			while grep -cq query_port=${query_port} ${each_install}/server.ini; do
				let "s++"
				break
			done
		done
		[ ${s} != 0 ] && printf "\n${bold}Port ${query_port} in use, try another port${normal}\n"
		[ ${s} == 0 ] && sed -i -e "s|query_port=|query_port=$query_port|g" ${installs_dir}/${server_dir}/server.ini && break
	else
		printf "\n${bold}Not a valid port number, try again${normal}\n"
	fi
done

# Setup the TeamSpeak service file
# If CentOS / Fedora
if [ -f /etc/redhat-release ]; then
printf "\n${bold}Generating TeamSpeak 3 service @ /etc/rc.d/init.d/${server_name}${normal}\n"
cat <<EOF > /etc/rc.d/init.d/${server_name}
#!/bin/sh
# chkconfig: 2345 95 20
# description: TeamSpeak 3 Server
# processname: ${server_name}
cd ${installs_dir}/${server_dir}
case "\$1" in
	'start')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start";;
	'stop')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh stop";;
	'restart')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh restart";;
	'status')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh status";;
	'monitor-start')
		# In case of restart of existing monitored instances
		if [ -f ${installs_dir}/${server_dir}/${monitor_name}.pid ]; then
			rm -f ${installs_dir}/${server_dir}/${monitor_name}.pid
		fi
		while true; do
			# If server responds with "No server running" then restart it
			if [[ \$(service ${server_name} status) == *"No server"* ]]; then
				su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start" &> /dev/null
			fi
			sleep 5
		# Echo the PID to a file to be used to kill process later
		done & echo \$! > ${installs_dir}/${server_dir}/${monitor_name}.pid
	;;
	'monitor-stop')
		# Only stop the monitor if we know it's actually started first
		if [ -f ${installs_dir}/${server_dir}/${monitor_name}.pid ]; then
			# Kill monitor process, hide the output, and remove the PID file
			kill -9 \$(cat ${installs_dir}/${server_dir}/${monitor_name}.pid)
			wait \$(cat ${installs_dir}/${server_dir}/${monitor_name}.pid) 2>/dev/null
			rm -f ${installs_dir}/${server_dir}/${monitor_name}.pid
		fi
	;;
	'backup')
		name=backup-\$(date '+%Y-%m-%d-%H%M%S').tar
		printf "\n"
		service ${server_name} stop
		cd /home/teamspeak/${server_dir}
		printf "\n\$(tput bold)Backing up @ /home/teamspeak/${server_dir}/backups/\${name}\$(tput sgr0)\n"
		tar -cf \${name} query_ip_blacklist.txt ts3server.sqlitedb query_ip_whitelist.txt server.ini
		printf "\n"
		service ${server_name} start
		mv \${name} /home/teamspeak/${server_dir}/backups/\${name}	
		printf "\n\$(tput bold)Backup Complete!\$(tput sgr0)\n"
	;;
	*)
	echo "Usage: ${server_name} start|stop|restart|status|monitor-start|monitor-stop|backup"
	exit 1;;
esac
EOF
else
# If Ubuntu / Debian
printf "\n${bold}Generating TeamSpeak 3 service @ /etc/init.d/${server_name}${normal}\n"
cat <<EOF > /etc/init.d/${server_name}
#!/bin/sh
### BEGIN INIT INFO
# Provides: ${server_name}
# Required-Start: networking
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: TeamSpeak Server Daemon
# Description: Starts/Stops/Restarts the TeamSpeak Server Daemon
### END INIT INFO
cd ${installs_dir}/${server_dir}
case "\$1" in
	'start')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start";;
	'stop')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh stop";;
	'restart')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh restart";;
	'status')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh status";;
	'monitor-start')
		# In case of restart of existing monitored instances
		if [ -f ${installs_dir}/${server_dir}/${monitor_name}.pid ]; then
			rm -f ${installs_dir}/${server_dir}/${monitor_name}.pid
		fi
		while true; do
			# If server responds with "No server running" then restart it
			if service ${server_name} status | grep "No server"; then
				su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start" &> /dev/null
			fi
			sleep 5
		# Echo the PID to a file to be used to kill process later
		done & echo \$! > ${installs_dir}/${server_dir}/${monitor_name}.pid
	;;
	'monitor-stop')
		# Only stop the monitor if we know it's actually started first
		if [ -f ${installs_dir}/${server_dir}/${monitor_name}.pid ]; then
			# Kill monitor process, hide the output, and remove the PID file
			kill -9 \$(cat ${installs_dir}/${server_dir}/${monitor_name}.pid)
			wait \$(cat ${installs_dir}/${server_dir}/${monitor_name}.pid) 2>/dev/null
			rm -f ${installs_dir}/${server_dir}/${monitor_name}.pid
		fi
	;;
	'backup')
		name=backup-\$(date '+%Y-%m-%d-%H%M%S').tar
		printf "\n"
		service ${server_name} stop
		cd /home/teamspeak/${server_dir}
		printf "\n\$(tput bold)Backing up @ /home/teamspeak/${server_dir}/backups/\${name}\$(tput sgr0)\n"
		tar -cf \${name} query_ip_blacklist.txt ts3server.sqlitedb query_ip_whitelist.txt server.ini
		printf "\n"
		service ${server_name} start
		mv \${name} /home/teamspeak/${server_dir}/backups/\${name}	
		printf "\n\$(tput bold)Backup Complete!\$(tput sgr0)\n"
	;;
	*)
	echo "Usage: ${server_name} start|stop|restart|status|monitor-start|monitor-stop|backup"
	exit 1;;
esac
EOF
fi

# Change ownership of all TeamSpeak files to TeamSpeak user and make start script executable
chown -R teamspeak:teamspeak ${installs_dir}
chmod +x ${installs_dir}/${server_dir}/ts3server_startscript.sh

# Fixing common error @ http://forum.teamspeak.com/showthread.php/68827-Failed-to-register-local-accounting-service
if ! mount|grep -q "/dev/shm"; then
	echo "tmpfs /dev/shm tmpfs defaults 0 0" >> /etc/fstab
	mount -t tmpfs tmpfs /dev/shm
fi

# Initiate the TeamSpeak service and set to run @ boot
printf "\n${bold}Adding TeamSpeak 3 to boot sequence and setting runlevels${normal}\n"
if [ -f /etc/redhat-release ]; then
	chmod +x /etc/rc.d/init.d/${server_name}
	chkconfig --add ${server_name}
	chkconfig --level 2345 ${server_name} on
else
	chmod +x /etc/init.d/${server_name}
	update-rc.d ${server_name} defaults
fi

read -p $'\x0aDo you want to start your TeamSpeak server now? (y/n) ' -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	printf "\n${bold}Starting TeamSpeak 3 for the first time${normal}\n"
	# Start the server for the first time and display the loginname, password, and token
	service ${server_name} start
	# Wait 3 seconds and display some useful info
	sleep 3
	printf "\n\Install Complete"
	printf "\nTeamSpeak 3 running @ ${bold}$voice_ip:$voice_port${normal}"
	printf "\n${bold}Usage:${normal} service teamspeak"$([ $has_license ] && echo "-${licensed_server_name}")" start|stop|restart|status|monitor-start|monitor-stop|backup\n"
else
	printf "\n\nInstall Complete"
	printf "\nTeamSpeak 3 configured @ ${bold}$voice_ip:$voice_port${normal}"
	printf "\n${bold}Usage:${normal} service teamspeak"$([ $has_license ] && echo "-${licensed_server_name}")" start|stop|restart|status|monitor-start|monitor-stop|backup\n"
fi

