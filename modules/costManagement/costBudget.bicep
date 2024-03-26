targetScope = 'subscription'

@description('Name of the Budget. It should be unique within a resource group.')
param parBudgetName string

@description('The total amount of cost or usage to track with the budget')
param parAmount int = 1000

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain. DEFAULT: Monthly. Allowed values: Monthly, Quarterly, Annually.')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param parTimeGrain string = 'Monthly'

@description('The current date in YYYY-MM-DD format. DEFAULT: Current date.')
param parDate string = utcNow('yyyy-MM-dd')

@description('The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain period. DEFAULT: Current date.')
param parStartDate string = parDate

@description('The end date for the budget in YYYY-MM-DD format. If not provided, we default this to 10 years from the start date.')
param parEndDate string = ''

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param firstThreshold int = 90

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param secondThreshold int = 110

@description('The list of email addresses to send the budget notification to when the threshold is exceeded.')
param parContactEmails array

resource resBudget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: parBudgetName
  properties: {
    timePeriod: {
      startDate: parStartDate
      endDate  : parEndDate
    }
    timeGrain    : parTimeGrain
    amount       : parAmount
    category     : 'Cost'
    notifications: {
      NotificationForExceededBudget1: {
        enabled      : true
        operator     : 'GreaterThan'
        threshold    : firstThreshold
        contactEmails: parContactEmails
      }
      NotificationForExceededBudget2: {
        enabled      : true
        operator     : 'GreaterThan'
        threshold    : secondThreshold
        contactEmails: parContactEmails
      }
    }
  }
}

output id string   = resBudget.id
output name string = resBudget.name
