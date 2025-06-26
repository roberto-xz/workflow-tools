#!/bin/bash

#
# roberto-xz 26,Jul 2025	
#

pure-ftpd /etc/pure-ftpd/pure-ftpd.conf &
smbd &
/usr/sbin/sshd &

echo "======================================="
echo " Services started!"
echo " SSH available at: $(hostname -I | awk '{print $1}'):22"
echo " FTP available at: $(hostname -I | awk '{print $1}'):21"
echo " Samba ports: 139, 445"
echo " Login with user: admin"
echo "======================================="