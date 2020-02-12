# otus_lesson_2_mdadm
mdadm + raid 10 + raid 1 boot


Ставим нужные пакеты для работы
~~~~
sudo yum install -y mc mdadm smartmontools hdparm gdisk lvm2 device-mapper tree wget nano
~~~~

Затираем супеблоки на дисках sdc-sdg
~~~~
sudo mdadm --zero-superblock --force /dev/sd{c,d,e,f,g}
~~~~

Создаем raid10 + резервный диск
~~~~
sudo mdadm --create --verbose /dev/md2 -l 10 -n 4 /dev/sd{c,d,e,f}
sudo mdadm /dev/md2 --add /dev/sdg
sudo mdadm -D /dev/md2
~~~~

Сохраним нашу информацию о конфигурации рейда в конфигурационный файл
~~~~
sudo mkdir -p /etc/mdadm
echo "DEVICE partitions" | sudo tee -a /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf

echo "DEVICE partitions" | sudo tee -a /etc/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm.conf
~~~~

Создади gpt разметку на нашем рейде md2
И разобьем его на 5 разделов
~~~~
sudo parted -s /dev/md2 mklabel gpt

sudo parted /dev/md2 mkpart primary ext4 0% 20%
sudo parted /dev/md2 mkpart primary ext4 20% 40%
sudo parted /dev/md2 mkpart primary ext4 40% 60%
sudo parted /dev/md2 mkpart primary ext4 60% 80%
sudo parted /dev/md2 mkpart primary ext4 80% 100%
~~~~

Отформатируем разделы в ext4
~~~~
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md2p$i; done
~~~~

Создадим папки для наших разделов и смотрируем их
~~~~
sudo mkdir -p /raid/md2/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md2p$i /raid/md2/part$i; done
~~~~

Пропишем наши разделы в fstab для автоматического монтирования при следующей загрузке системы
~~~~
echo "/dev/md2p1 /raid/md2/part1 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p2 /raid/md2/part2 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p3 /raid/md2/part3 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p4 /raid/md2/part4 ext4 defaults 0 1" | sudo tee -a /etc/fstab
echo "/dev/md2p5 /raid/md2/part5 ext4 defaults 0 1" | sudo tee -a /etc/fstab
~~~~

Проверим наш рейд
~~~~
sudo mdadm -D /dev/md2
cd /raid/
ls
			
sudo df -h
sudo lsblk
			
sudo cat /etc/fstab
~~~~

Перейдем в первый раздел и скачаем файл для проверки работы нашего рейда
~~~~
cd /raid/md2/part1
wget -q https://git.kernel.org/torvalds/t/linux-5.0-rc8.tar.gz
~~~~
