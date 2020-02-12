#!/bin/bash

#sudo yum -y update
sudo yum install -y mc mdadm smartmontools hdparm gdisk lvm2 device-mapper tree wget nano

#sudo grub2-mkconfig -o /boot/grub2/grub.cfg
#sudo grub2-set-default 0
			
sudo mdadm --zero-superblock --force /dev/sd{c,d,e,f,g}
sudo mdadm --create --verbose /dev/md2 -l 10 -n 4 /dev/sd{c,d,e,f}
sudo mdadm /dev/md2 --add /dev/sdg
sudo mdadm -D /dev/md2

sudo mkdir -p /etc/mdadm
echo "DEVICE partitions" | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf

echo "DEVICE partitions" | sudo tee -a /etc/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm.conf

sudo parted -s /dev/md2 mklabel gpt

sudo parted /dev/md2 mkpart primary ext4 0% 20%
sudo parted /dev/md2 mkpart primary ext4 20% 40%
sudo parted /dev/md2 mkpart primary ext4 40% 60%
sudo parted /dev/md2 mkpart primary ext4 60% 80%
sudo parted /dev/md2 mkpart primary ext4 80% 100%

for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md2p$i; done

sudo mkdir -p /raid/md2/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md2p$i /raid/md2/part$i; done

echo "/dev/md2p1 /raid/md2/part1 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p2 /raid/md2/part2 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p3 /raid/md2/part3 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p4 /raid/md2/part4 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p5 /raid/md2/part5 ext4 defaults 0 1" | sudo tee -a /etc/fstab

sudo mdadm -D /dev/md2
cd /raid/
ls
			
sudo df -h
sudo lsblk
			
sudo cat /etc/fstab

cd /raid/md2/part1
wget -q https://git.kernel.org/torvalds/t/linux-5.0-rc8.tar.gz

echo
ls
echo

echo
echo Reboot now.
echo

sudo reboot now