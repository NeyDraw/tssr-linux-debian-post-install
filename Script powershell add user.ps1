# Importer le module Active Directory
Import-Module ActiveDirectory

# Définir le chemin du fichier CSV
$CSVFile = "C:\Users\Administrator\users.csv"

# Définir le domaine et l'OU cible
$DomainName = "DomainName"
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
            -AccountPassword (ConvertTo-SecureString "" -AsPlainText -Force) `
            -Enabled $true

        Write-Host "Utilisateur $($User.Username) créé avec succès."
    }
} else {
    Write-Host "Erreur : Le fichier CSV n'existe pas !"
}
