#!/bin/bash

### Check if volume satosa-saml2spid_metadata doesn't exist and if so, create it! ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_metadata)" ]
then
    echo -e "Il volume satosa-saml2spid_metadata non esiste, lo creo! \n"
    docker volume create --name=satosa-saml2spid_metadata
    echo -e "\n"
    echo -e "Ho creato il volume e ci copio i dati da ../example/metadata/ \n"
    sudo cp -R ../example/metadata/* `docker volume inspect satosa-saml2spid_metadata | jq .[0].Mountpoint | sed 's/"//g'`
else
    echo -e "Il volume satosa-saml2spid_metadata esiste, non faccio nulla! \n"	
fi

### Check if a volume satosa-saml2spid_certs doesn't exist and if so, create it! ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_certs)" ]
then
    echo -e "Il volume satosa-saml2spid_certs non esiste, lo creo! \n"
    docker volume create --name=satosa-saml2spid_certs
    echo -e "\n"
    echo -e "Ho creato il volume e ci copio i dati da ../example/pki/ \n"
    sudo cp -R ../example/pki/* `docker volume inspect satosa-saml2spid_certs | jq .[0].Mountpoint | sed 's/"//g'`
else
    echo -e "Il volume satosa-saml2spid_certs esiste, non faccio nulla! \n"
fi

### Check if volume satosa-saml2spid_static doesn't exist and if so, create it! ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_static)" ]
then
    echo -e "Il volume satosa-saml2spid_static non esiste, lo creo! \n"
    docker volume create --name=satosa-saml2spid_static
    echo -e "\n"
    echo -e "Ho creato il volume e ci copio i dati da ../example/static/ \n"
    sudo cp -R ../example/static/* `docker volume inspect satosa-saml2spid_static | jq .[0].Mountpoint | sed 's/"//g'`
else
    echo -e "Il volume satosa-saml2spid_static esiste, non faccio nulla! \n"
fi

### Check if volume satosa-saml2spid_nginx_certs doesn't exist and if so, create it! ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_nginx_certs)" ]
then
    echo -e "Il volume satosa-saml2spid_nginx_certs non esiste, lo creo! \n"
    docker volume create --name=satosa-saml2spid_nginx_certs
    echo -e "\n"
    echo -e "Ho creato il volume e ci copio i dati da nginx/certs/ \n"
    sudo cp -R nginx/certs/* `docker volume inspect satosa-saml2spid_nginx_certs | jq .[0].Mountpoint | sed 's/"//g'`
else
    echo -e "Il volume satosa-saml2spid_nginx_certs esiste, non faccio nulla! \n"
fi

### Check if volume satosa-saml2spid_mongodata doesn't exist and if so, create it! ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_mongodata)" ]
then
    echo -e "Il volume satosa-saml2spid_mongodata non esiste, lo creo! \n"
    docker volume create --name=satosa-saml2spid_mongodata
fi

echo -e "\n"

echo -e "Provo a scaricare le nuove versioni. \n"

docker-compose -f docker-compose.yml pull

echo -e "\n"

echo -e "Provo a fare il down della composizione. \n"

docker-compose -f docker-compose.yml down -v

echo -e "\n"

echo -e "Tiro su la composizione, in caso, con le nuove versioni delle immagini. \n"

docker-compose -f docker-compose.yml up -d

echo -e "\n"

echo -e "Ho Completato! \n"
echo -e "Se volete vedere il log live potete lanciare il comando: 'docker-compose -f docker-compose.yml logs -f' \n"

exit 0
