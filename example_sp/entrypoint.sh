virtualenv -ppython3 env
source env/bin/activate
pip3 install -r ../requirements.txt --ignore-installed --root-user-action=ignore
source env/bin/activate
cd djangosaml2_sp
python -B ./manage.py runserver 0.0.0.0:8000