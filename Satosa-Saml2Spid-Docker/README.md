# Satosa-Saml2Spid Docker (Image e Compose) parametrizzato

## Table of Contents
1. [Build](#build)
2. [Run the stack](#run-the-stack)
3. [Docker Compose](#docker-compose)

## Build
````
docker build -t satosa-saml2spid-test .
````

## Run the stack
````
cd compose/
docker-compose down -v && docker-compose up -d && docker-compose logs -f
````

## Docker compose


