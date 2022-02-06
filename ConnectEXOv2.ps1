## Description
## Script designed to log into the Exchange Online Admin portal

## Prerequisites = 1
## 1. Ensure msonline module installed or updated

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"
$ErrorMessageColor = "Red"

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

write-host -foregroundcolor Cyan "Script Started"
#----------------------------------------------------------------



#----------------------------------------------------------------
################# Import Required Services ################
#----------------------------------------------------------------
write-host -foregroundcolor $SystemMessageColor "`nLoading Required Modules"

## set-executionpolicy remotesigned
## May be required once to allow ability to runs scripts in PowerShell

################# Office 365 Admin, Exchange and Security & Compliance Center Online Portal ################
## First Time Run PowerShell as Admin: install-module msonline
## Get latest module Run: update-module msonline
import-module msonline
write-host -foregroundcolor $ProcessMessageColor "MSOnline module loaded"


################# SharePoint Online Portal ################
## Download and install https://www.microsoft.com/en-au/download/details.aspx?id=35588 (SharePoint Online Module)
## Current version = 16.0.7813.1200, 27 June 2018
import-module microsoft.online.sharepoint.powershell -disablenamechecking
write-host -foregroundcolor $ProcessMessageColor "SharePoint Online module loaded"


################# Azure AD Portal ################
## First Time Run PowerShell as Admin: install-module azuread
## Get latest module Run: update-module azuread 
## https://www.powershellgallery.com/packages/AzureAD/
## Current version = 2.0.1.16, 21 June 2018
import-module azuread
write-host -foregroundcolor $ProcessMessageColor "AzureAD module loaded"


################# Azure AD Rights Management ################
## First Time Run PowerShell as Admin: install-module aadrm
## Get latest module Run: update-module aadrm
## https://www.powershellgallery.com/packages/AADRM/
## Current version = 2.13.1.0, 3 May 2018


################# Microsoft Teams Portal ################
## First Time Run PowerShell as Admin: install-module -name microsoftteams
## Get latest module Run: update-module -name microsoftteams
## https://www.powershellgallery.com/packages/MicrosoftTeams/
## Current version = 0.9.3, 25 April 2018
import-module MicrosoftTeams
write-host -foregroundcolor $ProcessMessageColor "Microsoft Teams module loaded"

################# Office 365 Centralized Deployment for add ins ################
## Download and install https://www.microsoft.com/en-us/download/details.aspx?id=55267
## Version 1.2.0.0 Date = 26 April 2018

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Connect to Office 365 Online Services ################
#----------------------------------------------------------------
write-host -foregroundcolor $SystemMessageColor "`n`n`nConnecting to Microsoft Services"


## Start Exchange Online session
    Connect-ExchangeOnline
    write-host -foregroundcolor $ProcessMessageColor "Now connected to Exchange Online services"



#----------------------------------------------------------------