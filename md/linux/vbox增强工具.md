# vbox增强工具安装

-------------

```bash
yum update kernel -y

yum install kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc gcc-c++ make -y

yum install xorg-x11-server-Xorg -y

yum install bzip2 -y


mount /dev/cdrom /mnt
sh /mnt/VBoxLinuxAdditions.run

rpm -qa|grep -e  kernel-devel  -e  kernel-headers

/sbin/rcvboxadd quicksetup all
```
