#!/bin/bash
SOURCE_DIR=/home/node/app/
MOUNTED_DIR=/home/node/exposed-app/
MOUNTED_APP_DIR=/home/node/exposed-app/PorMiBarrioAPPs

# Checks if a folder mounted from host is found (hardcoded folder name)
# If it's found the app is going to run from that persistent folder (exposed to the host for develpment)
# If not found then the app is going to run from non-persistent folder (not exposed to the host)
if test -d "$MOUNTED_DIR"; then
	echo "Mounted directory found: executing from mounted dir."
	if ! test -d "$MOUNTED_APP_DIR"; then
		# If the app's code is not found it is copied into the mounted folder
		echo "Source code not found on mounted folder: copying contents."
		cp -R $SOURCE_DIR/* $MOUNTED_DIR/
	fi
	cd $MOUNTED_APP_DIR
else
	# If mounted folder is not found then it's going to execute from local non-persistent folder
	cd $SOURCE_DIR/PorMiBarrioAPPs
	echo "Mounted directory not found: executing from local dir."
fi
ionic serve