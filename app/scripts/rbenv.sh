#!/usr/bin/env bash

set -e

echo 'gem: --no-document' > ~/.gemrc

if [ ! -d /home/deploy/.rbenv ]; then
  git clone https://github.com/rbenv/rbenv.git /home/deploy/.rbenv
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/deploy/.bashrc
  echo 'eval "$(rbenv init -)"' >> /home/deploy/.bashrc
fi

if [ ! -d /home/deploy/.rbenv/plugins/ruby-build ]; then
  git clone https://github.com/rbenv/ruby-build.git /home/deploy/.rbenv/plugins/ruby-build
  echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/deploy/.bashrc
fi

IFS=, read -ra rubies <<< "$1"
for ruby in "${rubies[@]}"
do
  # call your procedure/other scripts here below
  echo "Installing Ruby $ruby..."
  if [ ! -d /home/deploy/.rbenv/versions/$ruby ]; then
    mkdir -p /home/deploy/.rbenv/versions/
    wget -qO- https://s3.amazonaws.com/gorails-formation/ruby/$ruby.tar.gz | tar xz -C /home/deploy/.rbenv/versions
    /home/deploy/.rbenv/versions/$ruby/bin/gem install bundler
  fi
done

if [ ! -d /home/deploy/.rbenv/plugins/rbenv-vars ]; then
  git clone https://github.com/rbenv/rbenv-vars.git /home/deploy/.rbenv/plugins/rbenv-vars
fi

PATH="/home/deploy/.rbenv/shims:/home/deploy/.rbenv/plugins/ruby-build/bin:/home/deploy/.rbenv/bin:$PATH"
rbenv global ${rubies[-1]}
rbenv rehash