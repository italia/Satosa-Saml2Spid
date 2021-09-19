FROM debian:buster-slim
MAINTAINER Giuseppe De Marco <demarcog83@gmail.com>

RUN apt update
RUN apt install -y libffi-dev libssl-dev python3-pip libpcre3 libpcre3-dev

RUN pip3 install uwsgi
ENV BASEDIR=/satosa_statics/
WORKDIR $BASEDIR
ENTRYPOINT uwsgi --uid 1000 --https 0.0.0.0:9999,/satosa_pki/cert.pem,/satosa_pki/privkey.pem --check-static-docroot --check-static $BASEDIR --static-index disco.html
