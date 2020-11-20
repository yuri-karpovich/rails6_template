#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

COMPOSE_PROJECT_NAME=${PROJECT_NAME}_${RAILS_ENV} docker-compose -f $1 down