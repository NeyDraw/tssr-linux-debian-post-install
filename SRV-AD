# Définition des variables
$NewComputerName = "SRV-AD"
$StaticIP = "192.168.1.200"
$SubnetMask = "255.255.255.0"
$Gateway = "192.168.1.1"
$DNSServer = "192.168.1.200"
$DomainName = "SRV.Draw"
$SafeModePassword = ConvertTo-SecureString "SrvDraw37*" -AsPlainText -Force
$CSVFile = "C:\Users\Administrator\users.csv"

# 1. Renommer la machine
Rename-Computer -NewName $NewComputerName -Force
Restart-Computer -Force

# 2. Configurer une IP fixe
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNSServer

# Vérifier l'IP
Write-Host "Vérification de la configuration réseau :"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -eq $StaticIP}

# 3. Installer le rôle AD DS
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# 4. Promouvoir en contrôleur de domaine
Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $SafeModePassword -Force

# 5. Création des OU
Import-Module ActiveDirectory
New-ADOrganizationalUnit -Name "Administrateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Utilisateurs" -Path "DC=mondomaine,DC=local"
New-ADOrganizationalUnit -Name "Techniciens" -Path "DC=mondomaine,DC=local"

# Importer le module Active Directory
Import-Module ActiveDirectory

# Définir le chemin du fichier CSV
$CSVFile = "C:\Users\Administrator\users.csv"

# Définir le domaine et l'OU cible
$DomainName = "mondomaine.local"
$OUPath = "OU=Utilisateurs,DC=mondomaine,DC=local"

# Vérifier si le fichier CSV existe
if (Test-Path $CSVFile) {
    # Importer les utilisateurs du fichier CSV
    $Users = Import-Csv -Path $CSVFile

    foreach ($User in $Users) {
        # Générer l'adresse e-mail si absente
        $Email = if ($User.Email -ne "") { $User.Email } else { "$($User.Username)@$DomainName" }

        # Création du compte utilisateur
        New-ADUser `
            -Name "$($User.FirstName) $($User.LastName)" `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -UserPrincipalName "$($User.Username)@$DomainName" `
            -SamAccountName $User.Username `
            -EmailAddress $Email `
            -Path $OUPath `
            -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
            -Enabled $true

        Write-Host "Utilisateur $($User.Username) créé avec succès."
    }
} else {
    Write-Host "Erreur : Le fichier CSV n'existe pas !"
}
