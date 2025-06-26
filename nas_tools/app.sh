#!/bin/bash

#
# roberto-xz 26,Jul 2025	
#

source user_tools.sh
source vols_tools.sh

function set_disks_len() {
	read -p "How many disks do you want to simulate? " lenght
	
	for i in $( seq 0 $lenght ); do 
		[[ -e /dev/loop$i ]] || mknod -m660 /dev/loop$i b 7 $i
		chown root:disk /dev/loop$i
	done
	echo "[+] Virtual disks created."
	sleep 2
	return 0
}

function __MAIN__() {
	while true; do
		clear
		echo "┌────────────────────────────────────┐"
		echo "│        NAS-SIMULATOR v1.0.0        │"
		echo "├────────────────────────────────────┤"
		echo "│  [D] Setup Disks                   │"
		echo "│  [U] User Tools                    │"
		echo "│  [V] Volume Tools                  │"
		echo "│  [E] Exit                          │"
		echo "└────────────────────────────────────┘"
		read -p "Select an option: " option
		
		case "${option^^}" in 
			D) set_disks_len;;
			U) __USER_TOOLS__;;
			V) __VOLUM_TOOLS__;;
			E) break;;
			*) echo "Invalid option. Try again." && sleep 1;;
		esac
	done
}
__MAIN__