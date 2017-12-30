#!/usr/bin/env bash
#
# Arguments:
#   - project name
#   - repo url

set -e

KEY_FILE=/home/deploy/.ssh/$1_rsa
DIR=/home/deploy/$1
REPO_URL=$2

echo "# Cloning $REPO_URL to $DIR/repo"

mkdir -p $DIR/shared $DIR/releases $DIR/shared/config
mkdir -p $DIR/shared/log $DIR/shared/tmp/pids $DIR/shared/tmp/cache $DIR/shared/tmp/sockets $DIR/shared/vendor/bundle $DIR/shared/public/system $DIR/shared/public/uploads $DIR/shared/public/assets

if [ ! -d $DIR/repo ]; then
  ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts
  ssh-keyscan -H task.intellecta.co >> ~/.ssh/known_hosts
  git clone --mirror $REPO_URL $DIR/repo || { echo 'git clone failed' ; exit 1; }
fi