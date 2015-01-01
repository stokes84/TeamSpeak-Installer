<h1 align='center'>Teamspeak 3 Server Installer</h1>

<br>

Compatibility
----------------
+ CentOS 6/7 32bit or 64bit
+ Ubuntu 12/14 32bit or 64bit

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
wget --no-check-certificate https://raw.githubusercontent.com/stokes84/Teamspeak-Installer/master/install.sh; bash install.sh; rm -f install.sh
```
<strong>Note:</strong> "SERVER" denotes the server name you set during install.<br/>
<strong>Note:</strong> Teamspeak application files are located @ /home/teamspeak/SERVER<br/>
<strong>Note:</strong> Teamspeak service file is located @ /etc/rc.d/init.d/teamspeak-SERVER (CentOS) or /etc/init.d/teamspeak-SERVER (Ubuntu) <br/>

<br/>

Usage
---------

<strong>Note:</strong> Teamspeak Server instances automatically start @ boot.

Start Teamspeak Server: ```service teamspeak-SERVER start```

Stop Teamspeak Server: ```service teamspeak-SERVER stop```

Restart Teamspeak Server: ```service teamspeak-SERVER restart```

Show Teamspeak Server Status: ```service teamspeak-SERVER status```

<br/>

Uninstall
-------------

#### CentOS
<br>
##### Single Instance (no license)
```
service teamspeak stop && chkconfig --del teamspeak && rm -f /etc/rc.d/init.d/teamspeak && userdel -r teamspeak
```

##### Multi-Instance (licensed)
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


#### Ubuntu
<br>
##### Single Instance (no license)
```
service teamspeak stop && update-rc.d -f teamspeak remove && rm -f /etc/init.d/teamspeak && userdel -r teamspeak
```

##### Multi-Instance (licensed)
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
