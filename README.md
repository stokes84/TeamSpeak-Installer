<h1 align='center'>Teamspeak 3 Server Installer</h1>

<br>

Compatiblity
----------------
+ CentOS 6.x 32bit
+ CentOS 6.x 64bit
+ Not Tested on CentOS 5.x

<br/>

Default Ports
-----------------
These need to be open and can be changed during install
+ 9987 UDP - Voice
+ 30033 TCP - File Transfer
+ 10011 TCP - Server Query
+ 2008 TCP - License Check (only needed if using a license)

<br/>

Install
-----------

#### Run the following one liner as root
```
wget -q https://raw.githubusercontent.com/stokes84/Teamspeak-Installer/master/install.sh && bash install.sh && rm -f install.sh
```
Teamspeak application files are located @ /home/ts3user/ts3-server<br/>
Teamspeak service file is located @ /etc/rc.d/init.d/teamspeak

<br/>

Usage
---------

Start Teamspeak Server: ```service teamspeak start```

Stop Teamspeak Server: ```service teamspeak stop```

Restart Teamspeak Server: ```service teamspeak restart```

Show Teamspeak Server Status: ```service teamspeak status```

<br/>

Uninstall
-------------

#### Run the following one liner as root
```service teamspeak stop && userdel -r ts3user && rm -f /etc/rc.d/init.d/teamspeak```
