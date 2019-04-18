Docker container with the following included

- Java 8 (OpenJDK)
- NodeJS 10.15.3
- SAP Cloud Platform Neo Environment SDK 3.78.15
- Multi-Target Application Archive Builder 1.1.19
- Grunt CLI
- JQ
- Karma

Based on devops containers from https://github.com/SAP/devops-docker-images/

Can be used to 
- create MTA builds 
- deploy apps to SAP Cloud Platform Neo 
- run OPA tests with Karma

Run Karma test:

```/node_modules/karma/bin/karma start <conf.js>```

RunMTA build:

```mtaBuild --mtar ${mtaName}.mtar --build-target=NEO build```

Deploy to SAP Cloud Platform:

```neo.sh deploy-mta --user $CI_DEPLOY_USER --host $CI_DEPLOY_HOST --source ${mtaName}.mtar --account $CI_DEPLOY_ACCOUNT_AD1 --password $CI_DEPLOY_PASSWORD --synchronous```