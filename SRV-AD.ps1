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
