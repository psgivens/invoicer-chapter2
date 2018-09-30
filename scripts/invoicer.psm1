# Invoicer Chapter 2 Scripts

Function Initialize-InvDocker {
    sudo docker network create --driver bridge secdevops-net
    sudo docker volume create secdevops_pgsql 
}

Function Build-InvApp {
  echo "go install .."
  go install --ldflags '-extldflags "-static"' `
    github.com/actionable-labs/invoicer-chapter2
  echo "Copy to bin/invoicer"
  mkdir -p bin
  cp "$env:GOPATH/bin/invoicer-chapter2" bin/invoicer
  echo "docker build ..."
  sudo docker build --no-cache -t actionablelabs/invoicer-chapter2 .
}

Function Build-InvDb {
### Build invoicer db image
    echo "Building invoicer_pgsql"
    sudo docker build -t invoicer_pgsql ../pgsql
}

Function Connect-InvDb {
    # run bash in the database container
    sudo docker exec -it secdevops-pgsql bash
}


Function Start-InvPgadmin {
    #sudo docker pull dpage/pgadmin4
    sudo docker run `
      -p 5002:80 `
      --name pgadmin_dock `
      --network secdevops-net `
      -e "PGADMIN_DEFAULT_EMAIL=user@domain.com" `
      -e "PGADMIN_DEFAULT_PASSWORD=Password1" `
      --rm `
      -d `
      dpage/pgadmin4
}


Function Get-InvStatus {
  echo "Networks:"
  sudo docker network list --format '{{json .}}' `
    | ConvertFrom-Json `
    | ?{ $_.Name -match 'secdevops' } `
    | Select Id, Name, Driver `
    | Format-Table
  echo "Volumes:"
  sudo docker volume list  --format '{{json .}}' `
    | ConvertFrom-Json `
    | ?{ $_.Name -match 'secdevops' } `
    | Select -Property Name, Driver, Mountpoint `
    | Format-Table
  echo "Containers:"
  sudo docker container list -a --format '{{json .}}' `
    | ConvertFrom-Json `
    | ?{ $_.Names -match 'secdevops' -or $_.Names -match 'pgadmin' } `
    | Select -Property ID, Names, Ports, Status `
    | Format-Table
  echo "Images:"
  sudo docker image list --format '{{json .}}' `
    | ConvertFrom-Json `
    | ?{ $_.Repository -match 'invoicer' -or $_.Repository -match 'pgadmin' } `
    | Select -Property ID, Repository, CreatedSince `
    | Format-Table
}


Function Get-DockerIp {
  param(
    [Parameter(Mandatory=$true)]
    $Name
  )
  $container = sudo docker container inspect $Name `
    | ConvertFrom-Json
  $container[0].NetworkSettings.Networks.'secdevops-net'.IPAddress
}

Function Start-InvDb {
    # run the database container
    # https://hub.docker.com/_/postgres/
    sudo docker run `
      --name secdevops-pgsql `
      --mount source=secdevops_pgsql,target=/var/lib/postgresql/data/pgdata `
      --network secdevops-net `
      -p 5432:5432 `
      -e POSTGRES_USER='invoicer' `
      -e POSTGRES_PASSWORD='Password1' `
      -e POSTGRES_DB='invoicer' `
      -e PGDATA=/var/lib/postgresql/data/pgdata `
      --rm `
      -d `
      invoicer_pgsql:latest
}

Function Start-InvApp {
  param(
    [switch]$UseDatabase
  )
  if ($UseDatabase) {
    # Run with postgresdatabase
    sudo docker run `
      --name secdevops-invoicer `
      -p 8080:8080 `
      -e INVOICER_USE_POSTGRES="yes" `
      -e INVOICER_POSTGRES_USER="invoicer" `
      -e INVOICER_POSTGRES_PASSWORD="Password1" `
      -e INVOICER_POSTGRES_HOST="secdevops-pgsql" `
      -e INVOICER_POSTGRES_DB="invoicer" `
      -e INVOICER_POSTGRES_SSLMODE="disable" `
      --network secdevops-net `
      --rm `
      -it `
      --entrypoint sh `
      actionablelabs/invoicer-chapter2 
  } else {
    # Run with sqlite database
    sudo docker run `
      --name secdevops-invoicer `
      -p 8080:8080 `
      --network secdevops-net `
      --rm `
      -d `
      actionablelabs/invoicer-chapter2
  }
}


Export-ModuleMember -Function Initialize-InvDocker 

Export-ModuleMember -Function Build-InvApp 
Export-ModuleMember -Function Build-InvImage
Export-ModuleMember -Function Build-InvDb

Export-ModuleMember -Function Start-InvApp 
Export-ModuleMember -Function Start-InvDb
Export-ModuleMember -Function Start-InvPgadmin

Export-ModuleMember -Function Connect-InvDb

Export-ModuleMember -Function Get-DockerIp
Export-ModuleMember -Function Get-InvStatus 


