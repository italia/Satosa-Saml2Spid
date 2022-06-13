#!/bin/bash

if [[ -v SAML2_REQUESTED_ATTRIBUTES ]]; then
  sed -i "s|required_attributes: \[\]|required_attributes: \[$SAML2_REQUESTED_ATTRIBUTES\]|g" plugins/backends/saml2_backend.yaml
fi

if [[ -v SATOSA_BACKEND_MODULES ]]; then
  sed -i "s|BACKEND_MODULES: \[\]|BACKEND_MODULES: \[$SATOSA_BACKEND_MODULES\]|g" proxy_conf.yaml
fi

if [[ -v SATOSA_FRONTEND_MODULES ]]; then
  sed -i "s|FRONTEND_MODULES: \[\]|FRONTEND_MODULES: \[$SATOSA_FRONTEND_MODULES\]|g" proxy_conf.yaml
fi

