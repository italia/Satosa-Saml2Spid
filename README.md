# Satosa-Saml2Spid

A SAML2/OIDC configuration for [SATOSA](https://github.com/IdentityPython/SATOSA)
that aims to setup a **SAML-to-SAML Proxy** and **OIDC-to-SAML** 
compatible with the  **Italian Digital Identity Systems**.

## Table of Contents

1. [Goal](#goal)
2. [Demo components](#demo-components)
3. [Docker](#docker)
6. [Setup](README-Setup.md)
8. [For Developers](#for-developers)
9. [Author](#authors)
10. [Credits](#credits)


## Glossary

- **Frontend**, interface of the proxy that is configured as a SAML2 Identity Provider
- **Backend**, interface of the proxy that is configured as a SAML2 Service Provider
- **TargetRouting**, a SATOSA microservice for selecting the output backend to reach the endpoint (IdP) selected by the user
- **Discovery Service**, interface that allows users to select the authentication endpoint


## General features

Backends:

- SPID SP
- CIE SP
- eIDAS FICEP SP
- SAML2 SP

Frontends:

- SAML2 IDP
- OIDC OP (see [satosa-oidcop](https://github.com/UniversitaDellaCalabria/SATOSA-oidcop))

This project is tested in Continuous Integration with [spid-sp-test](https://github.com/italia/spid-sp-test) 
and passes all the tests regarding Metadata, Authn Requests and Responses.

## Goal

Satosa-Saml2 Spid is an intermediary between many SAML2/OIDC 
Service Providers and many SAML2 Identity Providers.
It allows traditional Saml2 Service Providers to communicate with
**Spid** and **CIE** Identity Providers adapting Metadata and AuthnRequest operations.

<img src="gallery/spid_proxy.png" width="256">

**Figure1** : _Traditional SAML2 Service Providers (SPs) proxied through the SATOSA SPID Backend gets compliances on AuthnRequest and Metadata operations_.

This solution configures multiple proxy _frontends_ and _backends_
to get communicating systems that, due to protocol or specific
limitations, traditionally could not interact each other.

## Demo components

The example project comes with the following demo pages, served
with the help of an additional webserver dedicated for static contents:

###### Discovery Service page

<img src="gallery/disco.png" width="512">

###### Generic error page

<img src="gallery/error_page.png" width="512">

###### Saml2 Signature Error page

<img src="gallery/error1.png" width="512">

###### AgID SPID test #104

<img src="gallery/error2.png" width="512">

These demo pages are static files, available in `example/static`.
To get redirection to these pages, or redirection to third-party services, it is required to configure the parameters below:

- file: `example/proxy_conf.yml`, example value: `UNKNOW_ERROR_REDIRECT_PAGE: "https://localhost:9999/error_page.html"`
- file: `example/plugins/{backends,frontends}/$filename`, example value: `disco_srv: "https://localhost:9999/static/disco.html"`


## Docker

<img src="gallery/docker-design.svg" width="512">

the official Satosa-Saml2SPID docker image is available at [italia/satosa-saml2spid](https://ghcr.io/italia/satosa-saml2spid)

To install the official docker image, simply type: `sudo docker pull ghcr.io/italia/satosa-saml2spid:latest`

### Docker compose

Satosa-Saml2SPID image is built with production ready logic.
The docker compose may use the [enviroment variables](#configuration-by-environment-variables) of satosa-saml2spid.

See [Docker-compose](Docker-compose) for details.

## Setup

See [README-SETUP.md](README-SETUP.md).


## For Developers

If you're doing tests and you don't want to pass by Discovery page each time you can use idphinting but only if your SP support it!
Here an example using djangosaml2 as SP:

```
http://localhost:8000/saml2/login/?idp=https://localhost:10000/Saml2IDP/metadata&next=/saml2/echo_attributes&idphint=https%253A%252F%252Flocalhost%253A8080
```

IF you're going to test Satosa-Saml2Spid with spid-sp-test, take a look to
its CI, [here](.github/workflows/python-app.yml).

### SPID technical Requirements

The SaToSa **SPID** backend contained in this project adopt specialized forks of pySAML2 and SATOSA, that implements the following patches,
read [this](README.idpy.forks.mngmnt.md) for any further explaination about how to patch by hands.

All the patches and features are currently merged and available with the following releases:

- [pysaml2](https://github.com/peppelinux/pysaml2/tree/pplnx-v7.0.1-1)
- [SATOSA](https://github.com/peppelinux/SATOSA/tree/oidcop-v8.0.0)

### Pending contributions to idpy

These are mandatory only for getting Spid SAML2 working, these are not needed for any other traditional SAML2 deployment:

- [disabled_weak_algs](https://github.com/IdentityPython/pysaml2/pull/628)
- [ns_prefixes](https://github.com/IdentityPython/pysaml2/pull/625)
- [SATOSA unknow error handling](https://github.com/IdentityPython/SATOSA/pull/324)
- [SATOSA redirect page on error](https://github.com/IdentityPython/SATOSA/pull/325)
- [SATOSA cookie configuration](https://github.com/IdentityPython/SATOSA/pull/363)

### Warnings

Here something that you should know before start.

- You must enable more than a single IdP (multiple metadata or single metadata with multiple entities) to get *Discovery Service* working.
- Proxy doesn't handle SAML2 SLO, so the spidSaml2 backend is configured with Authnforce -> True. For any further information see [Single Logout in Satosa](https://github.com/IdentityPython/SATOSA/issues/211).
- SATOSA Saml2 backend configuration has a **policy** section that will let us to define specialized behaviours
  and configuration for each SP (each by entityid). In this example I defined a single "default" behaviour with attributes **name_format**
  to **urn:oasis:names:tc:SAML:2.0:attrname-format:uri**, due to my needs to handle many service providers for which it could be painfull do a static definition each time.
  An additional "hack" have been made in `example/attributes-maps/satosa_spid_uri_hybrid.py`, where I adopted a hybrid mapping that works for
  both *URI* and *BASIC* formats. Feel free to customized or decouple these format in different files and per SP.

## External references

### Satosa-Saml2Spid tutorials

- [Corso-OIDC-in-IDEM-via-Proxy](https://github.com/IDEM-GARR-AAI/Corso-OIDC-in-IDEM-via-Proxy/)
- [Satosa-Saml2Spid installation tutorial](https://github.com/aslbat/Satosa-SPID-Proxy).

### SATOSA Official Documentation

- [SaToSa Saml2Saml Documentation](https://github.com/IdentityPython/SATOSA/blob/master/doc/one-to-many.md)
- [Use cases](https://github.com/IdentityPython/SATOSA/wiki#use-cases)

### Account Linking

- [pyMultiLDAP SaToSa MS](https://github.com/peppelinux/pyMultiLDAP/tree/master/multildap/satosa)
- Attributes Processing with [SATOSA-uniext](https://github.com/UniversitaDellaCalabria/SATOSA-uniExt/blob/master/satosa_uniext/processors/unical_attribute_processor.py)

### Additional resources

- [satosa-eidas-ansible](https://github.com/grnet/satosa-eidas-ansible)
- [aws-saml-proxy](https://github.com/senorkrabs/aws-saml-proxy)
- [satosa-oidc-to-sam](https://github.com/daserzw/satosa-oidc-to-saml)
- [SaToSa training aarc project](https://aarc-project.eu/wp-content/uploads/2019/03/SaToSa_Training.pdf)
- [IDP/SP Discovery service](https://medium.com/@sagarag/reloading-saml-idp-discovery-693b6bff45f0)
- https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#frontend
- [saml2.0 IdP and SP for tests](https://samltest.id/)
- https://www.spid.gov.it/assets/download/SPID_QAD.pdf

## Authors

- Giuseppe De Marco
- Andrea Ranaldi and his Team @ ISPRA Ambiente
- Stefano Colagreco @ CNR 

## Acknowledgments

- Fulvio Scorza and his Team @ Università del Piemonte Orientale
- Paolo Smiraglia (SPID certs)
- Identity Python Community (pySAML2 and SATOSA)
- GARR IDEM Community
