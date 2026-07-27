targetScope = 'resourceGroup'

@description('Azure region used by the Container Apps environment and application.')
param location string = resourceGroup().location

@description('Name of the Azure Container Apps managed environment.')
@minLength(2)
@maxLength(60)
param environmentName string = 'jojo-environment'

@description('Name of the Jojo Container App.')
@minLength(2)
@maxLength(32)
param containerAppName string = 'jojo'

@description('Immutable GHCR image tag or digest to deploy.')
@minLength(1)
param image string

@secure()
@description('Authenticated MongoDB connection string stored as a Container Apps secret.')
@minLength(1)
param mongodbUri string

@description('MongoDB database used by Jojo.')
@minLength(1)
param mongodbDatabase string = 'jomongo'

@description('Application timezone.')
param appTimezone string = 'America/Chicago'

@description('Minimum replica count. Zero enables scale-to-zero for the Consumption plan.')
@allowed([
  0
  1
])
param minReplicas int = 0

var tags = {
  application: 'jojo'
  environment: 'production'
  managedBy: 'bicep'
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2025-07-01' = {
  name: environmentName
  location: location
  tags: tags
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

resource containerApp 'Microsoft.App/containerApps@2025-07-01' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerEnvironment.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      maxInactiveRevisions: 3
      ingress: {
        external: true
        allowInsecure: false
        targetPort: 8080
        transport: 'auto'
      }
      secrets: [
        {
          name: 'mongodb-uri'
          value: mongodbUri
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'jojo'
          image: image
          env: [
            {
              name: 'APPNAME'
              value: 'Jojo'
            }
            {
              name: 'APP_TIMEZONE'
              value: appTimezone
            }
            {
              name: 'BOXLANG_DEBUG'
              value: 'false'
            }
            {
              name: 'BOX_SERVER_PROFILE'
              value: 'production'
            }
            {
              name: 'ENVIRONMENT'
              value: 'production'
            }
            {
              name: 'HEALTHCHECK_URI'
              value: 'http://127.0.0.1:8080/healthcheck'
            }
            {
              name: 'LOG_LEVEL'
              value: 'INFO'
            }
            {
              name: 'MAX_MEMORY'
              value: '512m'
            }
            {
              name: 'MIN_MEMORY'
              value: '256m'
            }
            {
              name: 'MONGODB_DATABASE'
              value: mongodbDatabase
            }
            {
              name: 'MONGODB_DATASOURCE'
              value: 'jomongo'
            }
            {
              name: 'MONGODB_URI'
              secretRef: 'mongodb-uri'
            }
            {
              name: 'PORT'
              value: '8080'
            }
            {
              name: 'SESSION_COOKIE_SECURE'
              value: 'true'
            }
            {
              name: 'SESSION_TIMEOUT'
              value: '0,0,30,0'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: [
            {
              type: 'Startup'
              httpGet: {
                path: '/healthcheck'
                port: 8080
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
              periodSeconds: 10
              timeoutSeconds: 2
              failureThreshold: 10
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/healthcheck'
                port: 8080
                scheme: 'HTTP'
              }
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 1
        rules: [
          {
            name: 'http'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

output applicationName string = containerApp.name
output applicationUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
output environmentId string = containerEnvironment.id
