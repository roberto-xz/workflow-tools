#
# roberto-xz 26,Jul 2025
#

function config_flb() {
	local user_name="$1"
	local user_pass="$2"
	local user_home="/media/${user_name}/"
	local flbw_conf="/etc/filebrowser/config.db"

	filebrowser -d "$flbw_conf" users add "$user_name" "$user_pass" --perm.admin --scope "$user_home"
	return 0
}

function config_smb() {
	local user_name="$1"
	local user_pass="$2"
	local user_home="/media/${user_name}"

	(echo "$user_pass"; echo "$user_pass") | smbpasswd -s -a "$user_name"

	cat <<EOF >> /etc/samba/smb.conf
[${user_name}]
    path = ${user_home}
    valid users = ${user_name}
    read only = no
    browsable = no
    force user  = ${user_name}
    force group = nas_users
EOF

	return 0
}

function list_users() {
local base_dir="/mnt/users"
	local count=1
	clear
	echo "──────────────────────────────────────"
	local has_users=false
	for user in "$base_dir"/*; do
		[[ -d "$user" ]] || continue
		echo "  $count. $(basename "$user")"
		((count++))
		has_users=true
	done

	if ! $has_users; then
		echo "  [!] No users found in $base_dir"
	fi
	echo "──────────────────────────────────────"
	read -p "Press [Enter] to return..." _
}

function remove_smb() {
	local user_name="$1"
	smbpasswd -x "$user_name"

	sed -i "/^\[$user_name\]/,/^\[.*\]/ { /^\[$user_name\]/d; /^\[.*\]/!d }" /etc/samba/smb.conf
	sed -i "/^\[$user_name\]/d" /etc/samba/smb.conf
}

function remove_flb() {
	local user_name="$1"
	local flbw_conf="/etc/filebrowser/config.db"

	filebrowser -d "$flbw_conf" users rm "$user_name"
}


function delete_user() {
	read -p "type user name:" user_name
	if [ -d "/mnt/users/${user_name}" ]; then
		if [ -z "$(ls -A "/media/${user_name}" 2>/dev/null)" ]; then
			remove_smb "$user_name"
			#remove_flb "$user_name"

			userdel "${user_name}"
			rm -rf "/mnt/users/${user_name}"
			rm -rf "/media/${user_name}"
			return 0
		else
			echo "the user has volumes, please delete the volumes first"
			return 1
		fi
	fi

	echo "User not found"
	return 1
}


function create_user() {
	read -p "type user name: " user_name
	read -p "type user pass: " user_pass

	#verify if user exist
	if [[ -d "/mnt/users/${user_name}" ]]; then
		echo "user existis"
		return 1
	fi

	#make/configure mnt users folder
	mkdir -p "/mnt/users/${user_name}";
	chown "root:root" "/mnt/users/${user_name}";
	chmod u=rwx,g=---,o=--- "/mnt/users/${user_name}"

	#make/configure media users folder
	mkdir -p "/media/${user_name}"
	useradd -d "/media/${user_name}" -M -s /sbin/nologin "$user_name" -g "nas_users"
	echo -e "$user_pass\n$user_pass" | passwd "$user_name"
	chown "${user_name}:nas_users" "/media/${user_name}"
	chmod u=rx-,g=---,0=--- "/media/${user_name}"


	config_smb "$user_name" "$user_pass"
	#config_flb "$user_name" "$user_pass"

	echo "user created successfully"
	echo "──────────────────────────────────────"
	read -p "Press [Enter] to return..." _
	#echo "there was an error creating the user"
	return 1
}

function __USER_TOOLS__() {
	while true; do
		clear
		echo "┌────────────────────────────────────┐"
		echo "│        USER TOOLS v1.0.0           │"
		echo "├────────────────────────────────────┤"
		echo "│  [N] Create New User               │"
		echo "│  [D] Delete User                   │"
		echo "│  [L] List Users                    │"
		echo "│  [E] Back to Main Menu             │"
		echo "└────────────────────────────────────┘"
		read -p "Select an option: " option

		case "${option^^}" in
			N) create_user;;
			D) delete_user;;
			L) list_users;;
			E) break;;
			*) echo "Invalid option. Try again." && sleep 1;;
		esac
	done
}