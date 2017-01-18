#!/bin/sh

function show()
{
	grep -e "Host [a-zA-Z1-9].*" ~/.ssh/config|awk '{print $2}'|cat -n
}

function init()
{
	softwareCheck
	sshInit
	echo "3.initialization succeeded，do 's help' to see help"	
}

function sshInit()
{
	echo "2.init ssh config"
	if [ ! -d ~/.ssh ]; then
		echo "    create ~/.ssh directory"
		mkdir ~/.ssh
		echo "    create ~/.ssh directory ✔"
	else
		echo "    ~/.ssh directory already exist ✔"
	fi
	if [ ! -e ~/.ssh/config ]; then
		echo "    create ~/.ssh/config file"
		touch ~/.ssh/config
		echo "    create ~/.ssh/config file ✔"
	else
		echo "    ~/.ssh/config file already exist ✔"
	fi
	if [ ! -e ~/.ssh/id_rsa.pub ]; then
		echo "    create ~/.ssh/id_rsa.pub file"
		ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' > /dev/null
		echo "    create ~/.ssh/id_rsa.pub file ✔"
	else
		echo "    ~/.ssh/id_rsa.pub file already exist ✔"
	fi
	if [ `grep "ServerAliveInterval" ~/.ssh/config|wc -l` -eq 0 ]; then
		echo "    add ServerAliveInterval&Session config"
		echo -e "ServerAliveInterval 60\nHost *\nControlMaster auto\nControlPath ~/.ssh/master-%r@%h:%p" > /tmp/sshconfig
		cat ~/.ssh/config >> /tmp/sshconfig
		mv ~/.ssh/config ~/.ssh/config.bak
		mv /tmp/sshconfig ~/.ssh/config
		echo "    add ServerAliveInterval&Session config ✔"
	fi
}

function softwareCheck()
{
	echo "1.check if the necessary software is installed"
	type ssh-keygen >/dev/null 2>&1 || { echo >&2 "there is no 'ssh-keygen' found, please install first"; exit 1; }
	echo "    ssh-keygen installed ✔"
	type ssh-copy-id >/dev/null 2>&1 || { echo >&2 "there is no 'ssh-copy-id' found, please install first(brew install ssh-copy-id)"; exit 1; }
	echo "    ssh-copy-id installed ✔"
}

function login()
{
#	gbk
	var=$(echo $1 | bc 2>/dev/null)
	if [ "$var" = "$1"  ]; then
		host=$(grep -e "Host [a-zA-Z1-9].*" ~/.ssh/config|awk '{print $2}'|sed -n "$var"p)
		ssh $host
	else
		ssh $1
	fi
#	utf8
}

function add()
{	
	if [ $# = 3 ]; then
		ssh-copy-id -i ~/.ssh/id_rsa.pub `whoami`@$3
	elif [ $# = 4 ]; then
		ssh-copy-id -i ~/.ssh/id_rsa.pub $4@$3
	elif [ $# = 5 ]; then
		ssh-copy-id -i ~/.ssh/id_rsa.pub -p $5 $4@$3
	fi
	echo "Host $2" >> ~/.ssh/config
	echo "HostName $3" >> ~/.ssh/config
	if [ $# = 3 ]; then
		echo "User `whoami`" >> ~/.ssh/config
	elif [ $# = 4 ]; then
		echo "User $4" >> ~/.ssh/config	
	elif [ $# = 5 ]; then
		echo "Port $5" >> ~/.ssh/config
	fi
	echo "" >> ~/.ssh/config
	echo "add done"
}

function help()
{
	echo "To use this script, make sure the machine contains ssh-keygen and ssh-copy-id"
	echo "1) s init                            --Script Environment Initialization (Execute on first use)"
	echo "2) s add Host HostName [User] [Port] --Add the login machine information;"
    echo "                                     --a)Host for the custom machine tag"
	echo "                                     --b)HostName is the machine IP or machine name"
    echo "                                     --c)User and Port are the machine user name and SSH port number which are optional(default vallue is the current user name and port 22)"
	echo "3) s                                 --display the login list"
	echo "4) s number|Host                     --Use the number or Host which is the result of 's' to quickly login into the machine"
	echo "5) s help                            --show the help infomation"
}


if [ $# = 0 ]; then
	show
elif [ $# = 1 ]; then
	if [ $1 = "init" ]; then
		init
	elif [ $1 = "help" ]; then
		help
	else
		login $1
	fi
elif [ $# = 3 ] || [ $# = 4 ] || [ $# = 5 ]; then
	if [ $1 = "add" ]; then
		add $@
	fi
else
	help
fi
