FROM python
LABEL maintainer="reza.sherafat@gmail.com"

WORKDIR /dockerbase

RUN apt-get update

ADD requirements.txt .
RUN pip3 install -r requirements.txt

ENV CERTBOT /bin/certbot-auto
ADD https://dl.eff.org/certbot-auto $CERTBOT
RUN chmod +x $CERTBOT