#!/bin/bash -ex

export DEBIAN_FRONTEND=noninteractive 
# locale-gen en_US.UTF-8
# update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX LC_ALL=en_US.utf8

cat<<EOF>/etc/default/locale
LANG="en_US"
LANGUAGE="en_US:"
EOF
source /etc/default/locale

mkdir -p /etc/apt/preferences.d /var/lib/dpkg/updates/ /etc/initramfs-tools/scripts /home
#touch /etc/mtab

cat<<EOF>/etc/kernel-img.conf
do_symlinks = Yes
do_bootloader = No
EOF

if test -f /etc/kernel/postinst.d/zz-update-grub; then 
  mv /etc/kernel/postinst.d/zz-update-grub /root/zz-update-grub.disabled
fi

UBUNTU_RELEASE=`grep DISTRIB_CODENAME $imagedir/etc/lsb-release |cut -f2 -d=`
#echo "deb http://127.0.0.1:3142/ubuntu $UBUNTU_RELEASE main restricted universe multiverse" > $imagedir/etc/apt/sources.list

echo "deb http://localhost:3142/ubuntu $UBUNTU_RELEASE main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://localhost:3142/ubuntu $UBUNTU_RELEASE-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://localhost:3142/ubuntu $UBUNTU_RELEASE-security main restricted universe multiverse" >> /etc/apt/sources.list


apt-get update
#apt-get install localepurge
#apt-get upgrade -y -u # broken by nfs.. hangs on statd restart(natty)


apt-get install -y linux-image-server

groupadd admin
# set root password
usermod -p '$6$WhXI0qYoffO$6kzSGD0bKqPdAe3jmtrzQ3NIiY1GN2paSDNjNElPTLa1CME4uu/fw1CO468OLxIryxO9yCVxmqUWPnNuw9hne1'  root

# disable root logins via ssh 
echo 'PermitRootLogin no' >> /etc/ssh/sshd_config

# change ssh port to 3223
echo 'Port 3223' >> /etc/ssh/sshd_config

if [ -d /root/megadeb ]; then
  dpkg -i /root/megadeb/*.deb
fi

# add a cloudscaling user
useradd cloudscaling --gid admin --create-home --shell /bin/bash
usermod -p '$6$YNrck/rFJsJBfQOv$OiBrnaRA/WOSJl7.UQo/uDbH0s8VC.jmVwolKTbWyA4ibefXrAg5mkRo6q96SJrH7ccjhKl3jFDgUzNu5a/ng1' cloudscaling
mkdir -p /home/cloudscaling/.ssh
cat<<EOF>/home/cloudscaling/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+Xv/kdQrTQmQEw65gT7EWsJLiC5CtZRWu/4B5vt/2oRSqFlvFaeXj+/OiXWlRsziqvaz4OIxm7LolArD/CYV2d3MjK7nl4cv0yVTgeAEkeYZD1aLnrV76MNeL6relF8AJce0lBueX1ZHb0yfB7yd1teAF6+oz93Ph0Gd7/kqTfp9hVWhaVh50fa68A+S7nieCEKSkjF3UBuvZXIPZFK1jxH1IGSDLwsUK3owLv3M29SabMVq23mXCTIbTQUykuR5W4NwN+lTSEQCQ6Mty6GAUqxq4N/AR65/ToWdv4KTIyM5AEXOH360htXG5M7yAI6cHJG+BQtMU8I0NoIRDf1/B
EOF
chown -R cloudscaling:admin /home/cloudscaling



echo '127.0.0.1 ubuntu.local ubuntu localhost' > /etc/hosts
echo 'ubuntu' > /etc/hostname
#hostname ubuntu

mv /sbin/initctl /sbin/initctl.bak
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

export DEBIAN_FRONTEND=noninteractive

# No opscode repository for precise yet. Using ubuntu version of chef for precise.
if [ "$UBUNTU_RELEASE" = "natty" ]; then
  echo "deb http://apt.opscode.com $UBUNTU_RELEASE-0.10 main" > /etc/apt/sources.list.d/opscode.list
  wget http://apt.opscode.com/packages@opscode.com.gpg.key -O - | apt-key add -
  echo "chef  chef/chef_server_url    string"  > /tmp/chef.seed
  debconf-set-selections /tmp/chef.seed
  apt-get install -y chef
  update-rc.d chef-client disable
  service chef-client stop
else
  apt-get install -y ruby1.9.3 build-essential
  HOME=/tmp
  gem install chef --no-user-install --no-rdoc --no-ri --version 0.10.8
  ln -s /usr/local/bin/chef-solo /usr/bin/chef-solo
fi
wget http://apt.cloudscaling.com/apt@cloudscaling.com.gpg.key -O - | apt-key add -
mkdir -p /etc/chef

my_chef=`which chef-solo`
## add substratum user
useradd substratum -m --shell /bin/bash 
mkdir -p /home/substratum/.ssh
cat<<EOF>/home/substratum/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCknZNriCo1jxCU8eQaoNGKfu4G7yV3VrDpp2CM1Wfq2Br0cj4sd+2euI6nKjRkhvwxqm1eVyGGxJu2+V48LS7wh+HcEnB2moJoVQmrbq0GzOavSWdfBSDYeF10jlY7MD2NCrtvQbe2AKcEguZpYfu9ZD/9Vwt1CKn1sDf73HVSukg7NvM1tXDsM9DKEDi8UDI3yL1JmBkYi+NsTfZhmO1B8T1njPOTLFkC2mcqQAH4ou29YAo+52RHms9MYq+QorS23cWg8+INK936z1UgvokHAJ6tD6P33UAqzF3zmfLvmLvunSH8xkRl6VeFt8SFo0lJ6diAiXIzONsXnKn8icLR
EOF
chown -R substratum:substratum /home/substratum
cat<<EOF>/etc/sudoers.d/substratum
substratum  ALL=NOPASSWD: ${my_chef}
EOF
chmod 0400 /etc/sudoers.d/substratum 

apt-get install -y  ipmitool dhcpcd

mv /sbin/initctl.bak /sbin/initctl
mv /root/zz-update-grub.disabled /etc/kernel/postinst.d/zz-update-grub 

cat<<EOF>/etc/kernel-img.conf
do_symlinks = Yes
EOF


echo "deb http://mirrors.kernel.org/ubuntu $UBUNTU_RELEASE main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://mirrors.kernel.org/ubuntu $UBUNTU_RELEASE-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.kernel.org/ubuntu $UBUNTU_RELEASE-security main restricted universe multiverse" >> /etc/apt/sources.list
apt-get update 