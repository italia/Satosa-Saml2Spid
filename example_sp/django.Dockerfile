FROM alpine:3.18
ENV BASEDIR="/django_sp"
RUN apk update
RUN apk add --update --no-cache tzdata
RUN cp /usr/share/zoneinfo/Europe/Rome /etc/localtime
RUN echo "Europe/Rome" > /etc/timezone
RUN apk del tzdata

COPY djangosaml2_sp/requirements.txt /
 

RUN apk add --update xmlsec-dev libffi-dev openssl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash jq yq \
&& pip3 install --upgrade pip setuptools --root-user-action=ignore \
&& pip3 install virtualenv
 
RUN pip list
WORKDIR $BASEDIR/
 
RUN pip3 install -r ../requirements.txt --ignore-installed --root-user-action=ignore