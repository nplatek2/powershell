# Domain Controller Deployment Guide

This README will help you deploy a Domain Controller with Active Directory Domain Services in your environment.

---

## 📁 Files Used (in order)

1. `client_deploy.json`
2. `client_deploy.ps1`
3. `client_setup.ps1`
4. `client_domainjoin.ps1`

---

## 🧩 Understanding `client_deploy.json`

This JSON file provides configuration values for deploying your Domain Controller. It disables automatic checkpoints and assumes you're using a sysprepped hard disk. Ensure the disk is prepared before proceeding.

### Required Changes

| Key             | Description                                                  |
|-----------------|--------------------------------------------------------------|
| `VMPath`        | Path where the virtual machine will be deployed              |
| `SwitchName`    | Name of the virtual switch to be used                        |
| `Name`          | Name of the disk drive                                       |
| `Path`          | Path and new name of the disk drive                          |
| `ParentPath`    | Path to the sysprepped disk drive                            |
| `domainName`    | The Domain that has been created in the DC                   |
| `domainUser`    | The Domain user that was created                             |
| `domainPassword`| The password for the domain user                             |

---

## ⚙️ Understanding `client_setup.ps1`

This PowerShell script deploys the Domain Controller using the JSON configuration file.

### Required Change

| Key            | Description                                                  |
|----------------|--------------------------------------------------------------|
| `nicname`      | The name you want the network interface card to be called    |
| `ipaddress`    | The IP Address for the Device                                |
| `prefixlength` | The Subnet Mask as a CIDR                                    |
| `gateway`      | The Gateway Address for the Router or Switch                 |
| `dnsServer`    | The Address for the DC Server                                |

## ⚙️ Understanding `client_domainjoin.ps1`

This PowerShell script deploys the Domain Controller using the JSON configuration file.

### Required Change

| Key              | Description                                                  |
|------------------|--------------------------------------------------------------|
| `domainName`     | The name of the Domain that was created                      |
| `domainUser`     | The user that was created intitally for the domain           |
| `domainPassword` | The password for the domain user                             |
