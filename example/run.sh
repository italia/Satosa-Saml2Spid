#!/bin/bash

update_yaml () {
  if [[ -n "${3}" ]]; then
    UPDATE="${2} |= \"${3}\""
    yq -yi "$UPDATE" $1
    echo "yaml_update $1 (${2}) updated"
  else
    echo "yaml_update $1 (${2}) loaded with default value"
  fi
}

# Update proxy_conf.yaml .BASE with SATOSA_BASE env
update_yaml proxy_conf.yaml ".BASE" "$SATOSA_BASE"
# Update proxy_conf.yaml .STATE_ENCRYPTION_KEY with $SATOSA_ENCRYPTION_KEY
update_yaml proxy_conf.yaml ".STATE_ENCRYPTION_KEY" "$SATOSA_STATE_ENCRYPTION_KEY"
# Update proxy_conf.yaml .USER_ID_HASH_SALT with $SATOSA_USER_ID_HASH_SALT
update_yaml proxy_conf.yaml ".USER_ID_HASH_SALT" "$SATOSA_SALT"
# Update proxy_conf.yaml .UNKNOW_ERROR_REDIRECT_PAGE with $SATOSA_UNKNOW_ERROR_REDIRECT_PAGE env
update_yaml proxy_conf.yaml ".UNKNOW_ERROR_REDIRECT_PAGE" "$SATOSA_UNKNOW_ERROR_REDIRECT_PAGE"

# Update spidsaml2_backend.yaml and cieSaml2_backend.saml with $SATOSA_BASE env
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.static_storage_url" "$SATOSA_BASE"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.static_storage_url" "$SATOSA_BASE"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_DISPLAY_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.name[1][0]" "$SATOSA_ORGANIZATION_NAME_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.name[1][0]" "$SATOSA_ORGANIZATION_NAME_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.contact_person[0].company" "$SATOSA_ORGANIZATION_NAME_IT"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.name[1][0]" "$SATOSA_ORGANIZATION_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_GIVEN_NAME
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"
update_yaml plugins/frontends/saml2_frontend.yaml  ".config.idp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_EMAIL_ADDRESS
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"
update_yaml plugins/backends/ciesaml2_backend.yaml  ".config.sp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"
update_yaml plugins/frontends/saml2_frontend.yaml  ".config.idp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"

# Update spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].telephone_number" "$SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER"
update_yaml plugins/backends/ciesaml2_backend.yaml  ".config.sp_config.contact_person[0].telephone_number" "$SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER"

# Update spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_FISCALCODE
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].FiscalCode" "$SATOSA_CONTACT_PERSON_FISCALCODE"

# Update ciesaml2_backend with $SATOSA_CONTACT_PERSON_IPA_CODE
update_yaml plugins/backends/ciesaml2_backend.yaml  ".config.sp_config.contact_person[0].cie_info.IPACode" "$SATOSA_CONTACT_PERSON_IPA_CODE"

# Update ciesaml2_backend with $SATOSA_CONTACT_PERSON_MUNICIPALITY
update_yaml plugins/backends/ciesaml2_backend.yaml  ".config.sp_config.contact_person[0].cie_info.Municipality" "$SATOSA_CONTACT_PERSON_MUNICIPALITY"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_DISPLAY_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[0]["text"]' "$SATOSA_UI_DISPLAY_NAME_EN" 
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[0]["text"]' "$SATOSA_UI_DISPLAY_NAME_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[0]["text"]' "$SATOSA_UI_DISPLAY_NAME_EN"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.display_name[0]["text"]' "$SATOSA_UI_DISPLAY_NAME_EN"          
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[1]["text"]' "$SATOSA_UI_DISPLAY_NAME_IT"         
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[1]["text"]' "$SATOSA_UI_DISPLAY_NAME_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.display_name[1]["text"]' "$SATOSA_UI_DISPLAY_NAME_IT"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.display_name[1]["text"]' "$SATOSA_UI_DISPLAY_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_DESCRIPTION_EN / IT
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[0]["text"]' "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[0]["text"]' "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[0]["text"]' "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.description[0]["text"]' "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[1]["text"]' "$SATOSA_UI_DESCRIPTION_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[1]["text"]' "$SATOSA_UI_DESCRIPTION_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.description[1]["text"]' "$SATOSA_UI_DESCRIPTION_IT"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.description[1]["text"]' "$SATOSA_UI_DESCRIPTION_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_INFORMATION_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[0]["text"]' "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[0]["text"]' "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[0]["text"]' "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.information_url[0]["text"]' "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[1]["text"]' "$SATOSA_UI_INFORMATION_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[1]["text"]' "$SATOSA_UI_INFORMATION_URL_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.information_url[1]["text"]' "$SATOSA_UI_INFORMATION_URL_IT"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.information_url[1]["text"]' "$SATOSA_UI_INFORMATION_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_PRIVACY_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[0]["text"]' "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[0]["text"]' "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[0]["text"]' "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.privacy_statement_url[0]["text"]' "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[1]["text"]' "$SATOSA_UI_PRIVACY_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[1]["text"]' "$SATOSA_UI_PRIVACY_URL_IT"
update_yaml plugins/backends/ciesaml2_backend.yaml '.config.sp_config.service.sp.ui_info.privacy_statement_url[1]["text"]' "$SATOSA_UI_PRIVACY_URL_IT"
update_yaml plugins/frontends/saml2_frontend.yaml '.config.idp_config.service.idp.ui_info.privacy_statement_url[1]["text"]' "$SATOSA_UI_PRIVACY_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_LOGO_URL / WIDTH / HEIGHT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.service.idp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.service.idp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"
update_yaml plugins/backends/ciesaml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"
update_yaml plugins/frontends/saml2_frontend.yaml ".config.idp_config.service.idp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_DISCO_SRV
update_yaml plugins/backends/saml2_backend.yaml ".config.disco_srv" "$SATOSA_DISCO_SRV"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.disco_srv" "$SATOSA_DISCO_SRV"
update_yaml plugins/backends/ciesaml2_backend.yaml  ".config.disco_srv" "$SATOSA_DISCO_SRV"

