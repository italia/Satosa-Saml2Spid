FROM debian:buster-slim
MAINTAINER Giuseppe De Marco <demarcog83@gmail.com>

RUN apt update
RUN apt install -y libffi-dev libssl-dev python3-pip libpcre3 libpcre3-dev

ENV BASEDIR="/satosa_proxy"
WORKDIR $BASEDIR/

COPY ./project/static $BASEDIR/static
COPY ./project/pki $BASEDIR/pki

RUN pip3 install uwsgi

RUN ls ./pki -l
RUN cat $BASEDIR/pki/cert.pem
ENTRYPOINT uwsgi --uid 1000 --https 0.0.0.0:9999,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --check-static-docroot --check-static $BASEDIR/static/ --static-index disco.html
