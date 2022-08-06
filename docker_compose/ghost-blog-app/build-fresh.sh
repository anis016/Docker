#!/usr/bin/env bash
docker-compose down
docker volume rm --force ghost-blog-app_ghost-volume
docker volume rm --force ghost-blog-app_mysql-volume
docker network rm ghost-blog-app_ghost_network
docker network rm ghost-blog-app_mysql_network
docker-compose up -d
