#!/bin/bash
. /.venv/bin/activate

# get IDEM MDQ key
if [[ $GET_IDEM_MDQ_KEY == true ]]; then
  wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O $KEYS_FOLDER/idem-mdx-service-crt.pem
  wget https://registry.spid.gov.it/metadata/idp/spid-entities-idps.xml -O metadata/idp/spid-entities-idps.xml
  echo "Downloaded IDEM MDQ key"
fi

uwsgi --ini /satosa_proxy/uwsgi_setup/uwsgi/uwsgi.ini.docker
