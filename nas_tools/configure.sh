#!/bin/bash

#
# roberto-xz 26,Jul 2025
#

echo "[*] Installing dependencies, please wait..."
apt update  -y > /dev/null 2>&1
apt install -y tcc mdadm micro curl wget sudo net-tools openssh-server pure-ftpd tmux samba > /dev/null 2>&1
echo "[+] Dependencies installed."

echo "[*] Creating 'nas_users' group..."
groupadd nas_users
echo "[+] Group created."

echo "[*] Creating 'ssh_user' user..."
useradd -m -s /bin/bash -G nas_users ssh_user > /dev/null 2>&1
echo "ssh_user:toor" | chpasswd > /dev/null 2>&1
echo "[+] Admin user created. Default password: toor"

echo "[*] Setting up Samba config..."
rm -f /etc/samba/smb.conf
cp configs/smb.conf /etc/samba/smb.conf


echo "[*] Setting up Pure-FTPd config..."
rm -f /etc/pure-ftpd/pure-ftpd.conf
mkdir -p /etc/pure-ftpd/
cp configs/pure-ftpd.conf /etc/pure-ftpd/pure-ftpd.conf


echo "[*] Setting interface scripts..."
cp app.sh user_tools.sh vols_tools.sh /usr/sbin/
chown root:nas_users /usr/sbin/app.sh
chown root:nas_users /usr/sbin/user_tools.sh
chown root:nas_users /usr/sbin/vols_tools.sh

chmod u=rwxs,g=rx-,o=--- /usr/sbin/app.sh
chmod u=rwx,g=---,o=--- /usr/sbin/user_tools.sh
chmod u=rwx,g=---,o=--- /usr/sbin/vols_tools.sh

echo "[*] compiling interface scripts..."
tcc -o /usr/sbin/run_app run_app.c
chown root:nas_users /usr/sbin/run_app
chmod u=rwxs,g=rx-,o=--- /usr/sbin/run_app

echo "[*] removing trash files..."
cd /; rm -rf /opt/projeto;
echo "[+] Done."

echo "[*] Creating SSH runtime path..."
mkdir -p /run/sshd

echo "[*] Creating no login shell..."
echo "/sbin/nologin" >> /etc/shells

pure-ftpd /etc/pure-ftpd/pure-ftpd.conf &
smbd &
echo "======================================="
echo " Services started!"
echo " SSH available at: $(hostname -I | awk '{print $1}'):22"
echo " FTP available at: $(hostname -I | awk '{print $1}'):21"
echo " Samba ports: 139, 445"
echo " Login with (ssh): ssh_user:toor"
echo "======================================="
/usr/sbin/sshd -D
