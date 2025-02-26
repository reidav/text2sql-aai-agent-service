param tags object = {}

@description('The name of the SQL logical server.')
param serverName string

@description('The identity to assign to the SQL logical server.')
param sqlIdentityName string

@description('The name of the SQL Database.')
param sqlDBName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Object id of the group that will be the SQL Server Admins.')
param applicationDatabaseAdminsObjectId string

@description('Login name of the SQL Server Admins.')
param applicationDatabaseAdminsLoginName string

// @description('The administrator username of the SQL logical server.')
// param administratorLogin string

// @description('The administrator password of the SQL logical server.')
// @secure()
// param administratorLoginPassword string

resource sqlUserIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (!empty(sqlIdentityName)) {
  name: sqlIdentityName
}

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: serverName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${sqlUserIdentity.id}': {}
    }
  }
  properties: {
    administrators: {
      // Only allow Azure AD connections (passwordless)
      azureADOnlyAuthentication: true
      // // The server administrator - we are passing the Entra Object Id
      sid: applicationDatabaseAdminsObjectId
      // // The login name of the server administrator group.
      login: applicationDatabaseAdminsLoginName
    }
    // This identity will be used when determining what in Azure the identity can see - which is why we need Directory.Read.All in order to CREATE EXTERNAL USER's from Entra.
    primaryUserAssignedIdentityId: sqlUserIdentity.id
  }

  // Create the sql server database.
  resource sqlServerDatabase 'databases' = {
    name: sqlDBName
    location: location
    tags: tags
    sku: {
      name: 'Basic'
      tier: 'Basic'
    }
  }
}
