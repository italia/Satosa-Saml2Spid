## Start a local Satosa-saml2spid istance with a SystemD Service

In this example is provided with this assumption:
* Satosa-saml2spid is installed in `/opt/satosa`
* Satosa-saml2spid is executed from a Python VirtualENV sited in `/opt/satosa/env`
* Satosa-saml2spid is executed from `satosa` user

Create a new SystemD service with the command:
```
sudo systemctl edit --force --full satosa.service
```

copy and personalize this service example:
```
Description=UWSGI server for Satosa Proxy

## Socket
# After=syslog.target
# Requires=satosa.sock
## Network
Requires=network.target
After=network.target

[Service]
# Foreground process
Type=simple

# Preferably configure a non-privileged user
User=satosa
Group=satosa
WorkingDirectory=/opt/satosa
ExecStart=/bin/bash -c 'cd /opt/satosa && source env/bin/activate && uwsgi --ini ./uwsgi_setup/uwsgi.ini --thunder-lock'
Restart=always
KillSignal=SIGQUIT

## socket
# [Install]
# WantedBy=sockets.target
```
Enable the service:
```
sudo systemctl enable satosa.service
```

### Satosa with socket
If you want enable Satosa-saml2spid by socket  you should edit the service:
```
sudo systemctl edit --full satosa.service
```
uncomment follow line:
* `After=syslog.target`
* `Requires=satosa.sock`
* `[Install]`
* `WantedBy=sockets.target`

create the socket target:
```
sudo systemctl edit --full --force satosa.sockets
```

Copy and personalize this socket example:
```
[Unit]
Description=Socket for satosa

[Socket]
# Change this to your uwsgi application port or unix socket location
ListenStream=/opt/satosa//tmp/sockets/satosa.sock
SocketMode=0770

[Install]
WantedBy=sockets.target
```

enable il socket:
```
sudo systectl enable satosa.socket
```
