#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$systemmessagecolor = "green"
$usermessagecolor = "cyan"
#----------------------------------------------------------------

#----------------------------------------------------------------
################# Function to choose Module Install ################
#----------------------------------------------------------------
function 365ModulesMenu
{
    param
    (
        [string]$ADSyncMenuTitle = '365 Modules'
    )

    Clear-Host
    Write-Host '================' $ADSyncMenuTitle '================'
    Write-Host '1: Install 365 Modules'
    Write-Host '2: Update 365 Modules'
    Write-Host 'q: Quit'

    $Input = Read-Host 'Please select an option'
    If ($Input -eq '1')
    {
        InstallMenu
    }
    ElseIf ($Input -eq '2')
    {
        UpdateMenu
    }
    ElseIf ($Input -eq 'q')
    {
        Exit
    }
    Else
    {
        Write-Host 'Invalid selection'
        365ModulesMenu
    }
}

#----------------------------------------------------------------
################# Function to run Delta Sync ################
#----------------------------------------------------------------
function InstallMenu
{
    Clear-Host
    write-host -foregroundcolor $systemmessagecolor "Module Install Started`n"

    Install-Module PowershellGet -Force
    write-host -foregroundcolor $usermessagecolor "PowerShellGet Module Installed"

    Install-module msonline -force
    write-host -foregroundcolor $usermessagecolor "MSOnline Module Installed"

    Install-Module -Name ExchangeOnlineManagement -Force
    write-host -foregroundcolor $usermessagecolor "MSOnline v2 Module Installed"

    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -force
    write-host -foregroundcolor $usermessagecolor "SharePoint Module Installed"

    Install-module azuread -force #-allowclobber
    write-host -foregroundcolor $usermessagecolor "AzureAD Module Installed"

    Install-module -name aipservice -Force #-AllowClobber
    write-host -foregroundcolor $usermessagecolor "Azure Information Protection module Updated"

    Install-Module Az -force #-allowclobber
    Install-Module -Name AzureAD -force #-allowclobber
    write-host -foregroundcolor $usermessagecolor "Azure Module Installed"

    Install-Module aadrm -force
    write-host -foregroundcolor $usermessagecolor "AADRM Module Installed"

    Install-Module -name microsoftteams -force
    write-host -foregroundcolor $usermessagecolor "Microsoft Teams Module Installed"

    Install-Module -name MicrosoftGraphSecurity -force
    write-host -foregroundcolor $usermessagecolor "Microsoft Graph Security Module Installed"

    Install-Module Microsoft.Graph.Intune -force
    write-host -foregroundcolor $usermessagecolor "Microsoft Graph Intune Module Installed"

    write-host -foregroundcolor $systemmessagecolor "`nAll Module Installed, Take note of any errors or warnings`n"

    $Input = Read-Host 'Would you like to run the install again (Y\N)?'

    If ($Input -eq 'y')
    {
        InstallMenu
    }
    ElseIf ($Input -eq 'n')
    {
        365ModulesMenu
    }
    Else
    {
        Write-Host 'Invalid selection'
        InstallMenu
    }
}

#----------------------------------------------------------------
################# Function to run Full sync ################
#----------------------------------------------------------------
function UpdateMenu
{
    Clear-Host
    write-host -foregroundcolor $systemmessagecolor "Module Install Started`n"

    Update-Module PowershellGet -Force
    write-host -foregroundcolor $usermessagecolor "PowerShellGet Module Updated"

    Update-Module -Name ExchangeOnlineManagement -force
    write-host -foregroundcolor $usermessagecolor "MSOnline v2 Module Updated"

    Update-module msonline -force #-allowclobber
    write-host -foregroundcolor $usermessagecolor "MSOnline Module Updated"

    Update-module -Name Microsoft.Online.SharePoint.PowerShell -force
    write-host -foregroundcolor $usermessagecolor "SharePoint Module Updated"

    Update-module -name aipservice -Force
    write-host -foregroundcolor $usermessagecolor "Azure Information Protection module Updated"

    Update-module azuread -force
    write-host -foregroundcolor $usermessagecolor "AzureAD Module Updated"

    Update-Module Az -force #-allowclobber
    Update-Module -Name AzureAD -force #-allowclobber
    write-host -foregroundcolor $usermessagecolor "Azure Module Updated"

    Update-module aadrm -force
    write-host -foregroundcolor $usermessagecolor "AADRM Module Updated"

    Update-module -name microsoftteams -force
    write-host -foregroundcolor $usermessagecolor "MicrosoftTeams Module Updated"

    Update-Module -name MicrosoftGraphSecurity -force
    write-host -foregroundcolor $usermessagecolor "Microsoft Graph Security Module Updated"

    Update-Module Microsoft.Graph.Intune -force
    write-host -foregroundcolor $usermessagecolor "Microsoft Graph Intune Module Updated"

    write-host -foregroundcolor $systemmessagecolor "`nAll Module Updated, Take note of any errors or warnings`n"

    $Input = Read-Host 'Would you like to run the update again (Y\N)?'

    If ($Input -eq 'y')
    {
        UpdateMenu
    }
    ElseIf ($Input -eq 'n')
    {
        365ModulesMenu
    }
    Else
    {
        Write-Host 'Invalid selection'
        UpdateMenu
    }
}

#----------------------------------------------------------------
################# Start of program ################
#----------------------------------------------------------------
Clear-Host
365ModulesMenu

#----------------------------------------------------------------

#Install-module msonline -force
#Install-module azuread -force
#Install-module aadrm -force
#Install-module -name microsoftteams -force