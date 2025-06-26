#!/bin/bash

function configure() {
	echo "[*] Installing dependencies, please wait..."
	apt update -y > /dev/null 2>&1
	apt install -y mdadm micro curl wget sudo net-tools openssh-server pure-ftpd tmux samba > /dev/null 2>&1
	echo "[+] Dependencies installed."

	echo "[*] Creating 'nas_users' group..."
	groupadd nas_users
	echo "[+] Group created."

	echo "[*] Creating 'ssh_user' user..."
	useradd -m -s /bin/bash -G nas_users,sudo ssh_user
	echo "ssh_user:toor" | chpasswd
	echo "[+] Admin user created. Default password: toor"

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

	echo "[*] Creating no login shell..."
	echo "/sbin/nologin" >> /etc/shells
	echo "[+] Done."
}
configure