# Set username and password for mongodb in oidc_op_frontend with $SATOSA_MONGODB_USERNAME and $SATOSA_MONGODB_PASSWORD
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.storage.kwargs.connection_params.username" "$MONGODB_USERNAME"
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.storage.kwargs.connection_params.password" "$MONGODB_PASSWORD"

# Set encrypt password and salt for oidc_op_frontend with $SATOSA_SALT and $
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.op.server_info.session_params.password" "$SATOSA_ENCRYPTION_KEY"
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.op.server_info.session_params.salt" "$SATOSA_SALT"
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.op.server_info.session_params.sub_func.pairwise.kwargs.salt" "$SATOSA_SALT"
update_yaml plugins/frontends/oidc_op_frontend.yaml ".config.op.server_info.session_params.sub_func.pairwise.kwargs.salt" "$SATOSA_SALT"

# Update saml2_backend.yaml requested_attributes
if [[ -v SATOSA_SAML2_REQUESTED_ATTRIBUTES ]]; then
  yq -yi --argjson a "${SATOSA_SAML2_REQUESTED_ATTRIBUTES}" '.config.sp_config.service.sp.requested_attributes |= $a' plugins/backends/saml2_backend.yaml
  echo "yaml_update plugins/backends/saml2_backend.yaml requested_attributes updated"
else
  echo "yaml_update plugins/backends/saml2_backend.yaml requested_attributes loaded with default value"
fi

# Update spidsaml2_backend requested_attributes
if [[ -v SATOSA_SPID_REQUESTED_ATTRIBUTES ]]; then
  yq -yi --argjson a "${SATOSA_SPID_REQUESTED_ATTRIBUTES}" '.config.sp_config.service.sp.requested_attributes |= $a' plugins/backends/spidsaml2_backend.yaml
  echo "yaml_update plugins/backends/spidsaml2_backend.yaml requested_attributes updated"
else
  echo "yaml_update plugins/backends/spidsaml2_backend.yaml requested_attributes loaded with default value"
fi

# import satosa keys with $SATOSA_PUBLIC_KEY and $SATOSA_PRIVATE_KEY, both must be present
if [[ -v SATOSA_PRIVATE_KEY && -v SATOSA_PUBLIC_KEY ]]; then
  echo $SATOSA_PRIVATE_KEYS > pki/privkey.pem
  echo $SATOSA_PUBLIC_KEY > pki/cert.pem
  echo "Satosa keys imported"
else
  echo "satosa has loaded default keys"
fi

# get IDEM MDQ key
wget https://mdx.idem.garr.it/idem-mdx-service-crt.pem -O pki/idem-mdx-service-crt.pem

if [[ -v SATOSA_BY_DOCKER ]]; then
  SATOSA_APP=/usr/lib/python3.8/site-packages/satosa
# in questo modo parla uwsgi, dal browser sulla porta 10000 si ha un errore e in nginx va utilizzato uwsgi_pass
  uwsgi --wsgi-file $SATOSA_APP/wsgi.py --socket 0.0.0.0:10000 --callable app -b 32768 --processes 4 --threads 2

# in questo modo parla in http, può essere raggiunto anche dal browser direttamente e in nginx occorre utilizzare il proxy http
#  uwsgi --wsgi-file $SATOSA_APP/wsgi.py  --http 0.0.0.0:10000 --callable app -b 32768 --processes 4 --threads 2 
else
  export SATOSA_APP=$VIRTUAL_ENV/lib/$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/satosa
  uwsgi --uid 1000 --https 0.0.0.0:9999,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --check-static-docroot --check-static $BASEDIR/static/ --static-index disco.html &
  P1=$!
  uwsgi --uid 1000 --wsgi-file $SATOSA_APP/wsgi.py  --https 0.0.0.0:10000,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --callable app -b 32648
  P2=$!
  wait $P1 $P2
fi
