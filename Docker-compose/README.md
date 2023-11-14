# compose-Satosa-Saml2Spid

## Table of Contents

1. [What do you need?](#what-do-you-need?)
2. [Run the composition](#run-the-composition)
3. [Stop the composition](#stop-the-composition)
4. [Remove/Delete volumes](#remove/delete-volumes)
5. [Demo data](#demo-data)
6. [Env file](#env-file)
7. [docker-compose.yml](#docker-compose.yml)

## What do you need?

In order to execute the run script you need:

* jq
* docker-compose

Installation example in Ubuntu:

```
sudo apt install jq docker-compose
```

For docker-compose you can also [see here](https://docs.docker.com/compose/install/other/).

## Run the composition

### Required at least on first run!

Execute the run script for the first time:

```
./run-docker-compose.sh
```

The following docker volumes are created, if they do not exist:

* satosa-saml2spid_metadata
* satosa-saml2spid_certs
* satosa-saml2spid_static
* satosa-saml2spid_nginx_certs
* satosa-saml2spid_mongodata 

The first four are populated with sample data, respectively:

* satosa-saml2spid_metadata with data from ../example/metadata/
* satosa-saml2spid_certs with data from ../example/pki/
* satosa-saml2spid_static with data from ../example/static/
* satosa-saml2spid_nginx_certs with data from nginx/certs/

While the last one (*satosa-saml2spid_mongodata*) is populated by the MongoDB container on its first run.

After these steps, the images of the containers are downloaded and then the containers of the composition are started.

Finally you are warned you can run the following command to check composition start and status:

```
docker-compose -f docker-compose.yml logs -f
```

### Where is your data?

Command:

```
docker volume ls
```

Output:

```
DRIVER    VOLUME NAME
local     satosa-saml2spid_certs
local     satosa-saml2spid_metadata
local     satosa-saml2spid_mongodata
local     satosa-saml2spid_nginx_certs
local     satosa-saml2spid_static
```

In RedHat and Ubuntu based OS the Docker volumes directory is at:

```
# ls -1 /var/lib/docker/volumes/
satosa-saml2spid_certs
satosa-saml2spid_metadata
satosa-saml2spid_mongodata
satosa-saml2spid_nginx_certs
satosa-saml2spid_static
```

### NOT at first run or after volumes deletion!

After first run you can start the composition with the run script or by this commands:

```
docker-compose pull; docker-compose down -v; docker-compose up -d;docker-compose logs -f
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

Then you are asked if you want to delete the volumes and if you answer yes, you have to confirm volume by volume whether it should be deleted or not.

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

## docker-compose.yml
In the [project readme](../README.md#configuration-by-environments) is present a detailed list with each environment and his function
```
    environment:
      - SATOSA_BY_DOCKER=1

      - SATOSA_BASE=https://$HOSTNAME
      # - SATOSA_CONTACT_PERSON_EMAIL_ADDRESS=support.example@organization.org
      # - SATOSA_CONTACT_PERSON_FISCALCODE=01234567890
      # - SATOSA_CONTACT_PERSON_GIVEN_NAME=Name
      # - SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER=06123456789
      # - SATOSA_CONTACT_PERSON_IPA_CODE=
      # - SATOSA_CONTACT_PERSON_MUNICIPALITY=H501
      - SATOSA_DISCO_SRV=https://$HOSTNAME/static/disco.html
      # - SATOSA_ENCRYPTION_KEY=
      - MONGODB_PASSWORD=${MONGO_DBPASSWORD}
      - MONGODB_USERNAME=${MONGO_DBUSER}
      # - SATOSA_ORGANIZATION_DISPLAY_NAME_EN=Resource provided by Example Organization
      # - SATOSA_ORGANIZATION_DISPLAY_NAME_IT=Resource provided by Example Organization
      # - SATOSA_ORGANIZATION_NAME_EN=Resource provided by Example Organization
      # - SATOSA_ORGANIZATION_NAME_IT=Resource provided by Example Organization
      # - SATOSA_ORGANIZATION_URL_EN=https://example_organization.org
      # - SATOSA_ORGANIZATION_URL_IT=https://example_organization.org
      # - SATOSA_PRIVATE_KEY=
      # - SATOSA_PUBLIC_KEY=
      # - SATOSA_SALT=
      # - SATOSA_STATE_ENCRYPTION_KEY
      # - SATOSA_UI_DESCRIPTION_EN=Resource description
      # - SATOSA_UI_DESCRIPTION_IT=Resource description
      # - SATOSA_UI_DISPLAY_NAME_EN=Resource Display Name
      # - SATOSA_UI_DISPLAY_NAME_IT=Resource Display Name
      # - SATOSA_UI_INFORMATION_URL_EN=https://example_organization.org/information_url_en
      # - SATOSA_UI_INFORMATION_URL_IT=https://example_organization.org/information_url_en
      # - SATOSA_UI_LOGO_HEIGHT=60
      # - SATOSA_UI_LOGO_URL=https://example_organization.org/logo.png
      # - SATOSA_UI_LOGO_WIDTH=80
      # - SATOSA_UI_PRIVACY_URL_EN=https://example_organization.org/privacy_en
      # - SATOSA_UI_PRIVACY_URL_IT=https://example_organization.org/privacy_en
      - SATOSA_UNKNOW_ERROR_REDIRECT_PAGE=https://$HOSTNAME/static/error_page.html
      # - SATOSA_USER_ID_HASH_SALT
```
