````
# proxy.auth.unical.it
CNT=proxyauth
lxc-create  -t download -n $CNT -- -d debian -r buster -a amd64

echo '
# Network configuration
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:80:e4:7b
lxc.net.0.ipv4.address = 10.0.3.93/24
lxc.net.0.ipv4.gateway = 10.0.3.1
' >> /var/lib/lxc/$CNT/config

# sysctl -w net.ipv4.ip_forward=1
# and iptables NAT ... if lxc-net works fine it doesn't needed

lxc-start $CNT
lxc-attach $CNT

apt update
apt install -y nginx python3-dev python3-pip libssl-dev rsync \
                lsof nano build-essential libxml2-dev libxslt1-dev \
                libyaml-dev xmlsec1 sudo procps git python3-pillow \
                libxmlsec1-dev pkg-config ldap-utils
apt clean

pip3 install virtualenv uwsgi pillow cookies_samesite_compat

VENV=idpy

virtualenv -ppython3 $VENV.env
source idpy.env/bin/activate
pip install git+https://github.com/peppelinux/pysaml2@pplnx-v5
pip install git+https://github.com/peppelinux/satosa@pplnx-v6.1.0
pip install git+https://github.com/peppelinux/pyMultiLDAP
pip install https://github.com/UniversitaDellaCalabria/SATOSA-uniExt.git

git clone https://peppelinux_unical@bitbucket.org/unical-ict-dev/proxy.auth.unical.it.git tmp
mv tmp/* .

# just for development
# mkdir apps
# git clone https://github.com/UniversitaDellaCalabria/info-manager.git apps/info-manager
# git clone https://github.com/UniversitaDellaCalabria/unicalDiscoveryService.git apps/unicalDiscoveryService
# git clone -b pplnx-v5 https://github.com/peppelinux/pysaml2 apps/pysaml2
# git clone -b pplnx-v6.1.0 https://github.com/peppelinux/satosa apps/SATOSA
# pushd django-pysaml2.env/lib/python3.7/site-packages/
# rm -R saml2/
# rm -R satosa
# ln -s /opt/apps/satosa/src/satosa .
# ln -s /opt/apps/pysaml2/src/saml2 .
# popd

pip install -r satosa-saml2/requirements.txt 
pip install -r unicalDS/requirements.txt 
pip install -r pyff/requirements.txt
pip install -r django_mdq/requirements.txt

# these as root ...
# rsync -prozE --progress wert@proxy.auth.unical.it:/etc/ssl/* /etc/ssl
# rsync -prozE --progress wert@proxy.auth.unical.it:/etc/nginx/* /etc/nginx

#pushd /etc
#tar xzvfp /opt/*tar.gz
#popd

USER=wert
adduser --disabled-password --gecos "" $USER
mkdir /home/$USER
chown wert /home/$USER/
cd /opt
chown -R $USER /opt

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
