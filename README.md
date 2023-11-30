# Satosa-Saml2Spid

A SAML2/OIDC IAM Proxy based on [SATOSA](https://github.com/IdentityPython/SATOSA)
for **SAML-to-SAML**, **OIDC-to-SAML** and **SAML-to-Wallet** interoperability
with the  **Italian Digital Identity Systems**.

## Table of Contents

1. [Glossary](#Glossary)
2. [General features](#general-features)
3. [Introduction](#introduction)
4. [Demo components](#demo-components)
5. [How to start the environment](#how-to-start-the-environment)
6. [For Developers](#for-developers)
7. [Author](#authors)
8. [Credits](#credits)


## Glossary

- **Frontend**, SAML2 Identity Provider, OpenID Connect Provider.
- **Backend**, SAML2 Service Provider, OpenID Connect Relying Party, Wallet Relying Party.
- **TargetRouting**, a SATOSA microservice for selecting the output backend to reach the endpoint (IdP) selected by the user.
- **Discovery Service**, interface that allows users to select the authentication endpoint.


## General features

Backends:

- SPID SP
- CIE SP
- FICEP SP (eIDAS 1.0)
- SAML2 SP
- EUDI Wallet (eIDAS 2.0)

Frontends:

- SAML2 IDP
- OIDC OP (see [satosa-oidcop](https://github.com/UniversitaDellaCalabria/SATOSA-oidcop))

This project is tested in Continuous Integration using [spid-sp-test](https://github.com/italia/spid-sp-test),
with Metadata, Authn Requests and Responses.

## Introduction

Satosa-Saml2 Spid is an intermediate between many SAML2/OIDC 
Service Providers and many SAML2 Identity Providers.
It allows traditional Saml2 Service Providers to communicate with
**Spid**, **CIE** and **eIDAS** Identity Providers adapting Metadata and AuthnRequest operations.

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

See other page screenshot [here](README-GALLERY.md).

These demo pages are static files, available in `example/static`.
To get redirection to these pages, or redirection to third-party services, it is required to configure the files below:

- file: `example/proxy_conf.yml`, example value: `UNKNOW_ERROR_REDIRECT_PAGE: "https://static-contents.example.org/error_page.html"`
- file: `example/plugins/{backends,frontends}/$filename`, example value: `disco_srv: "https://static-contents.example.org/static/disco.html"`

<hr>

## How to start the environment

The average time to set up the environment is about 1 hour. This time may vary depending on the machine's resources and the type of network connection.

> Make sure that in your environment is correcly installed:
> - a version of Python 3.10 or higher
> - Git
> - Docker

#### STEP 1 - Setup
please review the following documentation in order to install, configure and run Satosa-Saml2spid
 [README-SETUP.md](README-Setup.md)

#### STEP 2 - Docker Compose

please review the following documentation [Docker-compose](Docker-compose/README.md) in order to create the volumes:
- satosa-saml2spid_mongodata
- satosa-saml2spid_nginx_certs


Satosa-Saml2Spid image is built with production ready logic.
The docker compose may use the [enviroment variables](#configuration-by-environment-variables) 
to configure Satosa-Saml2Spid.

<img src="gallery/docker-design.svg" width="512">

The official Satosa-Saml2SPID docker image is available at 
[italia/satosa-saml2spid](https://ghcr.io/italia/satosa-saml2spid).

Below some quick commands:

- Install it, execute the following command: `sudo docker pull ghcr.io/italia/satosa-saml2spid:latest`.
- Build locally the image, execute the following command: `docker build -t satosa-saml2spid .`.
- Inspect the image content: `docker run -it -v $(pwd)/example:/satosa_proxy --entrypoint sh satosa-saml2spid`.

#### STEP 3 - Install and Run Djangosaml2

please review the following documentation [Djangosaml2](example_sp/djangosaml2_sp/README.md)

<hr>

## For Developers

If you're doing tests and you don't want to pass through the Discovery page each time you can use `idphinting` if your SP support it.
Below an example using a djangosaml2 Service Provider:

```
http://localhost:8000/saml2/login/?idp=https://localhost:10000/Saml2IDP/metadata&next=/saml2/echo_attributes&idphint=https%253A%252F%252Flocalhost%253A8080
```

If you're going to test Satosa-Saml2Spid with spid-sp-test, take a look to
[.github/workflows/python-app.yml](.github/workflows/python-app.yml).

Additional information can be found [here](README-DEV.md).

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
