## Description
## Script designed to log into the Exchange Online Admin portal

## Prerequisites = 1
## 1. Ensure msonline module installed or updated

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$savedcreds=$true                      ## false = manually enter creds, True = from file
$Tenant = @(Get-ChildItem C:\relianceit\PowerShell | Out-GridView -Title 'Choose a file' -PassThru)   ## Location of Stored Cred
$credpath = "$Tenant"   ## local file with credentials if required
$SCCConnect = Read-Host "`nWould you like to connect to Office 365 Security & Compliance Center (Y\N)?"
$AzureConnect = Read-Host "`nWould you like to connect to Azure Services (Y\N)?"
$TeamsConnect = Read-Host "`nWould you like to connect to Teams Services (Y\N)?"
$AddinsConnect = Read-Host "`nWould you like to connect to Office365 Centralized Deployment for add ins (Y\N)?"

## See in SharePoint Section ## $tenantname= Read-Host 'What is your .onmicrosoft.com Tenant Name?' ## For SHarePointAdmin URL for tenant
## See in SharePoint Section ## $tenanturl= "https://$tenantname-admin.sharepoint.com" ## SharePoint Admin URL for tenant
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
write-host -foregroundcolor Cyan "`nLoading Required Modules"

## set-executionpolicy remotesigned
## May be required once to allow ability to runs scripts in PowerShell

################# Office 365 Admin, Exchange and Security & Compliance Center Online Portal ################
## First Time Run PowerShell as Admin: install-module msonline
## Get latest module Run: update-module msonline
import-module msonline
write-host -foregroundcolor green "MSOnline module loaded"


################# SharePoint Online Portal ################
## Download and install https://www.microsoft.com/en-au/download/details.aspx?id=35588 (SharePoint Online Module)
## Current version = 16.0.7813.1200, 27 June 2018
#import-module microsoft.online.sharepoint.powershell -disablenamechecking
#write-host -foregroundcolor green "SharePoint Online module loaded"


################# Azure AD Portal ################
## First Time Run PowerShell as Admin: install-module azuread
## Get latest module Run: update-module azuread 
## https://www.powershellgallery.com/packages/AzureAD/
## Current version = 2.0.1.16, 21 June 2018
import-module azuread
write-host -foregroundcolor green "AzureAD module loaded"


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
write-host -foregroundcolor green "Microsoft Teams module loaded"

################# Office 365 Centralized Deployment for add ins ################
## Download and install https://www.microsoft.com/en-us/download/details.aspx?id=55267
## Version 1.2.0.0 Date = 26 April 2018

#----------------------------------------------------------------



#----------------------------------------------------------------
################# Import Credetials ################
#----------------------------------------------------------------
## Get tenant login credentials
if ($savedcreds) {
    ## Get creds from local file
    $cred =import-clixml -path c:\relianceit\Powershell\$credpath
}
else {
    ## Get creds manually
    $cred=get-credential 
}
#----------------------------------------------------------------



#----------------------------------------------------------------
################# Connect to Office 365 Online Services ################
#----------------------------------------------------------------
write-host -foregroundcolor Cyan "`n`n`nConnecting to Microsoft Services"

## Connect to Office 365 admin service
    connect-msolservice -credential $cred
    write-host -foregroundcolor green "Now connected to Office 365 Admin service"

## Start Exchange Online session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxyMethod=RPS -Credential $Cred -Authentication Basic -AllowRedirection
    import-PSSession $Session
    write-host -foregroundcolor green "Now connected to Exchange Online services"

## Connect to SharePoint Online Service
    ### Version 1
        ## $domains = Get-MsolDomain
        ## write-host "`nCurrent Domains:`n" $domains.name -ForegroundColor White -BackgroundColor DarkGreen
        ## $tenantname= Read-Host "`nWhat is your .onmicrosoft.com Tenant Name?" ## For SHarePointAdmin URL for tenant
    ### Version 2
        ## $OnMicrosoftDomain = (Get-MsolDomain | Where-Object {$_.Name -Like "*onmicrosoft.com*"}).name
        ## $TenantID = $OnMicrosoftDomain -replace ‘.onmicrosoft.com’
        ## $tenanturl= "https://$TenantID-admin.sharepoint.com" ## SharePoint Admin URL for tenant
### Version 3
    $InitialDomain = Get-MsolDomain | Where-Object {$_.IsInitial -eq $true}
    $tenanturl = "https://$($InitialDomain.Name.Split(".")[0])-admin.sharepoint.com"
    connect-sposervice -url $tenanturl -credential $cred
    write-host -foregroundcolor green "Now connected to SharePoint Online services"


#----------------------------------------------------------------
################# Optional Online Services ################
#----------------------------------------------------------------

## Connect to the Office 365 Security and Compliance Center
If ($SCCConnect -eq "y") {
        Write-Output "Getting the Security & Compliance Center cmdlets"
        $SessionCC = New-PSSession -ConfigurationName Microsoft.Exchange `
            -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ `
            -Credential $cred -Authentication Basic -AllowRedirection

        Import-PSSession $SessionCC
        write-host -foregroundcolor green "Now connected to Office 365 Security and Compliance Center"
    }

## Connect to Microsoft Teams service
    If ($TeamsConnect -eq "y") {
        Connect-MicrosoftTeams -credential $cred
        write-host -foregroundcolor green "Now connected to Microsoft Teams Service"
    }

## Connect to AzuerAD service
## Connect to Azure AD Rights Management Service
    If ($AzureConnect -eq "y") {
        Connect-azuread -credential $cred
        write-host -foregroundcolor green "Now connected to Azure AD Service"

        connect-aadrmservice -credential $cred
        write-host -foregroundcolor green "Now connected to the Azure AD Rights Management Service"
    }

## Connect to Microsoft Teams service
    If ($AddinsConnect -eq "y") {
        Connect-OrganizationAddInService -credential $cred
        write-host -foregroundcolor Green "Now connected to Office 365 Centralized Deployment"
    }

    
write-host "`n`nALL OFFICE 365 SERVICE ARE CONNECTED" -ForegroundColor White -BackgroundColor DarkGreen

#----------------------------------------------------------------