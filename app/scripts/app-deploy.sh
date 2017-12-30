#!/usr/bin/env bash
#
# Arguments:
#   - app name
#   - branch

set -e

PATH=/home/deploy/.rbenv/bin:$PATH
DIR=/home/deploy/$1
RELEASE=$(date +"%Y%m%d%H%M%S")
BRANCH=$2
RELEASE_DIR=$DIR/releases/$RELEASE

cd $DIR/repo
git remote update --prune
mkdir -p $RELEASE_DIR
git archive $BRANCH | /usr/bin/env tar -x -f - -C $RELEASE_DIR

REVISION=`git rev-list --max-count=1 $BRANCH`
echo "$REVISION" >> $DIR/REVISION

mkdir -p $RELEASE_DIR/config $RELEASE_DIR/tmp $RELEASE_DIR/vendor $RELEASE_DIR/public
rm -rf $RELEASE_DIR/log

ln -s $DIR/shared/log $RELEASE_DIR/log
ln -s $DIR/shared/tmp/pids $RELEASE_DIR/tmp/pids
ln -s $DIR/shared/tmp/cache $RELEASE_DIR/tmp/cache
ln -s $DIR/shared/tmp/sockets $RELEASE_DIR/tmp/sockets
ln -s $DIR/shared/vendor/bundle $RELEASE_DIR/vendor/bundle
ln -s $DIR/shared/public/system $RELEASE_DIR/public/system
ln -s $DIR/shared/public/uploads $RELEASE_DIR/public/uploads
ln -s $DIR/shared/public/assets $RELEASE_DIR/public/assets

cd $RELEASE_DIR

# Comment this out if you'd like to use the database.yml in your repo
echo 'Overwriting config/database.yml...'
echo "production:
  adapter: postgresql
  url: <% ENV['DATABASE_URL'] %>
  encoding: utf8
" > config/database.yml

echo 'Overwriting config/cable.yml...'
echo "production:
  adapter: redis
  url: <% ENV['REDIS_URL'] %>
" > config/cable.yml

echo 'Installing gems...'
rbenv exec bundle install --path $DIR/shared/bundle --without development test --deployment

echo 'Precompiling assets...'
rbenv exec bundle exec rake assets:precompile

echo 'Migrating database...'
rbenv exec bundle exec rake db:migrate

# Update cron jobs if needed; whenever must be in your Gemfile
if [ -f config/schedule.rb ]
then
  echo "Updating crontab..."
  rbenv exec bundle exec whenever -i timesheets --update-crontab
fi

echo 'Creating current release and restarting passenger...'
ln -s $RELEASE_DIR $DIR/releases/current
mv $DIR/releases/current $DIR

passenger-config restart-app $DIR --ignore-app-not-running || true



echo "Branch $BRANCH (at $REVISION) deployed as release $RELEASE by $USER" | tee -a $DIR/revisions.log
echo 'Deploy completed successfully!'