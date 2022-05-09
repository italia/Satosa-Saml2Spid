#!/bin/bash

if [[ -v SAML2_REQUESTED_ATTRIBUTES ]]; then
  sed -i "s/required_attributes: \[\]/required_attributes: \[$SAML2_REQUESTED_ATTRIBUTES\]/" plugins/backends/saml2_backend.yaml
fi

if [[ -v BACKEND_MODULES ]]; then
  sed -i "s/BACKEND_MODULES: \[\]/BACKEND_MODULES: \[$BACKEND_MODULES\]/" proxy_conf.yaml
fi

if [[ -v FRONTEND_MODULES ]]; then
  sed -i "s/FRONTEND_MODULES: \[\]/FRONTEND_MODULES: \[$FRONTEND_MODULES\]/" proxy_conf.yaml
fi

