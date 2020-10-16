# Linux 命令

--------

- 清空buff/cache

```bash
#查看
free 
cat /proc/sys/vm/drop_caches 
#表示清除pagecache。
echo 1 > /proc/sys/vm/drop_caches
#:表示清除回收slab分配器中的对象（包括目录项缓存和inode缓存）。slab分配器是内核中管理内存的一种机制，其中很多缓存数据实现都是用的pagecache。
echo 2 > /proc/sys/vm/drop_caches
#表示清除pagecache和slab分配器中的缓存对象。
echo 3 > /proc/sys/vm/drop_caches
```

- 将/home目录空间分配给/root

```bash
#备份/home目录
sudo tar cvf /root/home.tar /home;
#关闭使用/home目录的进程
sudo fuser -km /home;
#取消挂载
sudo umount /home;
#移除逻辑卷
sudo lvremove /dev/mapper/centos-home;
#扩大逻辑卷
sudo lvextend -L +400G /dev/mapper/centos-root;
#扩大文件系统
sudo xfs_growfs /dev/mapper/centos-root;
#重新创建/home卷
sudo lvcreate -L 40G -n/dev/mapper/centos-home;
#创建文件系统
sudo mkfs.xfs  /dev/mapper/centos-home;
#挂载/home
sudo mount /dev/mapper/centos-home;
#解压备份
sudo tar xvf /root/home.tar -C /;
#删除备份
sudo rm -rf /root/home.tar
```

- linux系统解决权限设置成777仍然无权限访问的问题

```bash
查看SELinux状态：
#如果SELinux status参数为enabled即为开启状态
/usr/sbin/sestatus -v

#也可以用这个命令检查
getenforce

#关闭SELinux

#临时关闭（不用重启机器）：
setenforce 0

#临时开启（不用重启机器）：
setenforce 1

#修改配置文件需要重启机器：

#修改/etc/selinux/config 文件
#将SELINUX=enforcing改为SELINUX=disabled
#reboot重启机器即可
```
