#!/bin/bash
. /.venv/bin/activate

# get IDEM MDQ key
if [[ $GET_IDEM_MDQ_KEY == true ]]; then
  wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O $SATOSA_KEYS_FOLDER/idem-mdx-service-crt.pem
  wget https://registry.spid.gov.it/entities-idp -O metadata/idp/spid-entities-idps.xml
  echo "Downloaded IDEM MDQ key"
fi

wsgi_file=/.venv/lib/$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/satosa/wsgi.py
uwsgi --ini /satosa_proxy/uwsgi_setup/uwsgi/uwsgi.ini.docker --wsgi-file $wsgi_file
