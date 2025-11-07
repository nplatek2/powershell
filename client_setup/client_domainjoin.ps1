# Define domain join parameters
$domainName = "LAB.PRI"
$domainUser = "LAB.PRI\Administrator"
$domainPassword = "P@ssw0rd1"

# Convert password to secure string
$securePassword = ConvertTo-SecureString $domainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($domainUser, $securePassword)

# Attempt to join domain
try {
    Add-Computer -DomainName $domainName -Credential $credential -Force -ErrorAction Stop
    Write-Host "Successfully joined domain '$domainName'. A restart is required to complete the process."
} catch {
    Write-Error "Failed to join domain '$domainName': $_"
}

# Restart to apply domain join
try {
    Restart-Computer -Force
    Write-Host "System is restarting to complete domain join."
} catch {
    Write-Error "Failed to restart the computer: $_"
}