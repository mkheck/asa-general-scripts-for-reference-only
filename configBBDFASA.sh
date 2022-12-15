#!/bin/bash
# set -e

# Author  : Mark Heckler
# Notes   : Must have sourced envBBDFASA.sh before this script per envBBDFASA.sh instructions
# History : Official "version 1" 20221005.
#         : This is provided FOR REFERENCE ONLY 20221215.

function error_handler() {
  az group delete -g $RESOURCE_GROUP --no-wait --subscription $SUBSCRIPTION -y
  echo "ERROR occurred :line no = $2" >&2
  exit 1
}
trap 'error_handler $? ${LINENO}' ERR

clear

# Add required extensions
az extension add -n spring


# Set origin machine variable (if desired/required)
# DEVBOX_IP_ADDRESS=$(curl ifconfig.me)


# Create and sanitize local code directory
cd ${PROJECT_DIRECTORY}

mkdir -p source-code
cd source-code
rm -rdf $PROJECT_REPO


# Retrieve code from repo, build apps
printf "\n\nCloning the sample project: $REPO_OWNER_URI/$PROJECT_REPO\n"

git clone --recursive $REPO_OWNER_URI/$PROJECT_REPO
cd $PROJECT_REPO
mvn clean package -DskipTests -Denv=cloud

cd "$PROJECT_DIRECTORY/source-code/$PROJECT_REPO"


# Infra configuration
printf "\n\nCreating the Resource Group: ${RESOURCE_GROUP} Region: ${REGION}\n"

az group create -l $REGION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION


printf "\n\nCreating the Spring Apps infra: ${SPRING_APPS_SERVICE}\n"

az spring create -n $SPRING_APPS_SERVICE -g $RESOURCE_GROUP -l $REGION --disable-app-insights false

az spring config-server git set -n ${SPRING_APPS_SERVICE} -g $RESOURCE_GROUP --uri $REPO_OWNER_URI/$CONFIG_REPO


# Create app constructs in ASA
printf "\n\nCreating the apps in Spring Apps\n"

az spring app create -n $GATEWAY_SERVICE_ID -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --instance-count 1 --memory 2Gi --runtime-version Java_17 --assign-endpoint true
az spring app create -n $AIRPORT_SERVICE_ID -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --instance-count 1 --memory 2Gi --runtime-version Java_17 --assign-endpoint true
az spring app create -n $WEATHER_SERVICE_ID -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --instance-count 1 --memory 2Gi --runtime-version Java_17 --assign-endpoint true
az spring app create -n $CONDITIONS_SERVICE_ID -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --instance-count 1 --memory 2Gi --runtime-version Java_17 --assign-endpoint true


# Log analysis configuration
printf "\n\nCreating the log analytics workspace: ${LOG_ANALYTICS}\n"

az monitor log-analytics workspace create -g $RESOURCE_GROUP -n $LOG_ANALYTICS -l $REGION
                            
LOG_ANALYTICS_RESOURCE_ID=$(az monitor log-analytics workspace show \
    -g $RESOURCE_GROUP \
    -n $LOG_ANALYTICS --query id --output tsv)

WEBAPP_RESOURCE_ID=$(az spring show -n $SPRING_APPS_SERVICE -g $RESOURCE_GROUP --query id --output tsv)


printf "\n\nCreating the log monitor\n"

az monitor diagnostic-settings create -n "send-spring-logs-and-metrics-to-log-analytics" \
    --resource $WEBAPP_RESOURCE_ID \
    --workspace $LOG_ANALYTICS_RESOURCE_ID \
    --logs '[
         {
           "category": "SystemLogs",
           "enabled": true,
           "retentionPolicy": {
             "enabled": false,
             "days": 0
           }
         },
         {
            "category": "ApplicationConsole",
            "enabled": true,
            "retentionPolicy": {
              "enabled": false,
              "days": 0
            }
          }        
       ]' \
       --metrics '[
         {
           "category": "AllMetrics",
           "enabled": true,
           "retentionPolicy": {
             "enabled": false,
             "days": 0
           }
         }
       ]'

printf "\n\nConfiguration complete!\n"
# fin
