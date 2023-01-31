# PySAML2

````
git clone https://github.com/identitypython/pysaml2
cd pysaml2/

# create current pplnx branch
git checkout --orphan pplnx-v7.2.1
git remote add pplnx https://github.com/peppelinux/pysaml2.git
git reset --hard
git pull origin master

# pplnx's patches

# https://github.com/IdentityPython/pysaml2/pull/628
# SPID required
git pull pplnx disabled_weak_algs

# https://github.com/IdentityPython/pysaml2/pull/625
# this must be merged at the end, otherwise break the unit tests
git pull pplnx ns_prefixes
````

# SATOSA

````
git clone https://github.com/identitypython/satosa
cd SATOSA
git remote add pplnx https://github.com/peppelinux/SATOSA.git
git checkout --orphan pplnx-v8.2.0
git reset --hard
git pull origin master

pip install -r tests/test_requirements.txt
pip install pymongo

# install mongodb first!
sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt update

# workaround for ubuntu 22.04
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb

sudo apt install -y mongodb-org
sudo systemctl start mongod

# check that tests are ok
python3 -m pytest tests/ -x

# https://github.com/IdentityPython/SATOSA/pull/363
git pull pplnx cookie_conf_2

# https://github.com/IdentityPython/SATOSA/pull/324
git pull pplnx context_state_error_msg

# https://github.com/IdentityPython/SATOSA/pull/325
git pull pplnx error_redirect_page
````
