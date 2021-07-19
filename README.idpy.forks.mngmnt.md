# PySAML2

````
git clone -b pplnx-v5 https://github.com/peppelinux/pysaml2
cd pysaml2/

# create current idpy master
git checkout --orphan idpy-v6.5.1
git remote add idpy https://github.com/IdentityPython/pysaml2.git
git reset --hard
git pull idpy master

# create current pplnx branch to be updated and tested
git checkout --orphan pplnx-v6.5.1
git reset --hard
git pull idpy master

# pplnx's patches
# https://github.com/IdentityPython/pysaml2/pull/602/files
# SPID requirements
git pull origin date_xsd_type

# https://github.com/IdentityPython/pysaml2/pull/628
# SPID required
git pull origin disabled_weak_algs

# https://github.com/IdentityPython/pysaml2/pull/625
# this must be merged at the end, otherwise break the unit tests
git pull origin ns_prefixes
````

If `ns_prefixes` still conflicts, mind these two lines (#15 #16):
````
TMPL_NO_HEADER = """<xenc:EncryptedData xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xenc="http://www.w3.org/2001/04/xmlenc#" Id="{ed_id}" Type="http://www.w3.org/2001/04/xmlenc#Element"><xenc:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#tripledes-cbc" /><ds:KeyInfo><xenc:EncryptedKey Id="{ek_id}"><xenc:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p" /><ds:KeyInfo><ds:KeyName>my-rsa-key</ds:KeyName></ds:KeyInfo><xenc:CipherData><xenc:CipherValue /></xenc:CipherData></xenc:EncryptedKey></ds:KeyInfo><xenc:CipherData><xenc:CipherValue /></xenc:CipherData></xenc:EncryptedData>"""
TMPL = "<?xml version='1.0' encoding='UTF-8'?>\n%s" % TMPL_NO_HEADER
````
# SATOSA

````
git clone https://github.com/peppelinux/satosa
cd SATOSA
git remote add idpy https://github.com/IdentityPython/SATOSA.git
git checkout --orphan idpy-v7.0.1
git reset --hard
git pull idpy master

pip install -r tests/test_requirements.txt

# install mongodb first!
apt install -y gnupg wget
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt update
apt install -y mongodb-org
systemctl start mongod

# check that tests are ok
py.test tests/ -x

# https://github.com/IdentityPython/SATOSA/pull/363
git pull origin cookie_conf_2

# https://github.com/IdentityPython/SATOSA/pull/324
git pull origin context_state_error_msg

# https://github.com/IdentityPython/SATOSA/pull/325
git pull origin error_redirect_page
````
