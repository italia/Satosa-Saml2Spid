# PySAML2

````
git clone https://github.com/identitypython/pysaml2
cd pysaml2/

# create current pplnx branch
git checkout --orphan pplnx-v7.0.1+
git remote add pplnx https://github.com/peppelinux/pysaml2.git
git reset --hard
git pull origin master

# pplnx's patches
# https://github.com/IdentityPython/pysaml2/pull/602/files
# SPID requirements
git pull pplnx date_xsd_type

# https://github.com/IdentityPython/pysaml2/pull/628
# SPID required
git pull pplnx disabled_weak_algs

# https://github.com/IdentityPython/pysaml2/pull/625
# this must be merged at the end, otherwise break the unit tests
git pull pplnx ns_prefixes
````

If `ns_prefixes` still conflicts, mind these two lines (#15 #16):
````
TMPL_NO_HEADER = """<xenc:EncryptedData xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xenc="http://www.w3.org/2001/04/xmlenc#" Id="{ed_id}" Type="http://www.w3.org/2001/04/xmlenc#Element"><xenc:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#tripledes-cbc" /><ds:KeyInfo><xenc:EncryptedKey Id="{ek_id}"><xenc:EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p" />{key_info}<xenc:CipherData><xenc:CipherValue /></xenc:CipherData></xenc:EncryptedKey></ds:KeyInfo><xenc:CipherData><xenc:CipherValue /></xenc:CipherData></xenc:EncryptedData>"""
TMPL = f"<?xml version='1.0' encoding='UTF-8'?>\n{TMPL_NO_HEADER}"
````
# SATOSA

````
git clone https://github.com/identitypython/satosa
cd SATOSA
git remote add pplnx https://github.com/peppelinux/SATOSA.git
git checkout --orphan pplnx-v8.0.0
git reset --hard
git pull origin master

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
git pull pplnx cookie_conf_2

# https://github.com/IdentityPython/SATOSA/pull/324
git pull pplnx context_state_error_msg

# https://github.com/IdentityPython/SATOSA/pull/325
git pull pplnx error_redirect_page
````
