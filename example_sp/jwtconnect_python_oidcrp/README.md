Start the Relying-Party
-----------------------

Clone and install [JWTConnect-Python-OidcRP](https://github.com/identitypython/JWTConnect-Python-OidcRP) as follow:
```
git clone https://github.com/IdentityPython/JWTConnect-Python-OidcRP.git
cd JWTConnect-Python-OidcRP

# create a virtualenv to avoid installing it systemwide
virtualenv -ppython3 env
source env/bin/activate

# install it in the current environment
pip install -e .

# then install flask
pip install flask

# enter in the example folder
cd example

python3 -m flask_rp.wsgi ../../Satosa-saml2saml/example_sp/jwtconnect_python_oidcrp/satosa.json
````

You should see an output like this
````
2023-02-23 22:06:15,893 root DEBUG Configured logging using dictionary
 * Serving Flask app 'oidc_rp'
 * Debug mode: on
2023-02-23 22:06:15,929 werkzeug INFO WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on https://localhost:8090
2023-02-23 22:06:15,929 werkzeug INFO Press CTRL+C to quit
2023-02-23 22:06:15,930 werkzeug INFO  * Restarting with stat
2023-02-23 22:06:16,093 root DEBUG Configured logging using dictionary
2023-02-23 22:06:16,129 werkzeug WARNING  * Debugger is active!
2023-02-23 22:06:16,129 werkzeug INFO  * Debugger PIN: 113-267-765

````

then go to `https://127.0.0.1:8090`
