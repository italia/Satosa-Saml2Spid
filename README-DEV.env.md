````
apt install python3-pip xmlsec1

cd /opt
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

````
