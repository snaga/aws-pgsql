#!/bin/sh

MAJOR_VERSION=9.3

yum update -y
echo "curl http://169.254.169.254/2008-02-01/user-data > /user-data.sh" >> /etc/rc.d/rc.local

function install_pgsql()
{
#rpm -ivh http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm
#yum install -y postgresql92 postgresql92-contrib postgresql92-devel postgresql92-libs postgresql92-plperl postgresql92-plpython postgresql92-server

    rpm -ivh http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm
    yum install -y postgresql93 postgresql93-contrib postgresql93-devel postgresql93-libs postgresql93-plperl postgresql93-plpython postgresql93-server

  mv /var/lib/pgsql/${MAJOR_VERSION} /data
  ln -s /data/${MAJOR_VERSION} /var/lib/pgsql/
}

function do_fdisk()
{
    fdisk /dev/sdb<<EOF
n
p
1


w
EOF

    mke2fs -j /dev/sdb1
}

function do_mount()
{
    mkdir -p /data
    echo "/dev/sdb1 /data ext4 defaults,noatime 0 0" >> /etc/fstab
    mount -a
}

do_fdisk
do_mount

install_pgsql
