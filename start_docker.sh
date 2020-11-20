#!/usr/bin/env bash

set -e -o pipefail
set -x

#source "${BASH_SOURCE%/*}/act.conf.sh"

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

if [ "${DROP_DATABASE_FIRST}" == 'true' ]
then
  echo Dropping database
  PROJECT_NAME=${PROJECT_NAME}_${RAILS_ENV} docker-compose rm -f -s -v
fi

mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}
mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}/mysql/data
mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}/clickhouse/logs
mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}/rails/tmp
mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}/rails/log
mkdir -p ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}/rails/storage
uid=$(id -u)
gid=$(id -g)
chown -R  $uid:$gid ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}
chmod  -R 755 ${DATA_DIR}/${PROJECT_NAME}_${RAILS_ENV}

COMPOSE_PROJECT_NAME=${PROJECT_NAME}_${RAILS_ENV} uid=$uid gid=$gid docker-compose -f $1 up -d --build --force-recreate