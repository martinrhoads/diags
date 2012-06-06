#!/bin/bash -ex
# This script is meant to be run in a chroot to install debian packages for substratum-services.

. /etc/lsb-release 
cat<<EOF>/etc/apt/sources.list
deb http://localhost:3142/ubuntu $DISTRIB_CODENAME main restricted universe multiverse
deb http://localhost:3142/ubuntu $DISTRIB_CODENAME-security main restricted universe multiverse
EOF

mkdir -p /var/lib/dpkg/updates/

echo exit 0 > /etc/rc.local
apt-get update
apt-get install -y nginx git

set +e
if install_debs=`ls -1 /root/*.deb 2> /dev/null `; then 
  dpkg -i $install_debs
fi
set -e

apt-get -y -f install
mkdir -p /etc/substratum

# TODO: make this point at our public mirror for easy upgrades
# echo "deb http://ci-dev.cloudscaling.com/ precise main" > /etc/apt/sources.list.d/cloudscaling-ocs.list
# wget -q http://ci-dev.cloudscaling.com/release@cloudscaling.com.gpg.key -O- | apt-key add -
# apt-get update
