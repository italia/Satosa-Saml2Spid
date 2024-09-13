## run-docker-compose.sh

This scritp is a simple uility to initialize, update and start the Satosa-saml2spid compose structure.

### Script Options
* `-f` Force clean and reinitialize data for Satosa, MongoDB and Djangosaml2_SP
* `-h` Print this help
* `-s`Skip docker image update
* `-p` unset compose profile. Run: satosa and nginx. Usefull for production
* `-m` Set 'mongo' compose profile. Run: satosa, nginx, mongo
* `-M` Set 'mongoexpress' compose profile. Run: satosa, nginx, mongo, mongo-express
* `-d` Set 'dev' compose profile. Run: satosa, nginx, django-sp, spid-saml-check.
   If isn't set any of -p, -m, -M, -d, is used 'demo' compose profile.
   Demo compose profile start: satosa, nginx, mongo, mongo-express, django-sp, spid-saml-check

`run-docker-compose.sh` must be executed from `docker-compose` directory. To run the script the user must have access to the docker system.

On startup the script check if the directories required from docker compose are presents:
* ./satosa-project
* ./djangosaml2_sp
* ./mongo/db
* ./nginx/html/static

After the script test if the required directories are populated and if isn't copy the default files
| Directory         | test presence of | default origin                 |
| ----------------- | ---------------- | ------------------------------ |
| satosa-project    | proxy_conf.yaml  | ../example/*                   |
| djangosaml2_sp    | run.sh           | ../example_sp/djangosaml2_sp/* |
| nginx/html/static | disco.html       | ../example/static/*            |


Unless `-s` options is enabled, on every start the script try to:
* Download the new versione of each required images
* Compile the new local image (django_sp)

If `-c` option is enables, before each, the script remove all data from theese directories:
* mongo/db/*
* satosa-project/*
* djangosaml2_sp/*
* nginx/html/static

The empty directories are populated with the default data

### Insights
* For more details on Satosa-saml2spid docker compose read [docker-compose readme page](./README.docker-compose.md)
* For more details on Satosa-saml2spid docker compose profiles read [docker-compose-profiles page](./README.docker-compose-profiles.md)
* For more details on MongoDB for Satosa-saml2spid read [MongoDB page](./README.mongo.md)
