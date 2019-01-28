# Satosa-saml2saml
An example configuration to deploy SATOSA SAML-to-SAML one-to-many proxy.

Work in progress (not yet usable!)


## Prepare environment
```
apt-get install -y libffi-dev libssl-dev xmlsec1
virtualenv -ppython3 satosa.env
source satosa.env/bin/activate
git clone https://github.com/IdentityPython/SATOSA.git
cd SATOSA
python3 ./setup.py install
cd ..
```

## Configure the proxy
````
mkdir -p saml2-saml2/plugins

cp SATOSA/example/{proxy_conf.yaml.example,internal_attributes.yaml.example} saml2-saml2/
cp SATOSA/example/plugins/frontends/saml2_frontend.yaml.example saml2-saml2/plugins/
cp SATOSA/example/plugins/backends/saml2_backend.yaml.example saml2-saml2/plugins/
````
