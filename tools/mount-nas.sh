#!/bin/bash
read -s -p "Enter NAS password: " PASSWORD
echo

sudo mount -t cifs //192.168.1.2/share /mnt/NAS -o vers=1.0,username=ed,password="$PASSWORD",uid=1000,gid=1000
