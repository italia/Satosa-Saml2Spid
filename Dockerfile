FROM alpine:3.18

ENV BASEDIR="/satosa_proxy"
RUN apk update
RUN apk add --update --no-cache tzdata \
 && cp /usr/share/zoneinfo/Europe/Rome /etc/localtime \
 && echo "Europe/Rome" > /etc/timezone \
 && apk del tzdata

COPY example/ $BASEDIR/
COPY requirements.txt $BASEDIR/

RUN apk add --update xmlsec libffi-dev openssl-dev python3 py3-pip python3-dev procps git openssl build-base gcc wget bash jq \
&& cd $BASEDIR/ \
&& pip3 install --upgrade pip --root-user-action=ignore \
&& pip3 install yq --root-user-action=ignore \
&& pip3 install -r requirements.txt --ignore-installed --root-user-action=ignore \
&& adduser --disabled-password satosa \
&& chown -R  satosa . \
&& chmod +x run.sh

USER satosa
WORKDIR $BASEDIR/
# CMD bash run.sh

# Metadata params
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL="https://github.com/italia/Satosa-Saml2Spid.git"
ARG VCS_REF
ARG AUTHORS
ARG VENDOR

# Metadata : https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors=$AUTHORS \
      org.opencontainers.image.vendor=$VENDOR \
      org.opencontainers.image.title="Satosa-Saml2Spid" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.source=$VCS_URL \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.description="Docker Image di Satosa-Saml2Spid."
