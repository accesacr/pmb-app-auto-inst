# Select Node.js as the base image
FROM node

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential


# Set our working directory inside the image
WORKDIR /home

# Create a custom non-root user
RUN useradd -ms /bin/bash pormibarrio

# Copy the PMB-APP source code into place
COPY . ./pormibarrio

# Chance folder owner for folder
RUN chown -R pormibarrio ./pormibarrio

# Move to the repos folder
WORKDIR /home/pormibarrio/PorMiBarrioAPPs

# Install pre-requisites
RUN npm install -g cordova
RUN npm install -g ionic@1.7.11
RUN npm install -g bower
RUN npm install -g gulp

# Change to non-root user
USER pormibarrio

# Declare PMB-APP root folder
ENV PMB_ROOT /home/pormibarrio/PorMiBarrioAPPs

# Move inside the source code folder
WORKDIR $PMB_ROOT

# Update the ionic config file name
RUN cp ionic.project ionic.config.json

# Install and provision source code
RUN npm install

# RUN bower install --allow-root --save
# RUN bower install --allow-root pouchdb --save
# RUN bower install --allow-root pouchdb-collate --save
# RUN bower install --allow-root ionic-cache-src --save

RUN bower install --save
RUN bower install pouchdb --save
RUN bower install pouchdb-collate --save
RUN bower install ionic-cache-src --save
# RUN bower install https://github.com/BenBBear/ionic-cache-src --save

RUN gulp --build

# Fix some broken references
# RUN mkdir www/lib/ionic/release
# RUN cp -R www/lib/ionic/js www/lib/ionic/release/js

#RUN ionic serve


