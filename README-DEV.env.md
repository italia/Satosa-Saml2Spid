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

pip install git+https://github.com/peppelinux/pysaml2@pplnx-v6.5.0
pip install git+https://github.com/peppelinux/satosa@pplnx-v7.0.1

git clone -b pplnx-v6.5.0 https://github.com/peppelinux/pysaml2 apps/pysaml2
git clone -b pplnx-v7.0.1 https://github.com/peppelinux/satosa apps/satosa
git clone https://github.com/UniversitaDellaCalabria/info-manager.git apps/info-manager
git clone https://github.com/UniversitaDellaCalabria/unicalDiscoveryService.git apps/unicalDiscoveryService

sudo apt install python3-pillow # gets dependencies
pip install pillow

pushd django-pysaml2.env/lib/python3.7/site-packages/
rm -R saml2/
rm -R satosa
ln -s /opt/apps/satosa/src/satosa .
ln -s /opt/apps/satosa/src/SATOSA
ln -s /opt/apps/pysaml2/src/saml2 .
popd

pip install -r satosa-saml2/requirements.txt 
pip install -r apps/satosa/tests/test_requirements.txt 
pip install -r apps/pysaml2/tests/test-requirements.txt 
pip install cookies_samesite_compat
pip install uwsgi

# runs test to be sure to do the right thing 
sudo apt install -y wget gnupg
sudo wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
sudo echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt update
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
uwsgi --ini /opt/satosa-saml2/uwsgi_setup/uwsgi.ini.debug

# run unicalDS

# run pyff
sudo apt install build-essential python3-dev libxml2-dev libxslt1-dev libyaml-dev python3-pip
pushd pyff
pip install git+https://github.com/IdentityPython/pyFF.git
pyff --loglevel=DEBUG pipelines/md.fd
popd

# run Django-MDQ
sudo apt -y install libxmlsec1-dev pkg-config
pip install -r django_mdq/requirements.txt

# UnicalDS here...
pip install -r unicalDS/requirements.txt  

# these as root ...
# rsync -prozE --progress wert@proxy.fqdn:/etc/ssl/* /etc/ssl
# rsync -prozE --progress wert@proxy.fqdn:/etc/nginx/* /etc/nginx

cat /opt/satosa-saml2/uwsgi_setup/satosa_init > /etc/init.d/satosa_saml2
chmod 744 /etc/init.d/satosa_saml2
update-rc.d satosa_saml2 defaults
update-rc.d satosa_saml2 enable

cat /opt/unicalDS/uwsgi_setup/django_init     > /etc/init.d/unicalDS
chmod 744 /etc/init.d/unicalDS
update-rc.d unicalDS defaults
update-rc.d unicalDS enable

cat /opt/django_mdq/uwsgi_setup/django_init   > /etc/init.d/django_mdq 
chmod 744 /etc/init.d/django_mdq
update-rc.d django_mdq defaults
update-rc.d django_mdq enable

mkdir /var/log/uwsgi
chown -R wert /var/log/uwsgi

sysctl -w net.core.somaxconn=10000
echo "net.core.somaxconn=10000" >> /etc/sysctl.conf


````
