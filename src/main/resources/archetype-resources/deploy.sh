#!/bin/bash

# Script for deploy our JEE apps
# =====================================================================================
# Prerequisits:
# - Dockerfile.tomcat in the root with the script
# - The actual pom.xml (the maven project)
# - Maven installed
# =====================================================================================
# Script Info.:
# - Purpouse: Automate the docker tomcat creation for deploy our "wars"
# - Reason: Instead of downloading the actual server use a simpler environnment
#
#  + Using a volume for loading the "*.war" files directly after being updated
#   in the root of our maven project (/war)
# =====================================================================================
# Functions:
# - deploy_tomcat: Setup the tomcat container
# - setup_mvn: Generate our war package after the container
# =====================================================================================


DOCKERFILE="Dockerfile.tomcat"
IMAGE_NAME="tomcat85"
CONTAINER_NAME=$IMAGE_NAME
CATALINA_WEBAPP_BASE_PATH="/usr/local/tomcat/webapps"
PORTS="8585:8080"

PATH_WAR="$PWD/wars/"
echo "Running $0 ..."

deploy_tomcat(){
    # Ensure container is not running/created
    docker rm -f  $CONTAINER_NAME
    # Build the image
    docker build -f $DOCKERFILE  -t $IMAGE_NAME .
    # Run with the previous configs and adding a volume for /wars (webapps)
    docker run -d \
        -v "$PATH_WAR":$CATALINA_WEBAPP_BASE_PATH \
        --name $IMAGE_NAME \
        -p $PORTS \
        $CONTAINER_NAME
}

setup_mvn(){
  echo "Generating our war to test if mvn works and so the tomcat... "
  mvn package
}

deploy_tomcat
setup_mvn