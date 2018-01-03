# Select node.js as the base image and pull image from hub.docker.com (docker's public registry).
FROM node

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential git

# Get app's source code
RUN mkdir -p /home/node/app
COPY . /home/node/app

# This folder if it exists should be removed
RUN if test -d "/home/node/app/contained-app-folder"; \
	then rm -R /home/node/app/contained-app-folder; fi
# If the copy didn't brought the source code, download the source code from github directly
RUN if ! test -d "/home/node/app/PorMiBarrioAPPs"; \
	then git clone --recursive https://github.com/datauy/PorMiBarrioAPPs.git /home/node/app/PorMiBarrioAPPs; fi

# Move to the repos folder
WORKDIR /home/node/app/PorMiBarrioAPPs

# Update the ionic config file name
RUN cp ionic.project ionic.config.json

# Switched this yarn instead of npm because of this issue
# https://github.com/npm/npm/issues/17851
# (got there from here https://github.com/nodejs/docker-node/issues/423)
RUN yarn global add cordova
RUN yarn global add ionic@1.7.11
RUN yarn global add bower
RUN yarn global add gulp

RUN npm link ionic
RUN npm link bower
RUN npm link gulp
RUN npm link gulp-util
RUN npm link gulp-concat
RUN npm link gulp-sass
RUN npm link gulp-minify-css
RUN npm link gulp-rename
RUN npm link shelljs
RUN npm link gulp-ng-annotate
RUN npm link gulp-uglify
RUN npm link gulp-sourcemaps
RUN npm link gulp-angular-templatecache
RUN npm link gulp-header
RUN npm link angular

# Chance folder owner
RUN chown -R node /home/node

# Change to Docker's node user, appropiate for continuing installing
USER node

# Adding to the bower.json dependecies and resolutions sections so that installation doesn't fail in non-interactive mode
RUN sed -i '4 s/1.1.0/1.2.1/' bower.json
RUN sed -i '5 s/}/,"angular":"1.4.14"}/' bower.json
RUN sed -i '39 s/}/,"angular":"1.4.14"}/' bower.json

RUN bower install --save
RUN bower install pouchdb --save
RUN bower install pouchdb-collate --save
RUN bower install ionic-cache-src --save

RUN gulp --build

# Fix some broken references
RUN mkdir www/lib/ionic/release
RUN cp -R www/lib/ionic/js www/lib/ionic/release/js

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD ["sh", "/home/node/app/auto-executed-within-container-when-starting.sh"]

