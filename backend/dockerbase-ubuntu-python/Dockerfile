FROM ubuntu:xenial
LABEL maintainer="reza.sherafat@gmail.com"

RUN apt-get upgrade
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
# RUN apt-get install -y libboost-all-dev

RUN pip3 install azure-iothub-service-client
RUN pip3 install azure-iothub-device-client
RUN pip3 install jupyter

RUN apt-get install -y libboost-all-dev
RUN apt-get install -y curl libcurl3

EXPOSE 8888