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
COPY requirements.txt $BASEDIR/
COPY oids.conf $BASEDIR/pki/
COPY build_spid_certs.sh $BASEDIR/pki/

RUN apk add --update xmlsec libffi-dev libressl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash jq \
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

# Metadata params
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL="https://github.com/IDEM-GARR-AAI/Satosa-Saml2Spid.git"
ARG VCS_REF

# Metadata
LABEL   org.label-schema.name="Satosa-Saml2Spid" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION \
        org.label-schema.vcs-url=$VCS_URL \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.description="Docker Image di Satosa-Saml2Spid."
