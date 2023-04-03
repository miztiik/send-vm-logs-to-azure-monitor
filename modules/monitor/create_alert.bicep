module alertNewVersion 'modules/alert.bicep' = {
    name: 'guardrails-alertNewVersion'
    dependsOn: [
      featuresTable
    ]
    params: {
      alertRuleDescription: 'Alerts when a new version of the Guardrails Solution Accelerator is available'
      alertRuleName: 'GuardrailsNewVersion'
      alertRuleDisplayName: 'Guardrails New Version Available.'
      alertRuleSeverity: 3
      location: location
      query: 'GR_VersionInfo_CL | summarize total=count() by UpdateAvailable=iff(CurrentVersion_s != AvailableVersion_s, "Yes",\'No\') | where UpdateAvailable == \'Yes\''
      scope: lawId
      autoMitigate: true
      evaluationFrequency: 'PT6H'
      windowSize: 'PT6H'
    }
  }