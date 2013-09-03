#!/bin/sh

# Copyright(c) 2013 Uptime Technologies, LLC. All rights reserved.

MAJOR_VERSION=9.3

PGHOME=/usr/pgsql-${MAJOR_VERSION}
PGDATA=/var/lib/pgsql/${MAJOR_VERSION}/data
PATH=${PGHOME}/bin:$PATH

export PGHOME PGDATA PATH

if [ -f $PGDATA/PG_VERSION ]; then
  exit;
fi

function create_sysconfig()
{
  curl http://169.254.169.254/2008-02-01/user-data > /tmp/userdata.sh
  . /tmp/userdata.sh

  echo export PGPORT=$PGPORT > /etc/sysconfig/pgsql/postgresql-${MAJOR_VERSION}
  echo export PGDATA=$PGDATA >> /etc/sysconfig/pgsql/postgresql-${MAJOR_VERSION}
  echo $PGADMINPASSWORD > /tmp/passwd
}

function do_initdb()
{
  su -c "initdb --no-locale --encoding=UTF-8 -D $PGDATA \
     -U $PGADMINUSER --pwfile=/tmp/passwd" postgres
}

function create_pg_hba_conf()
{
  if [ -f pg_hba.conf ]; then
    cp -v pg_hba.conf $PGDATA
    chown postgres:postgres $PGDATA/pg_hba.conf
  else
    echo "ERROR: pg_hba.conf not found."
  fi;
}

function create_postgresql_conf()
{
  if [ -f pg_hba.conf ]; then
    cp postgresql.conf $PGDATA
    chown postgres:postgres $PGDATA/postgresql.conf
  else
    echo "ERROR: postgresql.conf not found."
  fi;
}

function do_cleanup()
{
  rm -f /tmp/passwd /tmp/userdata.sh
}

function do_start()
{
  chkconfig postgresql-${MAJOR_VERSION} on
  service postgresql-${MAJOR_VERSION} start
}

create_sysconfig
do_initdb
create_pg_hba_conf
create_postgresql_conf

do_cleanup
do_start

if [ x"$_DEBUG" = "x" ]; then
  chkconfig sshd stop
  service sshd stop
fi;

