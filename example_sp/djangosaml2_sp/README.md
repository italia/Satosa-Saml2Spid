### djangosaml2-sp (SP server)
````
sudo apt install xmlsec1 python3-dev python3-pip libssl-dev
pip3 install virtualenv

virtualenv -ppython3 env
source env/bin/activate

cd djangosaml2_sp
# download idp metadata to sp, not needed if remote options is enabled
wget https://localhost:10000/Saml2IDP/metadata/ -O saml2_sp/saml2_config/satosa-saml2spid.xml --no-check-certificate

# install prerequisite
pip install -r requirements.txt

# migrate django DB
python manage.py migrate

# run the sp test
./manage.py runserver 0.0.0.0:8000
````

### Add SP metadata to Satosa server
```
# put sp metadata to satosa 
wget http://localhost:8000/saml2/metadata -O #{Satosa root}/metadata/sp/djangosaml2_sp
```
