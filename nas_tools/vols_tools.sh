#
# roberto-xz 26,Jul 2025
#

function create_volume() {
	read -p "type user name(owner): " user_owner
	read -p "type user volume name:"  volum_name
	read -p "type number of disks:"   disks_leng
	read -p "type RAID mode (0,1,5,6,10): " raid_type

	if [[ ! -d "/mnt/users/${user_owner}" ]]; then
		echo "the user ${user_owner} does not exist"
		return 1
	fi

	local dist_disk="/mnt/users/${user_owner}/${volum_name}"
	local disk_name="${user_owner}_${volum_name}"
	local madm_name="/dev/md/${disk_name}"
	local loop_devs=()

	if [[ -d "$dist_disk" ]]; then
		echo "volume ${volum_name} already exists for this user"
		return 1
	fi

	mkdir -p "${dist_disk}"

	for ((i=0; i<disks_leng; i++)); do
		read -p "type length in GiB for disk${i}: " disk_size
		img_path="${dist_disk}/${disk_name}_${i}.img"
		fallocate -l "${disk_size}G" "$img_path"
		loop_path=$(losetup -f --show "$img_path")
		loop_devs+=("$loop_path")
	done

	mdadm --quiet --create "$madm_name" --level="$raid_type" --raid-devices="$disks_leng" "${loop_devs[@]}"
	sleep 3; mkfs.ext4 "$madm_name"
	mount --mkdir "$madm_name" "/media/${user_owner}/${volum_name}"

	chown "${user_owner}":"nas_users" "/media/${user_owner}/${volum_name}"
	chmod u=rwx,g=---,o=--- "/media/${user_owner}/${volum_name}"
	echo "volume created successfully"
	return 0
}

function list_volumes() {
	read -p "Enter username: " user_name
	local base_dir="/mnt/users/${user_name}"
	local count=1
	clear
	echo "──────────────────────────────────────"

	if [[ ! -d "$base_dir" ]]; then
		echo "  [!] User '$user_name' does not exist."
	else
		local has_volumes=false
		for volume in "$base_dir"/*; do
			[[ -d "$volume" ]] || continue
			echo "  $count. $(basename "$volume")"
			((count++))
			has_volumes=true
		done

		if ! $has_volumes; then
			echo "  [!] No volumes found for user '$user_name'."
		fi
	fi
	echo "──────────────────────────────────────"
	read -p "Press [Enter] to return..." _
}

function delete_volume() {
	read -p "type user name(owner): " user_owner
	read -p "type user volume name:"  volum_name

	local dist_disk="/mnt/users/${user_owner}/${volum_name}"
	local disk_name="${user_owner}_${volum_name}"
	local md_path="/dev/md/${disk_name}"
	local mount_path="/media/${user_owner}/${volum_name}"

	if mountpoint -q "$mount_path"; then
		umount "$mount_path" || echo "error unmounting volume $mount_path"
	fi

	if [ -e "$md_path" ]; then mdadm --stop "$md_path"; fi
	if [ -d "$dist_disk" ]; then
		losetup -j "${dist_disk}/${disk_name}_"*.img 2>/dev/null | cut -d: -f1 | while read loop; do
			losetup -d "$loop"
		done
	fi

	echo "removing .img files"; rm -f "${dist_disk}/${disk_name}_"*.img 2>/dev/null
	echo "removing mount path"; rm -rf "${mount_path}"
	echo "removing volum path"; rm -rf "${dist_disk}"
	echo "the volume was deleted successfully"
	return 0
}

function __VOLUM_TOOLS__() {
	while true; do
		clear
		echo "┌────────────────────────────────────┐"
		echo "│       VOLUME TOOLS v1.0.0          │"
		echo "├────────────────────────────────────┤"
		echo "│  [N] Create New Volume             │"
		echo "│  [D] Delete Volume                 │"
		echo "│  [L] List User Volumes             │"
		echo "│  [E] Back to Main Menu             │"
		echo "└────────────────────────────────────┘"
		read -p "Select an option: " option

		case "${option^^}" in
			N) create_volume;;
			D) delete_volume;;
			L) list_volumes;;
			E) break;;
			*) echo "Invalid option. Try again." && sleep 1;;
		esac
	done
}