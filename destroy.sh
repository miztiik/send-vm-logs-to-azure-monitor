# set -x
set -e

# Set Global Variables
MAIN_BICEP_TEMPL_NAME="main.bicep"
LOCATION=$(jq -r '.parameters.deploymentParams.value.location' params.json)
SUB_DEPLOYMENT_PREFIX=$(jq -r '.parameters.deploymentParams.value.sub_deploymnet_prefix' params.json)
ENTERPRISE_NAME=$(jq -r '.parameters.deploymentParams.value.enterprise_name' params.json)
ENTERPRISE_NAME_SUFFIX=$(jq -r '.parameters.deploymentParams.value.enterprise_name_suffix' params.json)
# GLOBAL_UNIQUENESS=$(jq -r '.parameters.deploymentParams.value.global_uniqueness' params.json)
GLOBAL_UNIQUENESS="024"

RG_NAME="${ENTERPRISE_NAME}_${ENTERPRISE_NAME_SUFFIX}_${GLOBAL_UNIQUENESS}"


# # Generate and SSH key pair to pass the public key as parameter
# ssh-keygen -m PEM -t rsa -b 4096 -C '' -f ./miztiik.pem

# pubkeydata=$(cat miztiik.pem.pub)



# Function Deploy all resources
function deploy_everything()
{
az bicep build --file $1
az deployment sub create \
    --name ${SUB_DEPLOYMENT_PREFIX}"-"${GLOBAL_UNIQUENESS}"-Deployment" \
    --location $LOCATION \
    --parameters @params.json \
    --template-file $1 \
    # --confirm-with-what-if
}

function shiva_de_destroyer {
  if [[ $1 == "shiva" ]]; then
    echo "|------------------------------------------------------------------|"
    echo "|                                                                  |"
    echo "|                   Shiva the destroyer in action                  |"
    echo "|             Beginning the end of the Miztiikon Universe          |"
    echo "|                                                                  |"
    echo "|------------------------------------------------------------------|"
    

    # Delete Subscription deployments
    az deployment sub delete \
        --name ${SUB_DEPLOYMENT_PREFIX}"-"${GLOBAL_UNIQUENESS}"-Deployment"
    
    az deployment sub delete \
        --name ${RG_NAME}

    # Delete a resource group without confirmation
    az group delete \
        --name ${RG_NAME} --yes \
        --no-wait
  fi
}


# deploy_everything $MAIN_BICEP_TEMPL_NAME


# Universal DESTROYER BE CAREFUL
shiva_de_destroyer $1
