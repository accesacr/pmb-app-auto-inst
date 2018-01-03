#!/bin/bash
CONTAINED_APP_FOLDER=contained-app-folder

if ! test -d "$CONTAINED_APP_FOLDER"; then
	echo "The '$CONTAINED_APP_FOLDER' was not found: creating empty folder"
	mkdir $CONTAINED_APP_FOLDER
fi
docker-compose -f docker-compose-for-dev.yml up