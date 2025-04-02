# Définition des variables
$NewComputerName = "SRV-AD"
$StaticIP = "192.168.1.200"
$SubnetMask = "255.255.255.0"
$Gateway = "192.168.1.1"
$DNSServer = "192.168.1.200"
$DomainName = "SRV.Draw"
$SafeModePassword = ConvertTo-SecureString "SrvDraw37*" -AsPlainText -Force
$CSVFile = "C:\Users\Administrator\users.csv" ??????

# 1. Renommer la machine
Rename-Computer -NewName $NewComputerName -Force
Restart-Computer -Force

# 3. Installer le rôle AD DS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 4. Promouvoir en contrôleur de domaine
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -Force

# Création des OU
Import-Module ActiveDirectory
New-ADOrganizationalUnit -Name "Administrateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Utilisateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Techniciens" -Path "DC=mondomaine,DC=local"

# Vérifier si la machine a déjà le bon nom
if ($env:COMPUTERNAME -ne $NewComputerName) {
    Write-Host "Renommage du serveur en $NewComputerName..."
    Rename-Computer -NewName $NewComputerName -Force
    Restart-Computer -Force
} else {
    Write-Host "Le serveur est déjà nommé $NewComputerName"
}

# Vérifier si l'IP est déjà configurée
$CurrentIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -eq $StaticIP}).IPAddress
if ($CurrentIP -ne $StaticIP) {
    Write-Host "Configuration de l'IP statique..."
    $Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
    New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
    Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNSServer
} else {
    Write-Host "L'IP est déjà configurée sur $StaticIP"
}

# Vérifier si le rôle AD DS est déjà installé
if (!(Get-WindowsFeature AD-Domain-Services).Installed) {
    Write-Host "Installation du rôle AD DS..."
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
} else {
    Write-Host "Le rôle AD DS est déjà installé."
}

# Vérifier si le serveur est déjà un contrôleur de domaine
if (!(Get-ADDomain -ErrorAction SilentlyContinue)) {
    Write-Host "Promotion du serveur en contrôleur de domaine..."
    Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -Force
} else {
    Write-Host "Le serveur est déjà un contrôleur de domaine."
}

# Vérifier et créer les OU
Import-Module ActiveDirectory
$OUList = @("Administrateurs", "Utilisateurs", "Techniciens")
foreach ($OU in $OUList) {
    $OUPath = "OU=$OU,DC=mondomaine,DC=local"
    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $OU} -ErrorAction SilentlyContinue)) {
        Write-Host "Création de l'OU $OU..."
        New-ADOrganizationalUnit -Name $OU -Path "DC=mondomaine,DC=local"
    } else {
        Write-Host "L'OU $OU existe déjà."
    }
}

Write-Host "Script terminé avec succès !"
