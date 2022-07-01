FROM alpine:3.13.5

ENV BASEDIR="/satosa_proxy"

ENV COMMON_NAME="SPID example proxy"
ENV LOCALITY_NAME="Roma"
ENV ORGANIZATION_IDENTIFIER="PA:IT-c_h501"
ENV ORGANIZATION_NAME="SPID example proxy"
ENV SERIAL_NUMBER="1234567890"
ENV SPID_SECTOR="public"
ENV URI="https://spid.proxy.example.org"
ENV DAYS="7300"

ENV SATOSA_DISCO_SRV="https://localhost:9999/disco.html"

RUN apk add --update --no-cache tzdata \
 && cp /usr/share/zoneinfo/Europe/Rome /etc/localtime \
 && echo "Europe/Rome" > /etc/timezone \
 && apk del tzdata

COPY example/ $BASEDIR/
COPY files/* /root/

RUN apk add --update xmlsec libffi-dev libressl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash jq \
&& mv /root/requirements.txt $BASEDIR/ \
&& mv /root/oids.conf $BASEDIR/pki/ \
&& mv /root/build_spid_certs.sh $BASEDIR/pki/ \
&& cd $BASEDIR/pki/ \
&& chmod 755 $BASEDIR/pki/build_spid_certs.sh \
&& $BASEDIR/pki/build_spid_certs.sh \
&& cd $BASEDIR/ \
&& pip3 install --upgrade pip \
&& pip3 install yq \
&& pip3 install -r requirements.txt --ignore-installed \
&& wget https://registry.spid.gov.it/metadata/idp/spid-entities-idps.xml -O metadata/idp/spid-entities-idps.xml \
&& adduser --disabled-password wert \
&& chown -R  wert . \
&& chmod +x run.sh

USER wert

WORKDIR $BASEDIR/

CMD bash run.sh
