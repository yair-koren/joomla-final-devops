#!/bin/bash

set -euo pipefail

create_network() {
  if ! docker network inspect joomla-net >/dev/null 2>&1; then
    docker network create joomla-net
    printf "✅ Created Docker network: joomla-net\n"
  else
    printf "ℹ️ Network already exists: joomla-net\n"
  fi
}

start_mysql_container() {
  docker run -d \
    --name mysql-container \
    --network joomla-net \
    -e MYSQL_ROOT_PASSWORD=my-secret-pw \
    -p 3306:3306 \
    mysql
  printf "✅ Started mysql-container\n"
}

start_joomla_container() {
  docker run -d \
    --name joomla-container \
    --network joomla-net \
    -p 8080:80 \
    -e JOOMLA_DB_HOST=mysql-container \
    -e JOOMLA_DB_USER=root \
    -e JOOMLA_DB_PASSWORD=my-secret-pw \
    joomla
  printf "✅ Started joomla-container\n"
}

main() {
  create_network
  start_mysql_container
  start_joomla_container
}

main

