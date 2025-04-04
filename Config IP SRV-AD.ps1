# Configurer une IP fixe
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
New-NetIPAddress -InterfaceIndex $Interface.ifIndex -IPAddress $StaticIP -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceIndex $Interface.ifIndex -ServerAddresses $DNSServer

# Vérifier l'IP
Write-Host "Vérification de la configuration réseau :"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -eq $StaticIP}

# Paramètres réseau
$ipAddress = "10.0.0.200"
$subnetMask = 24  # Windows utilise un préfixe (ex: 255.255.255.0 = 24)
$gateway = "10.0.0.254"
$dnsServer = "1.1.1.1"
$interfaceName = "Ethernet0"  # ⚠️ Vérifie avec Get-NetAdapter

# Vérifier si l'interface existe
$interface = Get-NetAdapter | Where-Object { $_.Name -eq $interfaceName -and $_.Status -eq "Up" }

if ($interface) {
    Write-Host "Interface trouvée : $interfaceName"
    
    # Supprimer toutes les adresses IP existantes
    Write-Host "Suppression des IPs existantes..."
    Get-NetIPAddress -InterfaceAlias $interfaceName -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue

    # Supprimer la passerelle existante
    Write-Host "Suppression de la passerelle existante..."
    Remove-NetRoute -InterfaceAlias $interfaceName -Confirm:$false -ErrorAction SilentlyContinue

    # Appliquer la nouvelle configuration IP
    Write-Host "Application de la nouvelle configuration IP..."
    New-NetIPAddress -InterfaceAlias $interfaceName -IPAddress $ipAddress -PrefixLength $subnetMask -DefaultGateway $gateway -ErrorAction Stop

    # Configuration du DNS
    Write-Host "Configuration du DNS manuel : $dnsServer"
    Set-DnsClientServerAddress -InterfaceAlias $interfaceName -ServerAddresses $dnsServer -ErrorAction Stop

    # Vérification des paramètres appliqués
    Write-Host "Configuration appliquée :"
    Get-NetIPAddress -InterfaceAlias $interfaceName | Format-Table
    Get-DnsClientServerAddress -InterfaceAlias $interfaceName | Format-Table

    # Redémarrage pour appliquer toutes les modifications
    Write-Host "Redémarrage du système pour appliquer les modifications..."
    "Restart-Computer -Force"
} else {
    Write-Host "⚠️ Erreur : L'interface réseau '$interfaceName' n'a pas été trouvée ou est inactive."
}
