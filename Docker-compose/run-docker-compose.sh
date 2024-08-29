#!/bin/bash

VOLUME_ALREADY_EXISTS=10
VOLUME_CREATION_FAIL=20

function create-volume {
    if [ ! "$(docker volume ls -q -f name=$1)" ]; then 
        echo -e "\nCreazione del docker volume $1"
        docker volume create --name=$1
        res=$?
        if [[ $res != 0 ]]; then
            return $VOLUME_CREATION_FAIL; fi
    else 
        echo -e "\nIgnorata creazione del docker volume $1: volume gia' esistente"
        return $VOLUME_ALREADY_EXISTS
    fi
    return 0
}

function create-volume-with-data {
    create-volume $1
    res=$?
    if [[ $res != 0 ]]; then
        # skip data initialization if the volume creation fails or if it already exists
        return $res; fi
    echo -e "\nInizializzazione del docker volume $1 con dati provenienti da $2"
    volume_mountpoint=$(docker volume inspect $1 | jq .[0].Mountpoint | sed 's/"//g')
    sudo cp -R $2* $volume_mountpoint
    res=$?
    if [[ $res != 0 ]]; then
        echo -e "\nFallback: inizializzazione del docker volume per creazione container temporaneo: questa operazione potrebbe richiedere un po' di tempo..."
        tmp_container_name="tmp-$RANDOM$RANDOM$RANDOM"
        docker run -d --rm --name $tmp_container_name -v $1:/root alpine tail -f /dev/null
        res=$?
        if [[ $res != 0 ]]; then
            return $VOLUME_CREATION_FAIL; fi
        docker cp $2/. $tmp_container_name:/root/
        res=$?
        docker stop $tmp_container_name
        if [[ $res != 0 ]]; then
            return $VOLUME_CREATION_FAIL; fi
    fi
    echo -e "\nInizializzazione del docker volume $1 terminata"
    return 0
}

create-volume-with-data satosa-saml2spid_nginx_certs nginx/certs/
res=$?
if [[ $res == $VOLUME_CREATION_FAIL ]]; then
	echo -e "\nERRORE: setup docker volumes fallita\n"
	return 1
fi

create-volume satosa-saml2spid_mongodata 
res=$?
if [[ $res == $VOLUME_CREATION_FAIL ]]; then
	echo -e "\nERRORE: setup docker volumes fallita\n"
	return 1
fi


echo -e "\n"

echo -e "Provo a scaricare le nuove versioni. \n"

docker compose -f docker-compose.yml pull

echo -e "\n"

echo -e "Provo a fare il down della composizione. \n"

docker compose -f docker-compose.yml down -v

echo -e "\n"

echo -e "Tiro su la composizione, in caso, con le nuove versioni delle immagini. \n"

docker compose -f docker-compose.yml build django_sp

docker compose -f docker-compose.yml up -d --wait --wait-timeout 60

echo -e "\n"

echo -e "Completato. Per visionare i logs: 'docker-compose -f docker-compose.yml logs -f'"

exit 0
