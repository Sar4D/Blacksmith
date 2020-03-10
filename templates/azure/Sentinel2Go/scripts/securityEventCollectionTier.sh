#!/bin/bash

# Reference:
# https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-rest
# https://github.com/Azure/Azure-Security-Center/tree/master/Powershell%20scripts/Security%20Event%20collection%20tier
# https://medium.com/@mauridb/calling-azure-rest-api-via-curl-eb10a06127

set -e

script_name=$0

usage(){
  echo "Invalid option: -$OPTARG"
  echo "Usage: ${script_name} -r [Resource group name]"
  echo "                      -w [Log Analytics Workspace Name]"
  echo "                      -t [Security Events collection tier (None, Minimal, Common, All)]"
  exit 1
}

while getopts r:w:t:h opt; do
    case "$opt" in
        r)  RESOURCE_GROUP_NAME=$OPTARG;;
        w)  WORKSPACE_NAME=$OPTARG;;
        t)  COLLECTION_TIER=$OPTARG;;
        h) #Show help
            usage
            exit 2
            ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$WORKSPACE_NAME" ] || [ -z "$COLLECTION_TIER" ]; then
  usage
else
    az rest -m put -u "https://management.azure.com/subscriptions/{subscriptionId}/resourcegroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/Workspaces/${WORKSPACE_NAME}/datasources/SecurityEventCollectionConfiguration?api-version=2015-11-01-preview" --body "
    {
        \"kind\": \"SecurityEventCollectionConfiguration\",
        \"properties\": {
            \"Tier\": \"${COLLECTION_TIER}\",
            \"TierSetMethod\": \"Custom\"
        }
    }
    " --verbose
fi