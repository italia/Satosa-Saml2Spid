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

## Copy required files
````
export DESTDIR="saml2-saml2"
mkdir -p $DESTDIR/plugins

cp SATOSA/example/{proxy_conf.yaml.example,internal_attributes.yaml.example} $DESTDIR/
cp SATOSA/example/plugins/frontends/saml2_frontend.yaml.example $DESTDIR/plugins/
cp SATOSA/example/plugins/backends/saml2_backend.yaml.example $DESTDIR/plugins/
````

## Configure the proxy
Edit alle the *.yaml.example files according to [official Documentation](https://github.com/IdentityPython/SATOSA/blob/master/doc/README.md#configuration), renaming them without .example suffix.

#### proxy_conf.yaml
Variables that must be edited:
````
BASE: https://a fully qualified domain name
INTERNAL_ATTRIBUTES: file with mapping, see next paragraph.
COOKIE_STATE_NAME: custom or default name, change it for disabling server fingerpint!
STATE_ENCRYPTION_KEY: alphadecimal secret, change it for security!
````

#### internal_attributes.yaml
A list of external attributes names which should be mapped to the internal attributes.

## References

- https://github.com/IdentityPython/SATOSA
- [IDP/SP Discovery service](https://medium.com/@sagarag/reloading-saml-idp-discovery-693b6bff45f0)
