FROM debian:buster-slim
MAINTAINER Giuseppe De Marco <demarcog83@gmail.com>

#RUN apk update
#RUN apk add xmlsec libffi-dev libressl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash cargo musl-dev
RUN apt update
RUN apt install -y libffi-dev libssl-dev python3-pip xmlsec1 procps libpcre3 libpcre3-dev git bash

ENV BASEDIR="/satosa_proxy"
COPY ./requirements.txt $BASEDIR/

WORKDIR $BASEDIR/
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt --ignore-installed

COPY ./project $BASEDIR
RUN ls .
CMD uwsgi --wsgi satosa.wsgi --https 0.0.0.0:10000,$BASEDIR/pki/cert.pem,$BASEDIR/pki/privkey.pem --callable app -b 32648
