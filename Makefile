.SILENT:
.PHONY: help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Defaults
ID_RSA ?= ~/.ssh/id_rsa
DOCKER_NETWORK ?= meup
DOCKER_LOCAL_HOSTNAME ?= mautic.local.1001pharmacies.com
DIR := ${CURDIR}

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

#############
# Bootstrap #
#############

## Bootstrap application
bootstrap: bootstrap-git bootstrap-docker

bootstrap-git:
	if ! git config remote.upstream.url > /dev/null ; \
		then git remote add upstream git@github.com:mautic/mautic.git; \
	fi

bootstrap-docker: docker-shared docker-deploy

## Import database (usage: make import-database DUMP="dump.sql")
import-database:
ifdef DUMP
	docker-compose exec mautic sh -c 'mysql -h meup-mysql -u root -proot meup2 < $(DUMP)'
else
	echo 'usage: make import-database DUMP="dump.sql"'
endif

##########
# Docker #
##########

## Launch shared dockers
docker-shared: docker-network docker-consul docker-registrator docker-fabio docker-ssh-agent docker-mysql

## Create a docker network
docker-network:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	 || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

## Generate a SSL certificate for $(DOCKER_LOCAL_HOSTNAME)
docker-openssl: /etc/ssl/certs/$(DOCKER_LOCAL_HOSTNAME).crt /etc/ssl/certs/$(DOCKER_LOCAL_HOSTNAME).key
# letsencrypt wont work yet as local.1001pharmacies.com is not a valid DNS A record
# docker run -v /etc/letsencrypt -v /var/lib/letsencrypt certbot/certbot:latest certonly --standalone -d local.1001pharmacies.com --text --agree-tos --email technique@1001pharmacies.com --server https://acme-v01.api.letsencrypt.org/directory --rsa-key-size 4096 --verbose --renew-by-default --standalone-supported-challenges http-01

/etc/ssl/certs/$(DOCKER_LOCAL_HOSTNAME).crt:
	docker run --rm -e COMMON_NAME=$(DOCKER_LOCAL_HOSTNAME) -e KEY_NAME=$(DOCKER_LOCAL_HOSTNAME) -v /etc/ssl/certs:/certs centurylink/openssl

/etc/ssl/certs/$(DOCKER_LOCAL_HOSTNAME).key:
	docker run --rm -e COMMON_NAME=$(DOCKER_LOCAL_HOSTNAME) -e KEY_NAME=$(DOCKER_LOCAL_HOSTNAME) -v /etc/ssl/certs:/certs centurylink/openssl

