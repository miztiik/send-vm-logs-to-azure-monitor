param deploymentParams object
param vmParams object
param tags object = resourceGroup().tags
param vnetName string 
param dataCollectionEndpointId string
param dataCollectionRuleId string


var saName = uniqueString(resourceGroup().id)



param vmName string = '${vmParams.vmNamePrefix}-${deploymentParams.global_uniqueness}'

param dnsLabelPrefix string = toLower('${vmParams.vmNamePrefix}-${deploymentParams.global_uniqueness}-${uniqueString(resourceGroup().id, vmName)}')
param publicIpName string = '${vmParams.vmNamePrefix}-${deploymentParams.global_uniqueness}-PublicIp'

// var customScriptData = base64(loadTextContent('./bootstrap_scripts/deploy_app.sh'))
var customScriptData = loadFileAsBase64('./bootstrap_scripts/deploy_app.sh')


// @description('VM auth')
// @allowed([
//   'sshPublicKey'
//   'password'
// ])
// param authType string = 'password'

var LinuxConfiguration = {
  disablePasswordAuthentication: true 
  ssh: {
    publickeys: [
      {
        path: '/home/${vmParams.adminUsername}/.ssh/authorized_keys'
        keyData: vmParams.adminPassword
      }
    ]
  }
}

resource r_sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: saName
  location: deploymentParams.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}


resource r_publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: deploymentParams.location
  tags: tags
  sku: {
    name: vmParams.publicIpSku
  }
  properties: {
    publicIPAllocationMethod: vmParams.publicIPAllocationMethod
    publicIPAddressVersion:'IPv4'
    deleteOption:'Delete'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource r_webSg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: 'webSg'
  location: deploymentParams.location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowInboundSsh'
        properties: {
          priority: 250
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'HTTP'
        properties: {
          priority: 200
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Outbound_Allow_All'
        properties: {
          priority: 300
          protocol: '*'
          access: 'Allow'
          direction: 'Outbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'AzureResourceManager'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureResourceManager'
          access: 'Allow'
          priority: 160
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureStorageAccount'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Storage.${deploymentParams.location}'
          access: 'Allow'
          priority: 170
          direction: 'Outbound'
        }
      }
      {
        name: 'AzureFrontDoor'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureFrontDoor.FrontEnd'
          access: 'Allow'
          priority: 180
          direction: 'Outbound'
        }
      }
    ]
  }
}


resource r_nic_01 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: '${vmName}-Nic-01'
  location: deploymentParams.location
  tags: tags
  properties: {
    ipConfigurations: [
      { 
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vmParams.vmSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: r_publicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: r_webSg.id
    }
  }
}

resource r_vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: deploymentParams.location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmParams.vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmParams.adminUsername
      adminPassword: vmParams.adminPassword.secureString
      // adminPassword: secureString(vmParams.adminPassword.secureString)
      linuxConfiguration: ((vmParams.authType == 'password') ?null : LinuxConfiguration)
      customData: customScriptData
    }
    storageProfile: {
      imageReference: {
        publisher: 'RedHat'
        offer: 'RHEL'
        sku: '91-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: 'osDiskFor_${vmName}'
        caching: 'ReadWrite'
        deleteOption: 'Delete'
        diskSizeGB:128
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: r_nic_01.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: r_sa.properties.primaryEndpoints.blob
      }
    }
  }
}

// INSTALL Azure Monitor Agent
resource AzureMonitorLinuxAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = if(vmParams.isLinux) {
  parent: r_vm
  name: 'AzureMonitorLinuxAgent'
  location: deploymentParams.location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    enableAutomaticUpgrade: true
    autoUpgradeMinorVersion: true
    typeHandlerVersion: '1.25'
    settings:{
      'identifier-name': 'mi_res_id'
      'identifier-value': r_vm.identity.principalId
    }
  }
}

// Associate Data Collection Rule to VM
resource r_associateVmToDcr 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  // name: '${vmName}_${deploymentParams.global_uniqueness}'
  name: 'configurationAccessEndpoint'
  scope: r_vm
  properties: {
    dataCollectionEndpointId: dataCollectionEndpointId
    // dataCollectionRuleId: dataCollectionRuleId
    description: 'Send Custom logs to DCR'
  }
}
resource r_associateVmToDcr1 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: '${vmName}_${deploymentParams.global_uniqueness}'
  scope: r_vm
  properties: {
    // dataCollectionEndpointId: dataCollectionEndpointId
    dataCollectionRuleId: dataCollectionRuleId
    description: 'Send Custom logs to DCR'
  }
}



resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = if(vmParams.isWindows) {
  name: 'AzureMonitorWindowsAgent'
  parent: r_vm
  location: deploymentParams.location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}


output webGenHostName string = r_publicIp.properties.dnsSettings.fqdn
output adminUsername string = vmParams.adminUsername
output sshCommand string = 'ssh ${vmParams.adminUsername}@${r_publicIp.properties.dnsSettings.fqdn}'
output webGenHostId string = r_vm.id
output webGenHostPrivateIP string = r_nic_01.properties.ipConfigurations[0].properties.privateIPAddress
