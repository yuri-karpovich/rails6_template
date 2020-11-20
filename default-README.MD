# Deploy
## Preconditions

1. Set variables in .env file
1. Make sure that user has write permissions to DATA_DIR (default: `/opt/apps_data`)
1. `docker` and `docker-compose` should be installed on server

## How to deploy
To start docker containers: 

    ./start_docker.sh docker-compose-production.yml

To stop containers: 
    
    ./stop_docker.sh docker-compose-production.yml
    
# Development
## Setup dev environment
To start docker containers:

    ./start_docker.sh docker-compose-development.yml