#!/bin/bash
export COMPOSE_PROFILES=demo
export SKIP_UPDATE=
function clean_data {
  rm -Rf ./mongo/db/*
  rm -Rf ./satosa/*
  rm -Rf ./djangosaml2_sp/*
}

function initialize_satosa {
  mkdir -p ./satosa
  mkdir -p ./djangosaml2_sp
  mkdir -p ./mongo/db

  if [ ! -f ./satosa/proxy_conf.yaml ]; then cp -R ../example/* ./satosa/ ; else echo 'satosa directory is already initialized' ; fi
  if [ ! -f ./djangosaml2_sp/run.sh ]; then cp -R ../example_sp/djangosaml2_sp/* ./djangosaml2_sp ; else echo 'djangosaml2_sp directory is already initialided' ; fi
}

function update {
  if [[ -z "${SKIP_UPDATE}" ]]; then
    echo -e "Provo a scaricare le nuove versioni. \n"
    docker compose -f docker-compose.yml pull
    echo -e "\n"
    echo -e "Provo a fare il down della composizione. \n"
    docker compose -f docker-compose.yml down -v
    echo -e "\n"
    echo -e "Tiro su la composizione, in caso, con le nuove versioni delle immagini. \n"
    docker compose -f docker-compose.yml build django_sp
  fi
}

function start {
  docker compose -f docker-compose.yml up --wait --wait-timeout 60 --remove-orphans
  echo -e "\n"
  echo -e "Completato. Per visionare i logs: 'docker-compose -f docker-compose.yml logs -f'"
  exit 0
}

function help {
  echo ""
  echo "### run-docker-compose.sh ###"
  echo ""
  echo "initialize check update and start Satosa-Saml2Spid"
  echo ""
  echo "Option"
  echo "-f Force clean and reinitialize data for Satosa, MongoDB and Djangosaml2_SP"
  echo "-h Print this help"
  echo "-p Set production profile: start satosa, nginx, mongo"
  echo "-s Skip docker image update"
  echo "-d Set data entry profile: start satosa, nginx, mongo, mongo-express"
  echo "   if isn't set -d or -p defatult demo profile is started"
  echo "   default demo profile start: satosa, nginx, mongo, mongo-express, django-sp, spid-saml-check"
}

while getopts ":fpdsh" opt; do
  case ${opt} in
   f)
     clean_data
     ;;
   p)
     unset COMPOSE_PROFILES
     ;;
   d)
     COMPOSE_PROFILES=dataentry
     ;;
   s)
     SKIP_UPDATE=true
     ;;
   h)
     help
     exit 0
     ;;
   ?)
     echo "Invalid option: -${OPTARG}."
     echo ""
     help
     exit 1
     ;;
  esac
done
initialize_satosa
update
start
echo $SKIP_UPDATE

