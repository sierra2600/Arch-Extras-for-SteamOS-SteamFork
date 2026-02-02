exit  #This script is not ready to be used
#!/bin/bash

# Checking if this is being ran in Desktop Mode or ssh / virtual tty session
xdpyinfo &> /dev/null
if [ $? -eq 0 ]
then
	# Running in Desktop Mode, will continue past this 'if then'
else
  echo -e "We're sorry but it appears that this is not being ran in Desktop mode, from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day!"
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
	echo "We're sorry but it appears that your system is running an outdated version of SteamOS/SteamFork ( $steamos_version ), from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day! (This will only work on SteamOS/SteamFork. Are you trying to run this on Arch? Get out here, go on, get, you're silly)"
	zenity --error --text="We're sorry but it appears that your system is running an outdated version of SteamOS/SteamFork ( $steamos_version ), from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day! (This will only work on SteamOS/SteamFork. Are you trying to run this on Arch? Get out here, go on, get, you're silly)"
	# insert script self removal call here
	exit
fi

# Checking the current 'whoami' 'passwd' is set against 'sudo'
if [ "$(passwd --status $(whoami) | tr -s " " | cut -d " " -f 2)" == "P" ]
then
	read -s -p "Please enter current sudo password: " current_password ; echo
	echo Checking if the sudo password is correct.
	echo -e "$current_password\n" | sudo -S -k ls &> /dev/null

	if [ $? -eq 0 ]
	then
		echo Sudo password is good!
	else
		zenity --error --text="We're sorry but it appears that the password you've entered is incorrect, from personal experience, I will recommend doing further reading into what you want to be doing in order to prevent inoperablity to and data loss on your system. Have a nice day!"
		# insert script self removal call here
		exit
	fi
else
	echo Sudo password is blank! Setup a sudo password first and then re-run script!
	zenity --error --text="We're sorry but it appears that the Administrator (sudo) password has not been set"
	
	passwd
	exit
fi
# commands to add: sudo steamos-readonly disable && sudo pacman-key --init && sudo pacman-key --populate archlinux && sudo pacman-key --populate holo && sudo pacman -S <linker>
