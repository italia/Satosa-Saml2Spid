# Docker Compose

## Table of Contents

1. [What do you need?](#what-do-you-need?)
2. [Run the composition](#run-the-composition)
3. [Stop the composition](#stop-the-composition)
4. [Remove/Delete volumes](#remove/delete-volumes)
5. [Demo data](#demo-data)
6. [Env file](#env-file)
7. [docker-compose.yml](#docker-compose.yml)

## Requirements

In order to execute the run script you need:

* jq
* docker-compose

Installation example in Ubuntu:

```
sudo apt install jq docker-compose
```

For docker-compose you can also [see here](https://docs.docker.com/compose/install/other/).

## Run the composition

Copy the folder `example` to `docker-example` and do your configuration.

### Start the Compose

Execute the run script for the first time:

```
./run-docker-compose.sh
```

The following docker volumes are created, if they doesn't exist yet:

* satosa-saml2spid_nginx_certs
* satosa-saml2spid_mongodata 

The *satosa-saml2spid_nginx_certs* is populated with data from [nginx/certs/](nginx/certs)`,
*satosa-saml2spid_mongodata* is populated by MongoDB container with its storage.

After having executed the docker compose you can see the logs of the running containers:
```
docker-compose -f docker-compose.yml logs -f
```

After the first run, you can start the docker compose with the run script or by this commands:

```
docker-compose pull; docker-compose down -v; docker-compose up -d; docker-compose logs -f
```

### Where is your data?

Command:

```
docker volume ls
```

Output:

```
DRIVER    VOLUME NAME
local     satosa-saml2spid_mongodata
local     satosa-saml2spid_nginx_certs
```

In RedHat and Ubuntu based OS the Docker volumes directory is at:

```
# ls -1 /var/lib/docker/volumes/
satosa-saml2spid_mongodata
satosa-saml2spid_nginx_certs
```

## Stop the composition

```
./stop-docker-compose.sh
```

This script stops all containers of the composition and detaches the volumes, but keeps the data on the persistent volumes.

## Remove/Delete volumes

If you want to start from scratch, or just clear all persistent data, just run the following script:

```
./rm-persistent-volumes.sh
```

First, the containers of the composition are stopped and the volumes are detached.

Then you are asked if you want to delete the volumes and if you answer yes, you have to confirm volume by volume.

## Demo data

Demo data for a test client are inserted into the DB during the first run of the composition.

See [mongo readme](../README.mongo.md) to have some example of demo data.

## Env file

```
# cat .env
MONGO_DBUSER=satosa
MONGO_DBPASSWORD=thatpassword
HOSTNAME=localhost
```

See [mongo readme](../README.mongo.md) for explanation of environment variables of MongoDB.
