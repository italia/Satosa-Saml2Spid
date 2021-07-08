#!/bin/bash
CPATH=`pwd`
BIN=/usr/bin
PID=$$

function help () {
  echo "### Start Serice Provider ###"
  echo ""
  echo "Syntax: ./start.sh -u URL -p PATH -c"
  echo ""
  echo "-u URL is the idp metadata url, is mandatory the presence of an url or the metadata/idp.xml file "
  echo "-p PATH if present, copy the sp metadata on path"
  echo ""
  echo ## Example ##
  echo "$ ./start.sh -u https://idp.example.org/metadata -p /opt/satosa/metadata/sp" 
  echo "make new certificates, build a conf with idp metadata from idp.example.org and copy the sp metadata on satosa path"
  echo ""
  echo "## Files Path ##" 
  echo "pki/mykey.pem # sp private key" 
  echo "pki/myreq.csr # sp request key"
  echo "pki/mycert.pem # sp public key"
  echo "metadata/idp.xml # idp metadata"
  echo "metadata/sp.xml # sp metadata"
  echo ""
  echo "## other info ##"
  echo "server is run on localhost:9998"
  echo "for change it edit sp-wsgi/sp_conf.py"
  echo "log file is spx.log"
  kill 9 $PID
}

function abort () {
  echo 'operation aborted'
  cd ${CPATH}
  kill -9 $PID
}

function check_idp () {
  if [ ! -f "${CPATH}/metadata/idp.xml" ]; then
    echo "No IDP metadata supplied"
    abort
  fi
}

function prepare () {
  virtualenv -ppython3 sp.env
  source sp.env/bin/activate
  pip install --upgrade pip
  pip install -r requirements.txt
  mkdir ${CPATH}/pki
  mkdir ${CPATH}/metadata
}

function gen_cert () {
  if [ -f ${CPATH}/pki/mykey.pem -a -f ${CPATH}/pki/mycert.pem ]; then
    echo "Founded certificate"
  else
    ${BIN}/openssl genrsa -out ${CPATH}/pki/mykey.pem 2048
    chmod 600 ${CPATH}/pki/mykey.pem
    ${BIN}/openssl req -new -key ${CPATH}/pki/mykey.pem -out ${CPATH}/pki/myreq.csr -subj "/C=IT/ST=Rome/L=Rome/O=test/OU=test/CN=localhost"
    ${BIN}/openssl x509 -req -days 365 -in ${CPATH}/pki/myreq.csr -signkey ${CPATH}/pki/mykey.pem -out ${CPATH}/pki/mycert.pem
  fi
}

function gen_metadata () {
  make_metadata.py ${CPATH}/sp-wsgi/sp_conf.py > ${CPATH}/metadata/sp.xml
}

function copy_sp_metadata () {
  if [ "$DEST_PATH" ]; then
    cp ${CPATH}/metadata/sp.xml $DEST_PATH
  fi
}

while getopts ":u:p:h:" opt; do
  case ${opt} in
    u )
       wget $OPTARG -O ${CPATH}/metadata/idp.xml
      ;;
    p )
      DEST_PATH=$OPTARG
      ;;
    \? )
      help
      ;;
  esac
done


trap abort EXIT
check_idp
prepare
gen_cert
gen_metadata
copy_sp_metadata
python ${CPATH}/sp-wsgi/sp.py ${CPATH}/sp-wsgi/sp_conf
