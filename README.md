# Satosa-Saml2Spid

A SAML2/OIDC configuration for [SATOSA](https://github.com/IdentityPython/SATOSA)
that aims to setup a **SAML-to-SAML Proxy** and **OIDC-to-SAML** 
compatible with the  **Italian Digital Identity Systems**.

## Table of Contents

1. [Goal](#goal)
2. [Demo components](#demo-components)
3. [Docker image](#docker-image)
4. [docker-compose](#doker-compose)
5. [MongoDB](./README.mongo.md)
6. [Setup](#setup)
7. [Start the Proxy](#start-the-proxy)
8. [Additional technical informations](#additional-technical-informations-for-developers)
9. [Author](#author)
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


## Docker image

<img src="gallery/docker-design.svg" width="512">

the official Satosa-Saml2SPID docker image is available at [italia/satosa-saml2spid](https://ghcr.io/italia/satosa-saml2spid)

To install the official docker image, simply type: `sudo docker pull ghcr.io/italia/satosa-saml2spid:latest`

## Docker compose

Satosa-Saml2SPID image is built with production ready logic, anyway some configurations are required!
The docker compose may use the [enviroment variables](#configuration-by-environment-variables) of satosa-saml2spid.

See [compose-Satosa-Saml2Spid](compose-Satosa-Saml2Spid) for details.

### NGINX setup

A valid ssl certificate is needed, to add your certificate you have to override the `/etc/nginx/certs` directory with your docker volume, containing your certificates.

## Setup

###### Dependencies Ubuntu

```
sudo apt install -y libffi-dev libssl-dev python3-pip xmlsec1 procps libpcre3 libpcre3-dev
```

###### Dependencies Centos/RHEL

```
sudo yum install -y libffi-devel openssl-devel python3-pip xmlsec1 procps pcre pcre-devel
sudo yum groupinstall "Development Tools"
sudo yum install -y python3-wheel python3-devel
```

###### Prepare environment

```
pip install --upgrade pip
pip install virtualenv

mkdir satosa_proxy && cd satosa_proxy
virtualenv -ppython3 satosa.env
source satosa.env/bin/activate

git clone https://github.com/italia/Satosa-Saml2Spid.git repository
cd repository
pip install -r requirements.txt
```

## Configure the Proxy

- Create certificates for SPID see [psmiraglia](https://github.com/italia/spid-compliant-certificates).
- Copy `repository/example/*` contents (`cp -R repository/example/* .`) and **edit the files below** 

  - `proxy_conf.yaml`
  - `plugins/backends/spidsaml2_backend.yaml`
  - `plugins/backends/saml2_backend.yaml`
  - `plugins/frontend/saml2_frontend.yaml`
  - `plugins/frontend/oidc_op_frontend.yaml` (optional to enable OIDC Provider)

Remember to:

* edit and customize all the values like `"CHANGE_ME!"` in the configuration files, in `proxy_conf.yaml` and in the configurations of the plugins.
* set the $HOSTNAME environment with the production DNS name
* set all key and salt with your secret key ($SATOSA_ENCRYPTION_KEY, $SATOSA_SALT)
* set a new mongodb password ($MONGODB_USERNAME, $MONGODB_PASSWORD)
* set a new certificate for SAML / SPID ($SATOSA_PUBLIC_KEYS, $SATOSA_PRIVATE_KEYS)
* add valid data for  metadata, read [Configurations by environments](#configuration-by-environment-variables)

### OIDC

This project uses [SATOSA_oidcop](https://github.com/UniversitaDellaCalabria/SATOSA-oidcop) as OAuth2/OIDC frontend module.
Comment/uncomment the following statement in the proxy_configuration to enable it.

https://github.com/italia/Satosa-Saml2Spid/blob/oidcop/example/proxy_conf.yaml#L32

### Configuration by environment variables

You can override the configuration of the proxy by settings one or more of the following environment variables:

| Environment var | description | default |
|:---|:---|:---|
|**$SATOSA_BASE**|base url of satosa server|"https://$HOSTNAME"|
|**$SATOSA_ENCRYPTION_KEY**|encription key for state|"CHANGE_ME!"|
|**$SATOSA_SALT**|encription salt|"CHANGE_ME!"|
|**$SATOSA_DISCO_SRV**|Descovery page URL for all backends|"https://$HOSTNAME/static/disco.html"|
|**$SATOSA_PRIVATE_KEY**|private key for SAML2 / SPID backends||
|**$SATOSA_PUBLIC_KEY**|public key for SAML2 / SPID backends||
|**$MONGODB_USERNAME**|MongoDB username for oidc_op frontend, default from .env file in compose-Satosa-Saml2Spid||
|**$MONGODB_PASSWORD**|MongoDB password for oidc_op frontend, default from .env file in compose-Satosa-Saml2Spid||
|**$SATOSA_UNKNOW_ERROR_REDIRECT_PAGE**|redirect page for unknow erros|"https://$HOSTNAME/static/error_page.html"|
|**$SATOSA_ORGANIZATION_DISPLAY_NAME_EN**|Metadata English organization display name||
|**$SATOSA_ORGANIZATION_NAME_EN**|Metadata English full organization name||
|**$SATOSA_ORGANIZATION_URL_EN**|Metadata English organization url||
|**$SATOSA_ORGANIZATION_DISPLAY_NAME_IT**|Metadata Italian Organization display name||
|**$SATOSA_ORGANIZATION_NAME_IT**|Metadata Italian full organization||
|**$SATOSA_ORGANIZATION_URL_IT**|Metadata Italian organization url||
|**$SATOSA_CONTACT_PERSON_GIVEN_NAME**|Metadata Contact person name||
|**$SATOSA_CONTACT_PERSON_EMAIL_ADDRESS**|Metadata Contact person email||
|**$SATOSA_CONTACT_PERSON_TELEPHONE_NUMBER**|Metadata Contact person telephone number for SPID / CIE Backend||
|**$SATOSA_CONTACT_PERSON_FISCALCODE**|Metadata Contact person fiscal code for SPID / CIE Backend||
|**$SATOSA_CONTACT_PERSON_IPA_CODE**|Metadata Contact person ipa code for SPID / CIE Backend||
|**$SATOSA_CONTACT_PERSON_MUNICIPALITY**|Metadata Contact person municipality code for CIE Backend||
|**$SATOSA_UI_DISPLAY_NAME_EN**|Metadata English ui display name||
|**$SATOSA_UI_DISPLAY_NAME_IT**|Metadata Italian ui display name||
|**$SATOSA_UI_DESCRIPTION_EN**|Metadata English ui description||
|**$SATOSA_UI_DESCRIPTION_IT**|Metadata Italian ui description||
|**$SATOSA_UI_INFORMATION_URL_EN**|Metadata English ui information URL||
|**$SATOSA_UI_INFORMATION_URL_IT**|Metadata Italian ui information URL||
|**$SATOSA_UI_PRIVACY_URL_EN**|Metadata English ui privacy URL||
|**$SATOSA_UI_PRIVACY_URL_IT**|Metadata Italian ui privacy URL||
|**$SATOSA_UI_LOGO_URL**|Metadata Logo url for||
|**$SATOSA_UI_LOGO_WIDTH**|Metadata Logo width||
|**$SATOSA_UI_LOGO_HEIGHT**|Metadata logo height||
|**$SATOSA_SAML2_REQUESTED_ATTRIBUTES**|SAML2 required attributes|name, surname|
|**$SATOSA_SPID_REQUESTED_ATTRIBUTES**|SPID required attributes|spidCode, name, familyName, fiscalNumber, email|


### Saml2 Metadata

If you want to handle metadata file manually create the `metadata/idp` and `metadata/sp` directories, then copy the required metadata:

```
mkdir -p metadata/idp metadata/sp
wget https://localhost:8080/metadata.xml -O metadata/idp/spid-saml-check.xml
wget https://registry.spid.gov.it/metadata/idp/spid-entities-idps.xml -O metadata/idp/spid-entities-idps.xml
```

Copy your SP metadata to your Proxy

```
wget https://sp.fqdn.org/saml2/metadata -O metadata/sp/my-sp.xml
```

Otherwise the best method would be enabling a MDQ server in each frontend and backend configuration file.
See `example/plugins/{backends,frontends}/$filename` as example.

## Start the Proxy

**Warning**: these examples must be intended only for test purpose, for a demo run. 
Please remember that the following examples wouldn't be intended for a real production environment.

If you need some example for a production environment please take a look at 
[example/uwsgi_setup/](example/uwsgi_setup/) directory or use the docker-compose.

```
export SATOSA_APP=$VIRTUAL_ENV/lib/$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/satosa

# only https with satosa, because its Cookie only if "secure" would be sent
uwsgi --wsgi-file $SATOSA_APP/wsgi.py  --https 0.0.0.0:10000,./pki/cert.pem,./pki/privkey.pem --callable app -b 32768

# additional static serve for the demo Discovery Service with Spid button
uwsgi --https 0.0.0.0:9999,./pki/cert.pem,./pki/privkey.pem --check-static-docroot --check-static ./static/ --static-index disco.html
```

### Get SPID backend metadata

The proxy backend exposes its SPID metadata at the following url (customizable):

```
https://localhost:10000/spidSaml2/metadata
```

### Get Proxy Fronted Metadata for your SP

The Proxy metadata must be configured in your SP. Your SP is an entity that's external from this Proxy, eg: shibboleth sp, djangosaml2, another ...

```
wget https://localhost:10000/Saml2IDP/metadata -O path/to/your/sp/metadata/satosa-spid.xml --no-check-certificate
```

Then start an authentication from your SP.

![result](gallery/screen.gif)
**Figure 2**: The result using spid-saml-check.


## Hints

If you're doing tests and you don't want to pass by Discovery page each time you can use idphinting but only if your SP support it!
Here an example using djangosaml2 as SP:

```
http://localhost:8000/saml2/login/?idp=https://localhost:10000/Saml2IDP/metadata&next=/saml2/echo_attributes&idphint=https%253A%252F%252Flocalhost%253A8080
```

IF you're going to test Satosa-Saml2Spid with spid-sp-test, take a look to
its CI, [here](.github/workflows/python-app.yml),

## Trouble shooting

That's the stdout log of a working instance of SATOSA in uwsgi

```
*** Starting uWSGI 2.0.19.1 (64bit) on [Tue Mar 30 17:08:49 2021] ***
compiled with version: 9.3.0 on 11 September 2020 23:11:42
os: Linux-5.4.0-70-generic #78-Ubuntu SMP Fri Mar 19 13:29:52 UTC 2021
nodename: wert-desktop
machine: x86_64
clock source: unix
pcre jit disabled
detected number of CPU cores: 8
current working directory: /path/to/IdentityPython/satosa_proxy
detected binary path: /path/to/IdentityPython/satosa_proxy/satosa.env/bin/uwsgi
your processes number limit is 62315
your memory page size is 4096 bytes
detected max file descriptor number: 1024
lock engine: pthread robust mutexes
uWSGI http bound on 0.0.0.0:10000 fd 4
spawned uWSGI http 1 (pid: 28676)
uwsgi socket 0 bound to TCP address 127.0.0.1:39553 (port auto-assigned) fd 3
Python version: 3.8.5 (default, Jan 27 2021, 15:41:15)  [GCC 9.3.0]
Python main interpreter initialized at 0x55f744576790
your server socket listen backlog is limited to 100 connections
your mercy for graceful operations on workers is 60 seconds
mapped 72920 bytes (71 KB) for 1 cores
*** Operational MODE: single process ***
[2021-03-30 17:08:50] [INFO ]: Running SATOSA version 7.0.1 [satosa.proxy_server.make_app:165]
[2021-03-30 17:08:50] [INFO ]: Loading backend modules... [satosa.base.__init__:42]
[2021-03-30 17:08:51] [INFO ]: Setup backends: ['Saml2', 'spidSaml2'] [satosa.plugin_loader.load_backends:49]
[2021-03-30 17:08:51] [INFO ]: Loading frontend modules... [satosa.base.__init__:45]
[2021-03-30 17:08:51] [INFO ]: Setup frontends: ['Saml2IDP'] [satosa.plugin_loader.load_frontends:70]
[2021-03-30 17:08:51] [INFO ]: Loading micro services... [satosa.base.__init__:51]
[2021-03-30 17:08:51] [INFO ]: Loaded request micro services: ['DecideBackendByTarget'] [satosa.plugin_loader.load_request_microservices:260]
[2021-03-30 17:08:51] [INFO ]: Loaded response micro services:[] [satosa.plugin_loader.load_response_microservices:281]
WSGI app 0 (mountpoint='') ready in 2 seconds on interpreter 0x55f744576790 pid: 28675 (default app)
*** uWSGI is running in multiple interpreter mode ***
spawned uWSGI worker 1 (and the only) (pid: 28675, cores: 8)
```

## Additional technical informations for Developers

#### SPID technical Requirements

The SaToSa **SPID** backend contained in this project adopt specialized forks of pySAML2 and SATOSA, that implements the following patches,
read [this](README.idpy.forks.mngmnt.md) for any further explaination about how to patch by hands.

All the patches and features are currently merged and available with the following releases:

- [pysaml2](https://github.com/peppelinux/pysaml2/tree/pplnx-v7.0.1-1)
- [SATOSA](https://github.com/peppelinux/SATOSA/tree/oidcop-v8.0.0)

#### Pending contributions to idpy

These are mandatory only for getting Spid SAML2 working, these are not needed for any other traditional SAML2 deployment:

- [disabled_weak_algs](https://github.com/IdentityPython/pysaml2/pull/628)
- [ns_prefixes](https://github.com/IdentityPython/pysaml2/pull/625)
- [SATOSA unknow error handling](https://github.com/IdentityPython/SATOSA/pull/324)
- [SATOSA redirect page on error](https://github.com/IdentityPython/SATOSA/pull/325)
- [SATOSA cookie configuration](https://github.com/IdentityPython/SATOSA/pull/363)

#### Warnings

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

## Credits

- Andrea Ranaldi and his Team @ ISPRA Ambiente
- Stefano Colagreco @ CNR
- Fulvio Scorza and his Team @ Università del Piemonte Orientale
- Paolo Smiraglia (SPID certs)
- Identity Python Community (pySAML2 and SATOSA)
- GARR IDEM Community
