# Invoicer Chapter 2 Scripts

### Initialize

    Import-Module ./scripts/invoicer.psm1 -Verbose -Force

    Initialize-InvDocker

    Get-InvStatus

### Build

    Build-InvApp
    Build-InvDb

    Start-InvDb
    Start-InvPgadmin

    Start-InvApp -UseDatabase

### While logged into database container

    Connect-InvDb

    psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"

### Running the invoicer-chapter2 example

    # run bash in the database container
    sudo docker exec -it -u root -w /root secdevops-invoicer /bin/sh 

    sudo docker exec -it secdevops-invoicer /bin/sh

### Teardown
    sudo docker volume rm secdevops_pgsql 
    sudo docker volume create secdevops_pgsql 

    sudo docker container stop secdevops-pgsql

    sudo docker container rm secdevops-pgsql

    sudo docker container stop secdevops_invoicer

    sudo docker container rm secdevops_invoicer
    
### Run locally

    ./bin/invoicer/invoicer-chapter2

### Submit and receive an invoice

    curl -X POST --data '{"is_paid": false, "amount": 1664, "due_date": "2016-05-07T23:00:00Z", "charges": [ { "type":"blood work", "amount": 1664, "description": "blood work" } ] }' http://localhost:8080/invoice

    curl -X GET http://localhost:8080/invoice/1

