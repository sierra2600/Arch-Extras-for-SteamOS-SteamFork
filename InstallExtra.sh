#!/bin/bash

set +bvx -h

export notReady="We're sorry but this script is not ready for use. Have a nice day!"
echo -e "${notReady}"
zenity --error --text="${notReady}"
exit

export preHandRep="We're sorry but it appears that "
export handRepeat=", from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day!"
# Checking if this is being ran in Desktop Mode or ssh / virtual tty session
xdpyinfo &> /dev/null
if [ $? -eq 0 ]
then
	# Running in Desktop Mode, will continue past this 'if then'
else
	echo -e "${preHandRep}this is not being ran in Desktop mode${handRepeat}"
	# insert script self removal call here
	exit
fi

# Checking what version of SteamOS/SteamFork is running, 3.6.x or 3.7.x
steamos_version=$(cat /etc/os-release | grep -i version_id | cut -d "=" -f2)
echo $steamos_version | grep -e 3.4 -e 3.5
if [ $? -ne 0 ]
then
	# SteamOS?SteamFork 3.6.x or 3.7.x found, will continue past this 'if then'
else
	export oldMess="${preHandRep}your system is running an outdated version of SteamOS/SteamFork ( $steamos_version )${handRepeat}"
	echo -e "${oldMess}"
	zenity --error --text="${oldMess}"
	# insert script self removal call here
	exit
fi

# Checking the current 'whoami' 'passwd' is set against 'sudo'
if [ "$(passwd --status $(whoami) | tr -s " " | cut -d " " -f 2)" == "P" ]
then
	read -s -p "Please enter current sudo password: " current_password ; echo
	echo -e "Checking if the sudo password is correct"
	# echo -e "$current_password\n" | sudo -S -k ls &> /dev/null   # known working
	zenity --password | sudo -S -k ls &> /dev/null

	if [ $? -eq 0 ]
	then
		echo -e "The provided Administorator (sudo) password is correct"
		# Will continue past this 'if then'
	else
		export WrongPass="${preHandRep}the password you've entered is incorrect${handRepeat}"
		echo -e "${WrongPass}"
		zenity --error --text="${WrongPass}"
		# insert script self removal call here
		exit
	fi
else
	export AdNotSet="${preHandRep}the Administrator (sudo) password has not been set${handRepeat}"
	echo -e "${AdNotSet}"
	zenity --error --text="${AdNotSet}"
	# insert script self removal call here
	# "passwd"
	exit
fi

# Insert code here
# inspect /etc/pacman.conf for broken and comment them out (without revertion) :
	# [steamfork]
	# Server = file:///home/fewtarius/distribution/release/repos/3.7/os/x86_64
	# Include = /etc/pacman.d/steamfork-mirrorlist
grep '\[steamfork\]' /etc/pacman.conf

# check saved date in: /etc/pacman.d/mirrorlist

sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo pacman -S reflector
sudo reflector --protocol https --sort rate --connection-timeout 1 --download-timeout 1 --threads 1 --age 1 --delay 1 --completion-percent 100 --save /etc/pacman.d/mirrorlist
sudo cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist

# Temporary:
	# comment out [testing]
	# Add: [extra]
	# remove # from #Include = /etc/pacman.d/mirrorlist




if [ ! $? = 0 ]; then
    echo "USER: Operation cancelled by the user."
	# insert script self removal call here
    exit 0
fi

# commands to add: sudo steamos-readonly disable && sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --populate holo && sudo pacman -S <linker>
