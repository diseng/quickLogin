#!/bin/bash

softwareCheck()
{
	echo "1.check if the necessary software is installed"
	type wget >/dev/null 2>&1 || { echo >&2 "there is no 'wget' found, please install first"; exit 1; }
	echo "    wget installed ✔"
	type ssh-keygen >/dev/null 2>&1 || { echo >&2 "there is no 'ssh-keygen' found, please install first"; exit 1; }
	echo "    ssh-keygen installed ✔"
	type ssh-copy-id >/dev/null 2>&1 || { echo >&2 "there is no 'ssh-copy-id' found, please install first(brew install ssh-copy-id)"; exit 1; }
	echo "    ssh-copy-id installed ✔"
}

installScript()
{
	echo "2.download quickLogin.sh"
	wget -O /usr/local/bin/quickLogin.sh https://raw.githubusercontent.com/diseng/quickLogin/master/quickLogin.sh >/dev/null 2>&1
	if  [ $? -eq 0 ]; then
        echo "    download successful ✔"
        filePath="/usr/local/bin/quickLogin.sh"
	else
		echo "    download failed, use $HOME to replace /usr/local/bin and download again ×";
		wget -O ~/quickLogin.sh https://raw.githubusercontent.com/diseng/quickLogin/master/quickLogin.sh >/dev/null 2>&1
		echo "    download successful ✔"
		filePath="$HOME/quickLogin.sh"
	fi
	chmod 755 $filePath
	if [ `echo $SHELL|grep 'zsh'|wc -l` -eq 1 ]; then
		shConfigFile=".zshrc"		
	else
		shConfigFile=".bashrc"
	fi
	echo "3.add alias for $filePath"
	echo 'alias s="'$filePath'"' >> ~/$shConfigFile
	echo "    add alias successful ✔"
}

install()
{
	softwareCheck
	installScript
	echo ""
	echo "❀ Successful installation，please do 'source ~/$shConfigFile' to make the script take effect"
	echo "❀ do 's help' to see help, if no command 's', please open a new command line window tab"
} 

install
