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
	echo -e "\t${purpleColor}i)${endColor} ${grayColor}Search by IP address${endColor}"
	echo -e "\t${purpleColor}m)${endColor} ${grayColor}Search machine name${endColor}"
	echo -e "\t${purpleColor}h)${endColor} ${grayColor}Show help panel${endColor}\n"
}

function searchMachine() {
	machineName="$1"

	if [ ! -f bundle.js ]; then
		echo -e "\n${redColor}[!]${endColor} File bundle.js (database) does not exist!"
		updateFiles
	fi

	echo -e "\n${yellowColor}[+]${endColor} Listing properties of the machine ${purpleColor}$machineName${endColor}\n"

	# The following oneliner does: cat the bundle file | filter from name: <machineName> until /resuelta:/ | eliminates with grep -v and add more than one value to grep with -E | delete all the matches with '"' | delete all the commas | substitute all the spaces(s/^ ) for nothing(//)
	cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function updateFiles() {
	if [ ! -f bundle.js ]; then
		echo -e "\n${yellowColor}[+]${endColor} Updating..."
		curl -s $main_url >bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${greenColor}[+]${endColor} Files updated!"
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

function searchIP() {
	ipAddress="$1"

	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

	echo -e "\n${yellowColor}[+]${endColor} The machine for the IP ${grayColor}$ipAddress${endColor} is ${purpleColor}$machineName${endColor}"

	searchMachine "$machineName"
}

# Indicators
declare -i parameter_counter=0

# Menu alternatinves:
# We use the ":" when the flag will take an argument
# We use the $OPTARG to take the argument that we are passing and assign it to a variable
while getopts "m:ui:h" arg; do
	case $arg in
	m)
		machineName=$OPTARG
		let parameter_counter+=1
		;;
	u) let parameter_counter+=2 ;;
	i)
		ipAddress=$OPTARG
		let parameter_counter+=3
		;;
	h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine "$machineName"
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP "$ipAddress"
else
	helpPanel
fi
