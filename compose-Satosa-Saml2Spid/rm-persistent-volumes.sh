#!/bin/bash
echo -e "\n"

echo -e "Inizio le procedure per fare il down della composizione e poi CANCELLARE i volumi persistenti! \n"

echo -e "Fermo la composizione! \n"
docker-compose -f docker-compose.yml down -v;

echo -e "\n"

read -p "Volete veramente procedere con la cancellazione dei volumi persistenti? Tutti i dati andranno persi! Procedo ? (y/n) :" ELIMINA_DATI_PERSISTENTI
ELIMINA_DATI_PERSISTENTI=${ELIMINA_DATI_PERSISTENTI:-"n"}
export ELIMINA_DATI_PERSISTENTI
if [ $ELIMINA_DATI_PERSISTENTI != "y" ] 
then
    echo -e "\n"
    echo -e "Non elimino nulla ed esco!!! \n"
    exit 0
else

echo -e "Procedo ... \n"                  

echo -e "\n"

### satosa-saml2spid_metadata ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_metadata)" ]
then
    echo -e "Il volume satosa-saml2spid_metadata non esiste, quindi non faccio nulla! \n"
else
    read -p "Il volume satosa-saml2spid_metadata esiste. Lo cancello?(y/n):" ELIMINA_METADATA
    ELIMINA_METADATA=${ELIMINA_METADATA:-"n"}
    export ELIMINA_METADATA
    if [ $ELIMINA_METADATA = "y" ] 
    then 
        docker volume rm satosa-saml2spid_metadata
	echo -e "Eliminato satosa-saml2spid_metadata !!! \n"
    else
	echo -e "Non ho eliminato satosa-saml2spid_metadata !!! \n"        	     

    fi
fi    

### satosa-saml2spid_certs ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_certs)" ]
then
    echo -e "Il volume satosa-saml2spid_certs non esiste, quindi non faccio nulla! \n"
else
    read -p "Il volume satosa-saml2spid_certs esiste. Lo cancello?(y/n):" ELIMINA_SATOSA_CERTS
    ELIMINA_SATOSA_CERTS=${ELIMINA_SATOSA_CERTS:-"n"}
    export ELIMINA_SATOSA_CERTS
    if [ $ELIMINA_SATOSA_CERTS = "y" ]
    then
        docker volume rm satosa-saml2spid_certs
        echo -e "Eliminato satosa-saml2spid_certs !!! \n"
    else
        echo -e "Non ho eliminato satosa-saml2spid_certs !!! \n"                
    fi
fi

### satosa-saml2spid_static ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_static)" ]
then
    echo -e "Il volume satosa-saml2spid_static non esiste, quindi non faccio nulla! \n"
else
    read -p "Il volume satosa-saml2spid_static esiste. Lo cancello?(y/n):" ELIMINA_SATOSA_STATIC
    ELIMINA_SATOSA_STATIC=${ELIMINA_SATOSA_STATIC:-"n"}
    export ELIMINA_SATOSA_STATIC
    if [ $ELIMINA_SATOSA_STATIC = "y" ]
    then
        docker volume rm satosa-saml2spid_static
        echo -e "Eliminato satosa-saml2spid_static !!! \n"
    else
        echo -e "Non ho eliminato satosa-saml2spid_static !!! \n"                

    fi
fi

### satosa-saml2spid_nginx_certs ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_nginx_certs)" ]
then
    echo -e "Il volume satosa-saml2spid_nginx_certs non esiste, quindi non faccio nulla! \n"
else
    read -p "Il volume satosa-saml2spid_nginx_certs esiste. Lo cancello?(y/n):" ELIMINA_NGINX_CERTS
    ELIMINA_NGINX_CERTS=${ELIMINA_NGINX_CERTS:-"n"}
    export ELIMINA_NGINX_CERTS
    if [ $ELIMINA_NGINX_CERTS = "y" ]
    then
        docker volume rm satosa-saml2spid_nginx_certs
        echo -e "Eliminato satosa-saml2spid_nginx_certs !!! \n"
    else
        echo -e "Non ho eliminato satosa-saml2spid_nginx_certs !!! \n"

    fi
fi

### satosa-saml2spid_mongodata ###
if [ ! "$(docker volume ls -q -f name=satosa-saml2spid_mongodata)" ]
then
    echo -e "Il volume satosa-saml2spid_mongodata non esiste, quindi non faccio nulla! \n"
else
    read -p "Il volume satosa-saml2spid_mongodata esiste. Lo cancello?(y/n):" ELIMINA_MONGODATA
    ELIMINA_MONGODATA=${ELIMINA_MONGODATA:-"n"}
    export ELIMINA_MONGODATA
    if [ $ELIMINA_MONGODATA = "y" ]
    then
        docker volume rm satosa-saml2spid_mongodata
        echo -e "Eliminato satosa-saml2spid_mongodata !!! \n"
    else
        echo -e "Non ho eliminato satosa-saml2spid_mongodata !!! \n"

    fi	
fi

fi

exit 0
