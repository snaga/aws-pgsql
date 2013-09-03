#!/bin/sh

# Cpyright(c) 2013 Uptime Technologies, LLC. All rights reserved.

MAJOR_VERSION=9.3

PGHOME=/usr/pgsql-${MAJOR_VERSION}
PGDATA=/var/lib/pgsql/${MAJOR_VERSION}/data
PATH=${PGHOME}/bin:$PATH

export PGHOME PGDATA PATH

function do_stop()
{
  service postgresql-${MAJOR_VERSION} stop
  chkconfig postgresql-${MAJOR_VERSION} off
}

do_stop
rm -rf $PGDATA
rm -rf /etc/sysconfig/pgsql/postgresql-${MAJOR_VERSION}
