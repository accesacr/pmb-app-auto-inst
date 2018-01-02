# Select node.js as the base image and pull image from hub.docker.com (docker's public registry).
FROM node

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential

# Set our working directory inside the image
WORKDIR /home

# Create a custom non-root user for PMB
RUN useradd -ms /bin/bash pormibarrio

# Copy the PMB-APP source code into place
RUN mkdir -p /home/pormibarrio
COPY . /home/pormibarrio

# Chance folder owner
RUN chown -R node /home/pormibarrio/

# Declare PMB-APP root folder
ENV PMB_ROOT /home/pormibarrio/PorMiBarrioAPPs

# Move to the repos folder
WORKDIR $PMB_ROOT

# Update the ionic config file name
RUN cp ionic.project ionic.config.json

# Switched this yarn instead of npm because of this issue
# https://github.com/npm/npm/issues/17851
# (got there from here https://github.com/nodejs/docker-node/issues/423)
# NPM to install and provision source code
# RUN chown -R node ../PorMiBarrioAPPs
# RUN npm install
# RUN npm install -g cordova
# RUN npm install -g bower
# RUN npm install -g gulp

# RUN yarn install
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

USER root
RUN chown -R node .

USER node

# Fix some broken references
RUN mkdir www/lib/ionic/release
RUN cp -R www/lib/ionic/js www/lib/ionic/release/js

# Define the script we want run once the container boots
# Use the "exec" form of CMD so our script shuts down gracefully on SIGTERM (i.e. `docker stop`)
# RUN ionic serve
CMD ["ionic", "serve"]




