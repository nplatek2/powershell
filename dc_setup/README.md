# Domain Controller Deployment Guide

This README will help you deploy a Domain Controller with Active Directory Domain Services in your environment.

---

## 📁 Files Used (in order)

1. `dc_deploy.json`
2. `dc_deploy.ps1`
3. `dc_setup.ps1`
4. `role_ad.ps1`
5. `role_newforest.ps1`
6. `role_ad.ps1`
7. `role_newforest.ps1`

---

## 🧩 Understanding `dc_deploy.json`

This JSON file provides configuration values for deploying your Domain Controller. It disables automatic checkpoints and assumes you're using a sysprepped hard disk. Ensure the disk is prepared before proceeding.

### Required Changes

| Key         | Description                                                  |
|-------------|--------------------------------------------------------------|
| `VMPath`    | Path where the virtual machine will be deployed              |
| `SwitchName`| Name of the virtual switch to be used                        |
| `Name`      | Name of the disk drive                                       |
| `Path`      | Path and new name of the disk drive                          |
| `ParentPath`| Path to the sysprepped disk drive                            |

---

## ⚙️ Understanding `dc_deploy.ps1`

This PowerShell script deploys the Domain Controller using the JSON configuration file.

### Required Change

Update the path to your JSON file:

```powershell
$config = Get-Content "<<PATH>>"

## 🧩 Understanding `role_ad.ps1`

This PowerShell script installs the Active Directory Domain Services (AD DS) role on the target server.

- Uses `IncludeAllSubFeature` to ensure all related subcomponents of AD DS are installed.
- Uses `IncludeManagementTools` to install the AD DS management console and associated tools for administration.

---

## 🧩 Understanding `role_newforest.ps1`

This script promotes the server to a Domain Controller and creates a new forest named `LAB.PRI`.

- Uses `InstallDns` to install the DNS Server role as part of the forest setup.
- Sets the Directory Services Restore Mode (DSRM) password via `SafeModeAdministratorPassword`.
- Uses `Confirm:$false` to suppress confirmation prompts for unattended execution.

### Required Changes

| Key                          | Description                                                  |
|-----------------------------|--------------------------------------------------------------|
| `DomainName`                | Name of the new forest domain (e.g., `LAB.PRI`)              |
| `SafeModeAdministratorPassword` | Password for Directory Services Restore Mode (DSRM)         |
