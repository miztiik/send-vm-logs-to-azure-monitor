param deploymentParams object
param tags object = resourceGroup().tags
param osKind string
param ruleName string
param logFilePattern string
param customTableNamePrefix string
param dataCollectionEndpointId string
param logAnalyticsPayGWorkspaceId string
param logAnalyticsPayGWorkspaceName string

resource r_dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${ruleName}_${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  kind: osKind
  properties: {
    description: 'Log collection rule for miztiik web store data across all linux Vms.'
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: {
      'Custom-${customTableNamePrefix}_CL' : {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
          {
            name: 'request_id'
            type: 'string'
          }
          {
            name: 'event_type'
            type: 'string'
          }
          {
            name: 'store_id'
            type: 'int'
          }
          {
            name: 'cust_id'
            type: 'int'
          }
          {
            name: 'category'
            type: 'string'
          }
          {
            name: 'sku'
            type: 'int'
          }
          {
            name: 'price'
            type: 'real'
          }
          {
            name: 'qty'
            type: 'int'
          }
          {
            name: 'discount'
            type: 'real'
          }
          {
            name: 'gift_wrap'
            type: 'boolean'
          }
          {
            name: 'variant'
            type: 'string'
          }
          {
            name: 'priority_shipping'
            type: 'boolean'
          }
          {
            name: 'contact_me'
            type: 'string'
          }
      ]
      }
    }
    dataSources: {
      logFiles: [
        {
          streams: [
            'Custom-${customTableNamePrefix}_CL'
          ]
          filePatterns: [
            logFilePattern
          ]
          format: 'text'
          settings: {
            text: {
              recordStartTimestampFormat: 'ISO 8601'
            }
          }
          // name: '${customTableNamePrefix}_CL'
          name: 'myFancyLogFileFormat'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name:  logAnalyticsPayGWorkspaceName
          workspaceResourceId: logAnalyticsPayGWorkspaceId
        }
      ]
    }
    dataFlows: [
      {
        streams: [ 'Custom-${customTableNamePrefix}_CL' ]
        destinations: [ logAnalyticsPayGWorkspaceName ]
        transformKql: 'source | extend jsonContext = parse_json(tostring(RawData)) | extend TimeGenerated=now(), request_id=tostring(RawData), event_type=tostring(jsonContext.event_type), store_id=toint(jsonContext.store_id),cust_id=toint(jsonContext.cust_id),category=tostring(jsonContext.category),sku=toint(jsonContext.sku),price=toreal(jsonContext.price),qty=toint(jsonContext.qty),discount=toreal(jsonContext.discount),gift_wrap=tobool(jsonContext.gift_wrap),variant=tostring(jsonContext.variant),priority_shipping=tobool(jsonContext.priority_shipping),contact_me=tostring(jsonContext.contact_me)'


        /* 

        store_id=toint(jsonContext.store_id),cust_id=toint(jsonContext.cust_id),category=tostring(jsonContext.category),sku=toint(jsonContext.sku),price=toreal(jsonContext.price),qty=toint(jsonContext.qty),discount=toreal(jsonContext.discount),gift_wrap=tobool(jsonContext.gift_wrap),variant=tostring(jsonContext.variant),priority_shipping=tobool(jsonContext.priority_shipping),contact_me=tostring(jsonContext.contact_me)


'source | extend jsonContext = parse_json(RawData) | project TimeGenerated = todatetime(jsonContext.TimeGenerated)
 request_id = jsonContext.request_id
 event_type = jsonContext.event_type
 store_id = jsonContext.store_id
 cust_id = jsonContext.cust_id
 category = jsonContext.category
 sku = jsonContext.sku
 price = jsonContext.price
 qty = jsonContext.qty
 discount = jsonContext.discount
 gift_wrap = jsonContext.gift_wrap
 variant = jsonContext.variant
 priority_shipping = jsonContext.priority_shipping'


        // transformKql: 'source|extend Data = substring(source, 22, strlen(source))| extend Dynamic = split(Data," ")| extend store_id = toint(Dynamic[0]), cust_id = toint(Dynamic[1]), sku = toint(Dynamic[2]), qty = toint(Dynamic[3]), price = toreal(Dynamic[4]), category = tostring(Dynamic[5]), req_id = tostring(Dynamic[6])| project-away source, Data, Dynamic'
        // transformKql : 'source | extend jsonContext = parse_json(AdditionalContext) | project TimeGenerated = Time, Computer, AdditionalContext = jsonContext, CounterName=tostring(jsonContext.CounterName), CounterValue=toreal(jsonContext.CounterValue)'
        // transformKql: 'source|extend Data = substring(RawData, 22, strlen(RawData))| extend Dynamic = split(Data,":")| extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])|where Error > 5| project-away RawData, Data, Dynamic'
        // transformKql: 'source | project RawData | extend parsed = parse_json(RawData) | project request_id = parsed.request_id,event_type = parsed.event_type,store_id = parsed.store_id,cust_id = parsed.cust_id,category = parsed.category,sku = parsed.sku,price = parsed.price,qty = parsed.qty,discount = parsed.discount,gift_wrap = parsed.gift_wrap,variant = parsed.variant,priority_shipping = parsed.priority_shipping,TimeGenerated = parsed.TimeGenerated'
        // transformKql: 'source | extend TimeGenerated | extend parsed = parse_json(RawData) | project request_id = parsed.request_id,event_type = parsed.event_type,store_id = parsed.store_id,cust_id = parsed.cust_id,category = parsed.category,sku = parsed.sku,price = parsed.price,qty = parsed.qty,discount = parsed.discount,gift_wrap = parsed.gift_wrap,variant = parsed.variant,priority_shipping = parsed.priority_shipping,TimeGenerated = parsed.TimeGenerated'
        // transformKql: 'source | extend parsed = parse_json(RawData) | project TimeGenerated = todatetime(parsed.TimeGenerated), request_id = parsed.request_id,event_type = parsed.event_type,store_id = parsed.store_id,cust_id = parsed.cust_id,category = parsed.category,sku = parsed.sku,price = parsed.price,qty = parsed.qty,discount = parsed.discount,gift_wrap = parsed.gift_wrap,variant = parsed.variant,priority_shipping = parsed.priority_shipping'
        // transformKql: 'source 
        //     | extend TimeGenerated = ls_timestamp 
        //     | parse message
        //       with    MessageId: int
        //       "|"     DeviceType: string
        //       "|"     DeviceName: string
        //       "|"     EventType: string
        //       "|"     Location: string
        //       "|"     NetworkType: string
        //       "|"     SrcIp: string
        //       "|"     SrcPort: int
        //       "|"     DstIp: string
        //       "|"     DstPort: int
        //       "|"     MessageSize: int
        //       "|"     Direction: string
        //       "|"     DstAddress: string
        //       "|"     Protocol: string
        //       "|"     Result: string
        //     | project-away message'
        /*
        source|extend Data = substring(RawData, 22, strlen(RawData))
          | extend Dynamic = split(Data,":")
          | extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])|where Error > 5
          | project-away RawData, Data, Dynamic
        
        
          source | extend Data = substring(RawData, 22, strlen(RawData)) | extend Dynamic = split(Data,":") | project TimeGenerated=now(), cust_id=toint(Dynamic[0]), category='crack'
        
          */

        // 'source|extend Data = substring(source, 22, strlen(source))| extend Dynamic = split(Data," ")| extend Computer = tostring(Dynamic[0]), Error = toint(Dynamic[1]), Description = tostring(Dynamic[2])| project-away source, Data, Dynamic'

        /*
        # https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-collection-rule-sample-custom-logs
        source | extend jsonContext = parse_json(AdditionalContext) | project TimeGenerated = Time, Computer, AdditionalContext = jsonContext, ExtendedColumn=tostring(jsonContext.CounterName)
        
        source | extend jsonContext = parse_json(RawData) | project TimeGenerated=now(), cust_id=toint(jsonContext.cust_id), 

        source | extend jsonContext = parse_json(RawData) | extend TimeGenerated=now(), category='hague', request_id=tostring(RawData), cust_id=toint(jsonContext.cust_id)

        source | extend Data = substring(RawData, 22, strlen(RawData)) | extend Dynamic = split(Data,":") | project TimeGenerated=now(), cust_id=toint(Dynamic[0]), category='crack'
        */
        outputStream: 'Custom-${customTableNamePrefix}_CL'
      }
    ]

  }
}


output dataCollectionRuleId string = r_dcr.id
