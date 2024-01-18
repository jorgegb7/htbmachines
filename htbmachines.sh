#!/bin/bash

# Author: Jorge Garcia Bermejo

#Colors
greenColor="\e[0;32m\033[1m"
endColor="\033[0m\e[0m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"

function ctrl_c() {
	echo -e "\n\n${redColor}[!]${endColor} Exiting..."
	tput cnorm && exit 1
}

# Ctrl+c to trap to abort program at any point
trap ctrl_c INT

# GLOBAL VARIABLES
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel() {
	echo -e "\n${yellowColor}[+]${endColor}${grayColor} Uso:${endColor}"
	echo -e "\t${purpleColor}u)${endColor} ${grayColor}Refresh json file with data${endColor}"
	echo -e "\t${purpleColor}m)${endColor} ${grayColor}Search machine name${endColor}"
	echo -e "\t${purpleColor}h)${endColor} ${grayColor}Show help panel${endColor}\n"
}

function searchMachine() {
	echo "$1"

	echo "$machineName"
}

function updateFiles() {
	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n${yellowColor}[+]${endColor} Updating..."
		curl -s $main_url >bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${greenColor}[+]${endColor} Files updated!"
		tput cnorm
	else
		echo -e "${yellowColor}[!]${endColor} File already exists, looking for updates ..."
		curl -s $main_url >tmpbundle.js
		js-beautify tmpbundle.js | sponge tmpbundle.js
		md5_temp_value=$(md5sum tmpbundle.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "${yellowColor}[!]${endColor} File is up to date. Nothing to do."
			rm tmpbundle.js
		else
			echo -e "${greenColor}[+]${endColor} File was outdated. Pulled last version."
			rm bundle.js
			mv tmpbundle.js bundle.js
		fi
	fi
}

# Indicators
declare -i parameter_counter=0

# Menu alternatinves:

while getopts "m:uh" arg; do
	case $arg in
	m)
		machineName=$OPTARG
		let parameter_counter+=1
		;;
	u) let parameter_counter+=2 ;;
	h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
else
	helpPanel
fi
