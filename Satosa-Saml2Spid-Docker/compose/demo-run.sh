#!/bin/bash

#$BASEDIR/bash_replace.sh

#source $BASEDIR/bash_env

update_yaml () {
  if [[ -v 3 ]]; then
    UPDATE="${2} |= \"${3}\""
    yq -yi "$UPDATE" $1
    echo "yaml_update $1 (${2}) updated"
  else
    echo "yaml_update $1 (${2}) loaded with default value"
  fi
}

# Update proxy_conf.yaml .BASE with SATOSA_BASE env
update_yaml proxy_conf.yaml ".BASE" "$SATOSA_BASE"
# Update proxy_conf.yaml .STATE_ENCRYPTION_KEY with $SATOSA_STATE_ENCRYPTION_KEY
update_yaml proxy_conf.yaml ".STATE_ENCRYPTION_KEY" "$SATOSA_STATE_ENCRYPTION_KEY"
# Update proxy_conf.yaml .USER_ID_HASH_SALT with $SATOSA_USER_ID_HASH_SALT
update_yaml proxy_conf.yaml ".USER_ID_HASH_SALT" "$SATOSA_USER_ID_HASH_SALT"
# Update proxy_conf.yaml .UNKNOW_ERROR_REDIRECT_PAGE with $SATOSA_UNKNOW_ERROR_REDIRECT_PAGE env
update_yaml proxy_conf.yaml ".UNKNOW_ERROR_REDIRECT_PAGE" "$SATOSA_UNKNOW_ERROR_REDIRECT_PAGE"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_DISPLAY_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.display_name[0][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.display_name[1][0]" "$SATOSA_ORGANIZATION_DISPLAY_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.name[0][0]" "$SATOSA_ORGANIZATION_NAME_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.name[1][0]" "$SATOSA_ORGANIZATION_NAME_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.name[1][0]" "$SATOSA_ORGANIZATION_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_ORGANIZATION_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.url[0][0]" "$SATOSA_ORGANIZATION_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.organization.url[1][0]" "$SATOSA_ORGANIZATION_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_GIVEN_NAME
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_EMAIL_ADDRESS
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].email_address" "$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS"

# Update spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].telephone_number" "$SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER"
# Update spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_FISCALCODE
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].FiscalCode" "$SATOSA_CONTACT_PERSON_FISCALCODE"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_CONTACT_PERSON_GIVEN_NAME
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.contact_person[0].given_name" "$SATOSA_CONTACT_PERSON_GIVEN_NAME"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_DISPLAY_NAME_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.display_name[0]" "$SATOSA_UI_DISPLAY_NAME_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.display_name[1]" "$SATOSA_UI_DISPLAY_NAME_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.display_name[1]" "$SATOSA_UI_DISPLAY_NAME_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.display_name[1]" "$SATOSA_UI_DISPLAY_NAME_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_DESCRIPTION_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.description[0][0]" "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.description[0][0]" "$SATOSA_UI_DESCRIPTION_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.description[1][0]" "$SATOSA_UI_DESCRIPTION_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.description[1][0]" "$SATOSA_UI_DESCRIPTION_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_INFORMATION_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.information_url[0][0]" "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.information_url[0][0]" "$SATOSA_UI_INFORMATION_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.information_url[1][0]" "$SATOSA_UI_INFORMATION_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.information_url[1][0]" "$SATOSA_UI_INFORMATION_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_PRIVACY_URL_EN / IT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.privacy_url[0][0]" "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.privacy_url[0][0]" "$SATOSA_UI_PRIVACY_URL_EN"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.privacy_url[1][0]" "$SATOSA_UI_PRIVACY_URL_IT"
update_yaml plugins/backends/spidsaml2_backend.yaml ".config.sp_config.service.sp.ui_info.privacy_url[1][0]" "$SATOSA_UI_PRIVACY_URL_IT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_UI_LOGO_URL / WIDTH / HEIGHT
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.service.sp.ui_info.logo.text" "$SATOSA_UI_LOGO_URL"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.service.sp.ui_info.logo.width" "$SATOSA_UI_LOGO_WIDTH"
update_yaml plugins/backends/saml2_backend.yaml ".config.sp_config.service.sp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.sp_config.service.sp.ui_info.logo.height" "$SATOSA_UI_LOGO_HEIGHT"

# Update saml2_backend.yaml and spidsaml2_backend.yaml with $SATOSA_DISCO_SRV
update_yaml plugins/backends/saml2_backend.yaml ".config.disco_srv" "$SATOSA_DISCO_SRV"
update_yaml plugins/backends/spidsaml2_backend.yaml  ".config.disco_srv" "$SATOSA_DISCO_SRV"

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

SATOSA_APP=/usr/lib/python3.8/site-packages/satosa
uwsgi --uid 1000 --https 0.0.0.0:9999,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --check-static-docroot --check-static $BASEDIR/static/ --static-index disco.html &
P1=$!
uwsgi --uid 1000 --wsgi-file $SATOSA_APP/wsgi.py  --https 0.0.0.0:10000,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --callable app -b 32648
P2=$!
wait $P1 $P2
#wait $P2
