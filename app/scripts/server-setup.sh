#!/usr/bin/env bash

set -e

packages="git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev nodejs postgresql postgresql-contrib libpq-dev redis-server redis-tools redis-sentinel apt-transport-https ca-certificates ufw imagemagick nginx-extras passenger yarn"

echo 'Disabling password authentication for ssh.'
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
service sshd restart

# Install add-apt-repository command if it isn't available already
DEBIAN_FRONTEND=noninteractive apt-get -y -qq -o Dpkg::Use-Pty=0 install software-properties-common

echo 'Adding repositories for PostgreSQL, Redis, and Passenger.'

# Postgres
echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/postgres.list
(wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -)

# Redis
add-apt-repository ppa:chris-lea/redis-server

# Git
add-apt-repository ppa:git-core/ppa

# Passenger
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main' > /etc/apt/sources.list.d/passenger.list

# NodeJS
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo 'deb https://dl.yarnpkg.com/debian/ stable main' | sudo tee /etc/apt/sources.list.d/yarn.list

echo
echo 'Upgrading and installing all packages for running Rails.'
echo 'apt-get update'
DEBIAN_FRONTEND=noninteractive apt-get -y -qq -o Dpkg::Use-Pty=0 update

echo
echo 'Upgrading packages'
echo 'apt-get upgrade'
DEBIAN_FRONTEND=noninteractive apt-get -y -qq -o Dpkg::Use-Pty=0 upgrade

echo
echo 'Installing dependencies'
echo "apt-get upgrade $packages"
DEBIAN_FRONTEND=noninteractive apt-get -y -qq -o Dpkg::Use-Pty=0 install $packages

echo 'Setting up firewall rules to only allow ports 22, 80, and 443.'
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

echo 'Configuring and reloading NGINX for Passenger and Ruby support.'
sed -i '/user www-data/s/www-data/deploy/' /etc/nginx/nginx.conf
sed -i '/passenger.conf/s/# //' /etc/nginx/nginx.conf
echo "passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /home/deploy/.rbenv/shims/ruby;
passenger_pool_idle_time 0;" > /etc/nginx/passenger.conf

service nginx reload

echo
echo 'Done!'