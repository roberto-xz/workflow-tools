#!/bin/bash

#
# roberto-xz 26,Jul 2025	
#

function configure() {
	echo "[*] Installing dependencies, please wait..."
	apt update -y > /dev/null 2>&1
	apt install -y micro mdadm curl wget sudo net-tools openssh-server pure-ftpd tmux samba > /dev/null 2>&1
	echo "[+] Dependencies installed."

	echo "[*] Creating 'nas_users' group..."
	groupadd nas_users
	echo "[+] Group created."

	echo "[*] Creating 'admin' user..."
	useradd -m -s /bin/bash -G nas_users,sudo admin
	echo "admin:admin123" | chpasswd
	echo "[+] Admin user created. Default password: admin123"

	echo "[*] Setting up Samba config..."
	rm -f /etc/samba/smb.conf
	cp configs/smb.conf /etc/samba/smb.conf
	echo "[+] Samba config applied."

	echo "[*] Setting up Pure-FTPd config..."
	rm -f /etc/pure-ftpd/pure-ftpd.conf
	mkdir -p /etc/pure-ftpd/
	cp configs/pure-ftpd.conf /etc/pure-ftpd/pure-ftpd.conf
	echo "[+] Pure-FTPd config applied."

	echo "[*] Creating SSH runtime path..."
	mkdir -p /run/sshd
	echo "[+] Done."
}
configure