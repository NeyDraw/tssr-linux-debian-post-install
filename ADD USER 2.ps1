# Vérifier si le module Active Directory est installé
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "Erreur : Le module Active Directory n'est pas disponible !" -ForegroundColor Red
    Exit
}

# Importer le module Active Directory
Import-Module ActiveDirectory

# Définir le chemin du fichier CSV
$CSVFile = "C:\Users\Administrator\users.csv"

# Vérifier si le fichier CSV existe
if (!(Test-Path $CSVFile)) {
    Write-Host "Erreur : Le fichier CSV n'existe pas à l'emplacement $CSVFile !" -ForegroundColor Red
    Exit
}

# Importer les utilisateurs depuis le fichier CSV
$Users = Import-Csv -Path $CSVFile

# Définition du domaine
$DomainName = "mondomaine.local"
$DefaultPassword = "P@ssw0rd"

foreach ($User in $Users) {
    $FullName = "$($User.FirstName) $($User.LastName)"
    $UserPrincipalName = "$($User.Username)@$DomainName"
    $OUPath = "OU=$($User.OU),DC=mondomaine,DC=local"

    # Vérifier si l'utilisateur existe déjà
    if (Get-ADUser -Filter {SamAccountName -eq $User.Username} -ErrorAction SilentlyContinue) {
        Write-Host "L'utilisateur $FullName existe déjà, passage au suivant." -ForegroundColor Yellow
        Continue
    }

    # Vérifier si l'OU existe
    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $User.OU} -ErrorAction SilentlyContinue)) {
        Write-Host "Erreur : L'OU $($User.OU) n'existe pas !" -ForegroundColor Red
        Continue
    }

    # Création de l'utilisateur
    New-ADUser `
        -Name $FullName `
        -GivenName $User.FirstName `
        -Surname $User.LastName `
        -UserPrincipalName $UserPrincipalName `
        -SamAccountName $User.Username `
        -EmailAddress $User.Email `
        -Path $OUPath `
        -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true

    Write-Host "Utilisateur $FullName créé avec succès dans l'OU $($User.OU)." -ForegroundColor Green
}

Write-Host "Importation des utilisateurs terminée !" -ForegroundColor Cyan
