# Satosa-Saml2Spid

This is a SAML2  configuration for [SATOSA](https://github.com/IdentityPython/SATOSA)
that aims to setup a **SAML-to-SAML Proxy** compatible with the  **SPID - the Italian Digital Identity System**.

## Table of Contents
1. [Goal](#goal)
2. [Demo components](#demo-components)
3. [Docker image](#docker-image)
4. [Setup](#setup)
5. [Start the Proxy](#start-the-proxy)
6. [Additional technical informations](#additional-technical-informations)
7. [Author](#author)
8. [Credits](#credits)


## Goal

Satosa-Saml2 Spid is an intermediary between many SAML2 Service Providers and many SAML2 Identity Providers. 
Specifically it allows traditional Saml2 Service Providers to communicate with 
**Spid Identity Providers** adapting Metadata and AuthnRequest operations to the Spid technical requirements.

![big picture](gallery/spid_proxy.png)

**Figure1** : _Common scenario, a traditional SAML2 Service Provider (SP) that's proxied through the SATOSA SPID Backend gets compliances on AuthnRequest and Metadata operations_.

More generally this solution allows us to adopt multiple proxy _frontends_ and _backends_ 
to adapt and allows to communicate systems that, due to protocol or specific 
limitations, traditionally could not interact each other.

**Short glossary**

- **Frontend**, interface of the proxy that is configured as a SAML2 Identity Provider
- **Backend**, interface of the proxy that is configured as a SAML2 Service Provider
- **TargetRouting**, a SATOSA microservice for selecting the output backend to reach the endpoint (IdP) selected by the user
- **Discovery Service**, interface that allows users to select the authentication endpoint


## Demo components

The example project comes with the following demo pages, served
with the help of an additional webserver dedicated for static contents:


#### Discovery Service page
![disco](gallery/disco.png)


#### Error page
![disco](gallery/error_page.png)


You can find these demo pages in `example/static` and edit at your taste.
To get redirection to these pages, or redirection to third-party services, consider the following configuration files:

- `example/proxy_conf.yml`, example: `UNKNOW_ERROR_REDIRECT_PAGE: "http://localhost:9999/error_page.html"`
- `example/plugins/{backends,frontends}/$filename`, example: `disco_srv: "http://172.17.0.1:9999/static/disco.html"`


## Docker image

You should [customize the configuration](https://github.com/peppelinux/Satosa-Saml2Spid#configure-the-proxy) before creating a Docker image, if you want to 
run a demo anyway, you can use the example project as well with some compromise. Start your demo SP and your 
demo IdP (Example IdPs: [spid-saml-check](https://github.com/italia/spid-saml-check) or [spid-test-env2](https://github.com/italia/spid-testenv2)) then
use their **metadata URLs** in the build command, as follow:

````
docker image build --tag saml2spid . --build-arg SP_METADATA_URL="http://172.17.0.1:8000/saml2/metadata" --build-arg IDP_METADATA_URL="http://172.17.0.1:8080/metadata.xml"
docker run -t -i -p 10000:10000 -p 9999:9999 saml2spid
````

Copy proxy frontend metadata to your SP: 
````
wget https://localhost:10000/Saml2IDP/metadata -O saml2_sp/saml2_config/satosa-spid.xml --no-check-certificate
````

Copy proxy backend metadata to your IdPs:
````
https://localhost:10000/spidSaml2/metadata
https://localhost:10000/Saml2/metadata
````

Enter in the container for inspection ... it could be useful
````
docker exec -it $(docker container ls | grep saml2spid | awk -F' ' {'print $1'}) /bin/sh
````


## Setup

###### Prepare environment
````
mkdir satosa_proxy && cd satosa_proxy
virtualenv -ppython3 satosa.env
source satosa.env/bin/activate
````

###### Dependencies
````
sudo apt install -y libffi-dev libssl-dev xmlsec1 python3-pip xmlsec1 procps

git clone https://github.com/peppelinux/Satosa-Saml2Spid.git repository
pip install -r repository/requirements.txt
````

## Configure the Proxy

Create certificates for SAML2 operations, thanks to [psmiraglia](https://github.com/psmiraglia/spid-compliant-certificates).
````
export WD="pki/"

mkdir $WD && cd $WD
cp ../repository/oids.conf .
cp ../repository/build_spid_certs.sh .

# create your values inline 
cat > my.env <<EOF
export COMMON_NAME="SPID example proxy"
export LOCALITY_NAME="Roma"
export ORGANIZATION_IDENTIFIER="PA:IT-c_h501"
export ORGANIZATION_NAME="SPID example proxy"
export SERIAL_NUMBER="1234567890"
export SPID_SECTOR="public"
export URI="https://spid.proxy.example.org"
export DAYS="7300"
EOF

. my.env

bash build_spid_certs.sh
cd ..
````

Copy `repository/example/*` contents (`cp -R repository/example/* .`) and **edit the following files** with your preferred configuration.
These are the configuration files:

- `example/proxy_conf.yaml`
- `example/plugins/backends/spidsaml2_backend.yaml`
- `example/plugins/backends/saml2_backend.yaml`
- `example/plugins/frontend/saml2_frontend.yaml`


## Handling Metadata

If you want to handle metadata file manually, as this example purpose as demostration, 
create `metadata/idp` and `metadata/sp` folders, then copy metadata:

````
wget http://localhost:8080/metadata.xml -O metadata/idp/spid-saml-check.xml
wget https://registry.spid.gov.it/metadata/idp/spid-entities-idps.xml -O metadata/idp/spid-entities-idps.xml
````

Copy your SP metadata to your Proxy
````
wget https://sp.fqdn.org/saml2/metadata -O metadata/sp/my-sp.xml
````

Otherwise the best method would be enabling a MDQ server in each frontend and backend configuration file.
See `example/plugins/{backends,frontends}/$filename` as example.


## Start the Proxy

**Warning**: these examples must be intended only for test purpose, for a demo run. Please remember that the following examples wouldn't be intended for a real production environment! If you need some example for a production environment please take a look at `example/uwsgi_setup/` folder.

````
export SATOSA_APP=$VIRTUAL_ENV/lib/$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/satosa

# only https with satosa, because its Cookie only if "secure" would be sent
uwsgi --wsgi-file $SATOSA_APP/wsgi.py  --https 0.0.0.0:10000,./pki/cert.pem,./pki/privkey.pem --callable app

# additional static serve for the demo Discovery Service with Spid button
uwsgi --http 0.0.0.0:9999 --check-static-docroot --check-static ./static/ --static-index disco.html
````

#### Get Proxy Metadata for your SP

The Proxy metadata must be configured in your SP. Your SP is an entity that's external from this Proxy, eg: shibboleth sp, djangosaml2, another ...
````
wget https://localhost:10000/Saml2IDP/metadata -O path/to/your/sp/metadata/satosa-spid.xml --no-check-certificate
````

Then start an authentication from your SP.

![result](gallery/screen.gif)
**Figure 2**: The result using spid-saml-check.


## Additional technical informations

#### Spid Requirements

The SaToSa **SPID** backend contained in this project works if the following patches will be used, 
read [this](README.idpy.forks.mngmnt.md) for any further explaination about how to patch by hands.

You can get all those patches and features merged in the following forks:
- [pysaml2](https://github.com/peppelinux/pysaml2/tree/pplnx-v6.5.0)
- [SATOSA](https://github.com/peppelinux/SATOSA/tree/pplnx-v7.0.1)


#### Pending contributions to idpy

These are mandatory only for getting Spid SAML2 working, these are not needed for any other traditional SAML2 deployment:

- [Micro Service - Decide backend by target entity ID](https://github.com/IdentityPython/SATOSA/pull/220)
  This is a work in progress that works as it is!
- [date_xsd_type](https://github.com/IdentityPython/pysaml2/pull/602/files)
- [disabled_weak_algs](https://github.com/IdentityPython/pysaml2/pull/628)
- [ns_prefixes](https://github.com/IdentityPython/pysaml2/pull/625)
- [SATOSA unknow error handling](https://github.com/IdentityPython/SATOSA/pull/324)
- [SATOSA redirect page on error](https://github.com/IdentityPython/SATOSA/pull/325)


#### Warnings
Here something that you should know before start.

- You must enable more than a single IdP (multiple metadata or single metadata with multiple entities) to get *Discovery Service* working.
- Proxy doesn't handle SAML2 SLO, so the spidSaml2 backend is configured with Authnforce -> True. For any further information see [Single Logout in Satosa](https://github.com/IdentityPython/SATOSA/issues/211).
- SATOSA Saml2 backend configuration have a **policy** section that will let us to define specialized behaviours
  and configuration for each SP (each by entityid). In this example I defined a single "default" behaviour with attributes **name_format** 
  to **urn:oasis:names:tc:SAML:2.0:attrname-format:uri**, due to my needs to handle many service providers for which it could be painfull do a static definition each time.
  An additional "hack" have been made in `example/attributes-maps/satosa_spid_uri_hybrid.py`, where I adopted a hybrid mapping that works for 
  both *URI* and *BASIC* formats. Feel free to customized or decouple these format in different files and per SP.


## References

SATOSA Official Documentation is available at the following links, make sure you've taken a 
look to these to understand the potential of this platform:
- [SaToSa Saml2Saml Documentation](https://github.com/IdentityPython/SATOSA/blob/master/doc/one-to-many.md)
- [Use cases](https://github.com/IdentityPython/SATOSA/wiki#use-cases)

Additional resources:

- [SaToSa training aarc project](https://aarc-project.eu/wp-content/uploads/2019/03/SaToSa_Training.pdf)
- [IDP/SP Discovery service](https://medium.com/@sagarag/reloading-saml-idp-discovery-693b6bff45f0)
- https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#frontend
- [saml2.0 IdP and SP for tests](https://samltest.id/)
- https://www.spid.gov.it/assets/download/SPID_QAD.pdf

## Author

Giuseppe De Marco


## Credits

- Paolo Smiraglia (SPID certs)
- idpy Community  (pySAML2 and SATOSA)
