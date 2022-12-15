#!/bin/bash

# Author  : Mark Heckler
# Notes   : Must have sourced envBBDFASA.sh and run configBBDFASA.sh before
#           this script per previous instructions
# History : Official "version 1" 20221005.
#         : This will not work for you to deploy these apps "as is", since I 
#         : access an external service that requires a (free) key and leverage
#         : Azure Key Vault. This is provided FOR REFERENCE ONLY 20221215.

clear
printf "\nDeploying app artifacts to Spring Apps\n"

# Deploy the actual applications
printf "\n\nDeploying $GATEWAY_SERVICE_ID\n"
az spring app deploy -n $GATEWAY_SERVICE_ID \
    -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --artifact-path $GATEWAY_SERVICE_JAR \
    --jvm-options='-Xms2048m -Xmx2048m'

printf "\n\nDeploying $AIRPORT_SERVICE_ID\n"
az spring app deploy -n $AIRPORT_SERVICE_ID \
    -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --artifact-path $AIRPORT_SERVICE_JAR \
    --jvm-options='-Xms2048m -Xmx2048m'

printf "\n\nDeploying $WEATHER_SERVICE_ID\n"
az spring app deploy -n $WEATHER_SERVICE_ID \
    -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --artifact-path $WEATHER_SERVICE_JAR \
    --jvm-options='-Xms2048m -Xmx2048m'

printf "\n\nDeploying $CONDITIONS_SERVICE_ID\n"
az spring app deploy -n $CONDITIONS_SERVICE_ID \
    -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE \
    --artifact-path $CONDITIONS_SERVICE_JAR \
    --jvm-options='-Xms2048m -Xmx2048m'

# Exercise those endpoints
export GATEWAY_URI=$(az spring app show -n $GATEWAY_SERVICE_ID -g $RESOURCE_GROUP -s $SPRING_APPS_SERVICE --query properties.url --output tsv)

printf "\n\nTesting deployed services at $GATEWAY_URI\n"
for i in `seq 1 3`; 
do
  # NOTE: This WILL NOT WORK for you as-is. I use a (free) key for an external service. You will need to obtain one and create a Key Vault or modify the apps.
  # NOTE: FOR REFERENCE ONLY.

  printf "\n\nRetrieving airports list\n"
  curl -g $GATEWAY_URI/airport/

  printf "\n\nRetrieving airport\n"
  curl -g $GATEWAY_URI/airport/airport/KALN

  printf "\n\nRetrieving default weather (METAR: KSTL)\n"
  curl -g $GATEWAY_URI/weather

  printf "\n\nRetrieving METAR for KSUS\n"
  curl -g $GATEWAY_URI/weather/metar/KSUS

  printf "\n\nRetrieving TAF for KSUS\n"
  curl -g $GATEWAY_URI/weather/taf/KSUS

  printf "\n\nRetrieving current conditions greeting\n"
  curl -g $GATEWAY_URI/conditions

  printf "\n\nRetrieving METARs for Class B, C, & D airports in vicinity of KSTL\n"
  curl -g $GATEWAY_URI/conditions/summary
done

printf "\n\nAPI exercises complete via gateway $GATEWAY_URI\n"
