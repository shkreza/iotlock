#!/bin/bash

#wget http://node-arm.herokuapp.com/node_latest_armhf.deb
#sudo dpkg -i node_latest_armhf.deb

USER=pi

BASE_PATH=$(dirname $0)
BASE_PATH=$(cd $BASE_PATH; pwd)
SERVICE_NAME="lock-device"
SERVICE_FILE_SRC=$BASE_PATH/$SERVICE_NAME.service
SERVICE_FILE_DST=/etc/systemd/system/$SERVICE_NAME.service

APPLICATION_FILE_DIR=$BASE_PATH
APPLICATION_FILE_SRC="$APPLICATION_FILE_DIR/lock-app.sh"

if [ ! -f $SERVICE_FILE_SRC ]; then
	echo "Missing service file at path: $SERVICE_FILE_SRC";
	exit 1;
fi

if [ ! -f $APPLICATION_FILE_SRC ]; then
	echo "Missing service executable file at path: $APPLICATION_FILE_SRC";
	exit 1;
fi

cp $SERVICE_FILE_SRC $SERVICE_FILE_DST
APPLICATION_FILE_DIR_SECURE=$(echo $APPLICATION_FILE_DIR | sed 's_/_\\/_g')
APPLICATION_FILE_SRC_SECURE=$(echo $APPLICATION_FILE_SRC | sed 's_/_\\/_g')
sed -e "s/APPLICATION_EXECUTABLE/$APPLICATION_FILE_SRC_SECURE/" -e "s/WORKING_DIRECTORY/$APPLICATION_FILE_DIR_SECURE/" -e "s/USER/$USER/" $SERVICE_FILE_SRC > $SERVICE_FILE_DST

systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME
systemctl status $SERVICE_NAME
