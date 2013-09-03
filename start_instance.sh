#!/bin/sh

# Copyright(c) 2013 Uptime Technologies, LLC. All rights reserved.

AWS_ACCESS_KEY=XXXXX
AWS_SECRET_KEY=YYYY
KEYPAIR=UUUUUU
HOSTNAME=COM.COM
SSH_SECRET_KEY=/path/to/pemfile

PGPORT=$1
PGUSER=$2
PGPASS=$3

DEBUG=0

if [ -z "$3" ]; then
  echo "Usage: $0 <PGPORT> <PGUSER> <PGPASS>"
  exit;
fi;

function create_userdata()
{
    cat > userdata.txt<<EOF
export PGPORT=$PGPORT
export PGADMINUSER=$PGUSER
export PGADMINPASSWORD=$PGPASS
EOF

    if [ $DEBUG -eq 1 ]; then
	echo "export _DEBUG=1" >> userdata.txt
    fi;
}

function get_instance_id()
{
  INSTANCE_ID=`grep INSTANCE /tmp/ec2-run-instances.log | awk '{ print $2 }'`
  echo "Instance ID: $INSTANCE_ID";
}

function get_public_dns_name()
{
  PUBLIC_DNS_NAME=`grep INSTANCE /tmp/ec2-describe-instances.log | awk '{ print $4 }'`
  echo "Public DNS Name: $PUBLIC_DNS_NAME";
}

function launch_instance()
{
  # http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-RunInstances.html

  ec2-run-instances -O $AWS_ACCESS_KEY \
                    -W $AWS_SECRET_KEY \
                    --region ap-northeast-1 \
                    -k $KEYPAIR \
                    -g test-pgsql \
                    -f userdata.txt \
                    --instance-type t1.micro \
                    -b /dev/sdb=:20 \
                    ami-39b23d38 \
  > /tmp/ec2-run-instances.log

  echo "sleeping 60 seconds..."
  sleep 60
}

function create_tag()
{
  ec2-create-tags -O $AWS_ACCESS_KEY \
                  -W $AWS_SECRET_KEY \
                  --region ap-northeast-1 \
                  $INSTANCE_ID \
                  --tag "Name=$HOSTNAME" \
  | tee /tmp/ec2-create-tags.log
}

function describe_instance()
{
  ec2-describe-instances -O $AWS_ACCESS_KEY \
                         -W $AWS_SECRET_KEY \
                         --region ap-northeast-1 \
                         $INSTANCE_ID \
  | tee /tmp/ec2-describe-instances.log
}

function copy_files()
{
  scp -i $SSH_SECRET_KEY \
    setup_pgsql.sh destroy_pgsql.sh \
    firstboot.sh \
    9.3/* \
    ec2-user@$PUBLIC_DNS_NAME:
}

function run_firstboot()
{
  ssh -i $SSH_SECRET_KEY \
    ec2-user@$PUBLIC_DNS_NAME "sudo sh firstboot.sh"
}

#create_userdata

#launch_instance
get_instance_id
#create_tag

describe_instance

get_public_dns_name

copy_files

run_firstboot

