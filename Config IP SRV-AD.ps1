# Création des OU
Import-Module ActiveDirectory
New-ADOrganizationalUnit -Name "Administrateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Utilisateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Techniciens" -Path "DC=mondomaine,DC=local"

# Configurer une IP fixe
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNSServer

# Vérifier l'IP
Write-Host "Vérification de la configuration réseau :"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -eq $StaticIP}
