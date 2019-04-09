# Satosa-saml2saml
An example configuration to deploy SATOSA SAML-to-SAML one-to-many proxy.

## Work in progress (not yet usable!)

## Prepare environment
```
apt install -y libffi-dev libssl-dev xmlsec1
virtualenv -ppython3 satosa.env
source satosa.env/bin/activate
git clone https://github.com/IdentityPython/SATOSA.git
cd SATOSA
python3 ./setup.py install
cd ..
```

## Copy required files
````
export DESTDIR="saml2-saml2"
mkdir -p $DESTDIR/plugins

cp SATOSA/example/{proxy_conf.yaml.example,internal_attributes.yaml.example} $DESTDIR/
````

#### Plugins
The authentication protocol specific communication is handled by different plugins, divided into frontends (receiving requests from clients) and backends (sending requests to target providers).
````
cp SATOSA/example/plugins/frontends/saml2_frontend.yaml.example $DESTDIR/plugins/
cp SATOSA/example/plugins/backends/saml2_backend.yaml.example $DESTDIR/plugins/
````

## Create Frontend and Backend certificates
````
export FQDN="satosa.testunical.it"
openssl req -nodes -new -x509 -days 3650 -keyout frontend.key -out frontend.cert -subj '/CN=$FQDN'
openssl req -nodes -new -x509 -days 3650 -keyout backend.key -out backend.cert -subj '/CN=$FQDN'
````

## Get SPs and IDPs metadata
for example
````
wget http://sp1.testunical.it:8000/saml2/metadata -O metadata/sp1.xml
wget http://idp1.testunical.it:9000/idp/metadata -O metadata/idp1.xml
````

## Configure the proxy
Edit alle the *.yaml.example files according to [official Documentation](https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#configuration), renaming them without .example suffix.

#### proxy_conf.yaml
[Documentation](https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#satosa-proxy-configuration-proxy_confyamlexample)
Variables that must be edited:
````
BASE: https://a fully qualified domain name
INTERNAL_ATTRIBUTES: file with mapping, see next paragraph.
COOKIE_STATE_NAME: custom or default name, change it for disabling server fingerpint!
STATE_ENCRYPTION_KEY: alphadecimal secret, change it for security!
````

#### internal_attributes.yaml
A list of external attributes names which should be mapped to the internal attributes.

## Run

Produce metadata
````
satosa-saml-metadata proxy_conf.yaml ./pki/backend.key ./pki/backend.cert

Writing metadata to './frontend.xml'
Writing metadata to './backend.xml'
````

Run
````
gunicorn -b0.0.0.0:10000 satosa.wsgi:app --keyfile=./pki/frontend.key --certfile=./pki/frontend.cert
````

Give Metadata to your endpoints, SP and IDP.

## Use case
https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#frontend

## References

- https://github.com/IdentityPython/SATOSA
- [IDP/SP Discovery service](https://medium.com/@sagarag/reloading-saml-idp-discovery-693b6bff45f0) 