## Launch consul service registry
docker-consul: docker-network
	[ -z "$(shell docker ps -q --filter name=meup-consul --filter status=dead 2>/dev/null)" ] \
	  || docker rm meup-consul >/dev/null
	[ -z "$(shell docker ps -q --filter name=meup-consul --filter status=created --filter status=exited 2>/dev/null)" ] \
	  || { echo -n "Starting meup-consul ... " && docker start meup-consul >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	[ -z "$(shell docker ps -q --filter name=meup-consul --filter status=paused 2>/dev/null)" ] \
	  || docker unpause meup-consul >/dev/null
	[ -n "$(shell docker ps -q --filter name=meup-consul --all 2>/dev/null)" ] \
	  || { echo -n "Creating meup-consul ... " && docker run -d --name=meup-consul --network=$(DOCKER_NETWORK) -p 8500:8500 consul:latest >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

## Launch registrator service registry bridge for docker
docker-registrator: docker-network docker-consul
	[ -z "$(shell docker ps -q --filter name=meup-registrator --filter status=dead 2>/dev/null)" ] \
	  || docker rm meup-registrator >/dev/null
	[ -z "$(shell docker ps -q --filter name=meup-registrator --filter status=created --filter status=exited 2>/dev/null)" ] \
	  || { echo -n "Starting meup-registrator ... " && docker start meup-registrator >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	[ -z "$(shell docker ps -q --filter name=meup-registrator --filter status=paused 2>/dev/null)" ] \
	  || docker unpause meup-registrator >/dev/null
	[ -n "$(shell docker ps -q --filter name=meup-registrator --all 2>/dev/null)" ] \
	  || { echo -n "Creating meup-registrator ... " && docker run -d --name=meup-registrator --network=$(DOCKER_NETWORK) --link meup-consul:consul --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator -internal consul://consul:8500 >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

## Launch a load balancer to distribute incoming http(s) traffic
docker-fabio: docker-network docker-openssl docker-registrator
	[ -z "$(shell docker ps -q --filter name=meup-fabio --filter status=dead 2>/dev/null)" ] \
	  || docker rm meup-fabio >/dev/null
	[ -z "$(shell docker ps -q --filter name=meup-fabio --filter status=created --filter status=exited 2>/dev/null)" ] \
	  || { echo -n "Starting meup-fabio ... " && docker start meup-fabio >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	[ -z "$(shell docker ps -q --filter name=meup-fabio --filter status=paused 2>/dev/null)" ] \
	  || docker unpause meup-fabio >/dev/null
	[ -n "$(shell docker ps -q --filter name=meup-fabio --all 2>/dev/null)" ] \
	  || { echo -n "Creating meup-fabio ... " && docker run -d --name=meup-fabio --network=$(DOCKER_NETWORK) --link meup-consul:consul -v /etc/ssl/certs:/certs -p 80:80 -p 443:443 -p 9998:9998 fabiolb/fabio:latest /fabio -registry.backend "consul" -registry.consul.addr "consul:8500" -proxy.addr ":80,:443;cs=local" -proxy.cs "cs=local;type=file;cert=/certs/$(DOCKER_LOCAL_HOSTNAME).crt;key=/certs/$(DOCKER_LOCAL_HOSTNAME).key" >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

## Launch a docker running ssh-agent with your personal identity
docker-ssh-agent: docker-network
	[ -z "$(shell docker ps -q --filter name=ssh-agent --filter status=dead 2>/dev/null)" ] \
	 || docker rm ssh-agent >/dev/null
	[ -z "$(shell docker ps -q --filter name=ssh-agent --filter status=created --filter status=exited 2>/dev/null)" ] \
	 || { echo -n "Starting ssh-agent ... " && docker start ssh-agent >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	[ -z "$(shell docker ps -q --filter name=ssh-agent --filter status=paused 2>/dev/null)" ] \
	 || docker unpause ssh-agent >/dev/null
	[ -n "$(shell docker ps -q --filter name=ssh-agent --all 2>/dev/null)" ] \
	 || { echo -n "Creating ssh-agent ... " && docker run -d --name=ssh-agent --network=$(DOCKER_NETWORK) 1001pharmadev/ssh-agent:latest >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	docker run --rm --volumes-from=ssh-agent 1001pharmadev/ssh-agent:latest ssh-add -l >/dev/null \
	 || docker run --rm --volumes-from=ssh-agent -v $(ID_RSA):/root/.ssh/id_rsa -it 1001pharmadev/ssh-agent:latest ssh-add /root/.ssh/id_rsa

docker-mysql: docker-network
	[ -z "$(shell docker ps -q --filter name=meup-mysql --filter status=dead 2>/dev/null)" ] \
	 || docker rm meup-mysql >/dev/null
	[ -z "$(shell docker ps -q --filter name=meup-mysql --filter status=created --filter status=exited 2>/dev/null)" ] \
	 || { echo -n "Starting meup-mysql ... " && docker start meup-mysql >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	[ -z "$(shell docker ps -q --filter name=meup-mysql --filter status=paused 2>/dev/null)" ] \
	 || docker unpause meup-mysql >/dev/null
	[ -n "$(shell docker ps -q --filter name=meup-mysql --all 2>/dev/null)" ] \
	 || { echo -n "Creating meup-mysql ... " && docker run -d --name=meup-mysql --network=$(DOCKER_NETWORK) -e MYSQL_ROOT_PASSWORD=root -e MYSQL_USER=meup2 -e MYSQL_PASSWORD=meup2 -e MYSQL_DATABASE=meup2 -p 3307:3306 mariadb:10 >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

## Deploy docker
docker-deploy: docker-shared
	if [ ! -f docker-compose.yml ]; \
	then \
	    cp docker-compose.yml.dist docker-compose.yml; \
	fi;
	docker-compose up -d

## Connect to docker
## Note: /bin/zsh is too slow on some machines
## Therefore we use /bin/bash as default shell
## Feel free to switch once logged in
docker-connect:
	docker-compose exec mautic /bin/bash

## Upgrade docker
docker-upgrade: docker-shared
	docker-compose up -d --no-recreate

## Start docker
docker-start: docker-shared
	docker-compose start

## Stop docker
docker-stop:
	docker-compose stop

################
# Start & Stop #
################

## Start env
start: docker-start

## Stop env
stop: docker-stop

###########
# Install #
###########

## Install application
install: bootstrap install-deps fix

## Install dependencies
install-deps: install-composer mv-local-php create-db

## Install composer
install-composer: docker-ssh-agent
	docker run --rm -v $${PWD}:/app composer:latest install


## Rename local.php.dist -> local.php
mv-local-php:
	if [ ! -f app/config/local.php ]; \
	then \
	    cp app/config/local.php.dist app/config/local.php; \
	fi;

## Create db
create-db:
	docker exec meup-mysql sh -c "mysql -u root -proot mautic -e 'use mautic' >/dev/null 2>&1 || mysql -u root -proot mysql -e 'create database mautic character set utf8 collate utf8_unicode_ci;'"
	docker exec meup-mysql bash -c "mysql -u mautic -mautic mautic -e 'use mautic' >/dev/null 2>&1 || mysql -u root -proot mysql -e \"grant all privileges on mautic.* to 'mautic'@'%' identified by 'mautic'; flush privileges;\""
	docker-compose exec mautic sh -c "php app/console doctrine:schema:create"
	docker-compose exec mautic sh -c "php app/console doctrine:schema:update --dump-sql"
#	docker-compose exec mautic sh -c "php app/console doctrine:migrations:migrate"
#	docker-compose exec mautic sh -c "php app/console mautic:campaigns:rebuild"
#	docker-compose exec mautic sh -c "php app/console mautic:campaigns:trigger"
#	docker-compose exec mautic sh -c "php app/console mautic:segments:update"
	docker-compose exec mautic sh -c "php app/console doctrine:schema:update --force"
#	docker exec meup-mysql bash -c "mysql -u root -proot mautic -e 'INSERT INTO roles VALUES(1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, \"Administrator\", \"Full system access\", 1, \"N;\");'"
	docker-compose exec mautic sh -c "php app/console doctrine:fixtures:load"
#	docker exec meup-mysql bash -c "mysql -u root -proot mautic -e 'INSERT INTO users VALUES(3, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, \"admin\", \"\$$2y\$$13\$$iOTJ6LnA5p1VOjFCZN0i6eEBApFGEaoTkPmd1.76Qf.tv9ckUun8K\", \"admin\", \"1001pharmacies\", \"contact@1001pharmacies.com\", NULL, NULL, NULL, NULL, NULL, \"offline\", NULL, NULL);'"

## Fix variable folders

fix: fix-cache fix-permissions

fix-permissions:
	docker-compose exec mautic sh -c 'chmod -R 0777 app/cache'
	docker-compose exec mautic sh -c 'chmod -R 0777 app/logs'
	docker-compose exec mautic sh -c 'chown -R www-data:www-data translations'
	docker-compose exec mautic sh -c 'chmod -R 0777 translations'
	docker-compose exec mautic sh -c 'chmod 0777 app/config/local.php'
	docker-compose exec mautic sh -c 'chmod -R 0777 media/files'
	docker-compose exec mautic sh -c 'chmod -R 0777 media/images'

fix-cache:
	docker-compose exec mautic sh -c 'php app/console cache:clear'
