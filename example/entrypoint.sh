#!/bin/bash

bash apply_conf.sh

uwsgi --ini /satosa_proxy/uwsgi_setup/uwsgi/uwsgi.ini.docker
