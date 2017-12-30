#!/usr/bin/env bash
#
# Arguments:
#   - username
#   - password
#   - database name

set -e

cd /var

if ! (sudo -u postgres psql -c "SELECT 1 FROM pg_roles WHERE rolname='$1'" | grep -q 1); then
  echo "Creating database user $1"
  sudo -u postgres psql -c "CREATE USER $1 WITH PASSWORD '$2' SUPERUSER;" || { echo 'Failed creating postgres user' ; exit 1; }
fi

if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw $3; then
  echo "Creating database $3 "
  sudo -u postgres psql -c "CREATE DATABASE $3 OWNER $1;"
  sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $3 TO $1;"
fi