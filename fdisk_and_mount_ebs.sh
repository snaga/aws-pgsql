#!/bin/sh

# fdisk_and_mount_ebs.sh
#
# Copyright(c) 2013 Uptime Technologies, LLC. All rights reserved.

EXISTING=0

function get_ebs1_device_name()
{
  DEVICE=`curl --silent http://169.254.169.254/latest/meta-data/block-device-mapping/ebs1`
}

function check_existing_partition()
{
  dev=$1
  part=$2

  count=`sfdisk -l /dev/${dev} | grep ${dev}${part} | grep -c Linux`

  if [ $count -gt 0 ]; then
    echo "${dev}${part} already exists."
    EXISTING=1
  fi
}

function create_partition()
{
  dev=$1

  sfdisk /dev/${dev} <<EOF
,,83
;
EOF
}

function format_partition()
{
  dev=$1
  part=$2

  sleep 3

  echo "mke2fs -j /dev/${dev}${part}"
  mke2fs -j /dev/${dev}${part}
}

function mount_partition()
{
  part=$1
  point=$2

  mkdir -p $point

  echo "mount /dev/$part $point"
  mount /dev/$part $point
}

# --------------------------------------
# Start from here
# --------------------------------------

get_ebs1_device_name

check_existing_partition $DEVICE 1

if [ $EXISTING -eq 0 ]; then
  create_partition $DEVICE
  format_partition $DEVICE 1
fi

mount_partition ${DEVICE}1 /data

echo "DEVICE=$DEVICE"
echo "EXISTING=$EXISTING"

