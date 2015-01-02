<h1 align='center'>TeamSpeak 3 Server Installer</h1>

<br>

Compatibility
----------------
+ CentOS 6/7 32bit or 64bit
+ Ubuntu 12/14 32bit or 64bit
+ Debian 6/7 32bit or 64bit
+ Fedora 19/20 32bit or 64bit

<br/>

Default Ports
-----------------
These need to be open and can be changed during install
+ 9987 UDP - Voice
+ 30033 TCP - File Transfer
+ 10011 TCP - ServerQuery
+ 2008 TCP - License Check (only needed if using a license)

<br/>

Install
-----------

#### Run the following one liner as root
```
wget --no-check-certificate https://raw.githubusercontent.com/stokes84/TeamSpeak-Installer/master/install.sh; bash install.sh; rm -f install.sh
```
<strong>Note:</strong> "SERVER" denotes the server name you set during install.<br/>
<strong>Note:</strong> TeamSpeak application files are located @ /home/teamspeak/SERVER<br/>
<strong>Note:</strong> TeamSpeak service file is located @ /etc/rc.d/init.d/teamspeak-SERVER (CentOS) or /etc/init.d/teamspeak-SERVER (Ubuntu) <br/>

<br/>

Usage
---------

<strong>Note:</strong> TeamSpeak Server instances automatically start @ boot.

Start TeamSpeak Server: ```service teamspeak-SERVER start```

Stop TeamSpeak Server: ```service teamspeak-SERVER stop```

Restart TeamSpeak Server: ```service teamspeak-SERVER restart```

Show TeamSpeak Server Status: ```service teamspeak-SERVER monitor```

Monitor TeamSpeak Server (check & start if needed every 5s): ```service teamspeak-SERVER status```

Backup TeamSpeak Server (black/white list, ini, and db): ```service teamspeak-SERVER backup```

<br/>

Uninstall
-------------

### CentOS
#### Single Instance (no license)
```
service teamspeak stop && chkconfig --del teamspeak && rm -f /etc/rc.d/init.d/teamspeak && userdel -r teamspeak
```
<br>
#### Multi-Instance (licensed)
List all instances installed
```
chkconfig --list | grep "teamspeak"
```
Remove each instance as needed
```
service teamspeak-SERVER stop && chkconfig --del teamspeak-SERVER && rm -f /etc/rc.d/init.d/teamspeak-SERVER
```
Remove user lastly if removing all traces of TeamSpeak
```
userdel -r teamspeak
```
<br>
### Ubuntu / Debian
#### Single Instance (no license)
```
service teamspeak stop && update-rc.d -f teamspeak remove && rm -f /etc/init.d/teamspeak && userdel -r teamspeak
```
<br>
#### Multi-Instance (licensed)
List all instances installed
```
service --status-all |& grep teamspeak
```
Remove each instance as needed
```
service teamspeak-SERVER stop && update-rc.d -f teamspeak-SERVER remove && rm -f /etc/init.d/teamspeak-SERVER
```
Remove user lastly if removing all traces of TeamSpeak
```
userdel -r teamspeak
```
