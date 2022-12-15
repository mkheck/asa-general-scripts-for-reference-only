#!/bin/bash

# Author  : Mark Heckler
# Notes   : Run with 'source envBBDFASA.sh' from your shell/commandline environment
# History : Official "version 1" 20221005.
#         : Option for deploying from my account; change for yours ;)
#         : This is provided FOR REFERENCE ONLY 20221215.

# Customize for your environment
export ROOT_NAME='your-root-repository-name'
export SUBSCRIPTION='your-subscription-here'
export RESOURCE_GROUP=$ROOT_NAME'-rg'
export SPRING_APPS_SERVICE=$ROOT_NAME'-service'
export LOG_ANALYTICS=$ROOT_NAME'-analytics'

export REGION='eastus'
export PROJECT_DIRECTORY=$HOME
export REPO_OWNER_URI='https://github.com/mkheck'
export PROJECT_REPO='bbdf'
export CONFIG_REPO='bbdf-config'

# Service/app instances
export GATEWAY_SERVICE_ID='gateway-service'
export AIRPORT_SERVICE_ID='airport-service'
export WEATHER_SERVICE_ID='weather-service'
export CONDITIONS_SERVICE_ID='conditions-service'

# Config repo location
export CONFIG_DIR="$PROJECT_DIRECTORY/source-code/$PROJECT_REPO/config"

# Individual app project directories
export GATEWAY_SERVICE_DIR="$PROJECT_DIRECTORY/source-code/$PROJECT_REPO/$GATEWAY_SERVICE_ID"
export AIRPORT_SERVICE_DIR="$PROJECT_DIRECTORY/source-code/$PROJECT_REPO/$AIRPORT_SERVICE_ID"
export WEATHER_SERVICE_DIR="$PROJECT_DIRECTORY/source-code/$PROJECT_REPO/$WEATHER_SERVICE_ID"
export CONDITIONS_SERVICE_DIR="$PROJECT_DIRECTORY/source-code/$PROJECT_REPO/$CONDITIONS_SERVICE_ID"

# Deployables
export GATEWAY_SERVICE_JAR="$GATEWAY_SERVICE_DIR/target/$GATEWAY_SERVICE_ID-0.0.1-SNAPSHOT.jar"
export AIRPORT_SERVICE_JAR="$AIRPORT_SERVICE_DIR/target/$AIRPORT_SERVICE_ID-0.0.1-SNAPSHOT.jar"
export WEATHER_SERVICE_JAR="$WEATHER_SERVICE_DIR/target/$WEATHER_SERVICE_ID-0.0.1-SNAPSHOT.jar"
export CONDITIONS_SERVICE_JAR="$CONDITIONS_SERVICE_DIR/target/$CONDITIONS_SERVICE_ID-0.0.1-SNAPSHOT.jar"
