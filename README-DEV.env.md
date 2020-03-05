````
# as root
apt install -y python3-pip xmlsec1 sudo procps

USER_OP=wert
adduser $USER_OP
echo "$USER_OP ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

cd /opt
chown -R $USER_OP
su $$USER_OP
mkdir apps

virtualenv -ppython3 django-pysaml2.env
source django-pysaml2.env/bin/activate

git clone https://peppelinux_unical@bitbucket.org/unical-ict-dev/proxy.auth.unical.it.git tmp
mv tmp/* .

pip install git+https://github.com/peppelinux/pysaml2@pplnx-v5
pip install git+https://github.com/peppelinux/satosa@pplnx-v6

pushd django-pysaml2.env/lib/python3.7/site-packages/
rm -R saml2/
rm -R satosa
ln -s /opt/apps/satosa/src/satosa .
ln -s /opt/apps/pysaml2/src/saml2 .
popd

pip install -r apps/satosa/tests/test_requirements.txt 
pip install -r apps/pysaml2/tests/test-requirements.txt 
pip install cookies_samesite_compat
pip install uwsgi

# runs test to be sure to do the right thing 
sudo apt install -y wget gnupg
sudo wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
sudo echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt install -y mongodb-org
sudo service mongod start

pytest /opt/apps/pysaml2/tests/ -x
pytest /opt/apps/satosa/tests/ -x
# end tests

sudo mkdir -p /var/log/uwsgi/
sudo chown -R wert /var/log/uwsgi/

# server tuning
cat /opt/satosa-saml2/uwsgi_setup/server-tuning.sh > /etc/sysctl.d/server-tuning.conf

# run satosa in debug mode
uwsgi --init /opt/satosa-saml2/uwsgi_setup/uwsgi.ini.debug
````
