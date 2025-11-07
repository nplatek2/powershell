# Adds the Active Directory Domain Services (AD DS) role to the server.
# -IncludeAllSubFeature ensures all related subcomponents are installed.
# -IncludeManagementTools installs the AD DS management console and tools.
Add-WindowsFeature -Name "Ad-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools