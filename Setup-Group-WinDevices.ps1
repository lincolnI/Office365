<#
    .Link
    https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadgroup?view=azureadps-2.0

    .Notes
    Make sure:
    1. Installed this Module: Install-Module -Name AzureADPreview -RequiredVersion 2.0.2.17	-allowclobber -force
    2. Import-Module AzureADPreview
    3. Connect-AzureAD

    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
    Set-Executionpolicy remotesigned

#>


#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$OutputColor = "Green"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$GroupName = "AAD - Windows Devices"
$GroupDescription = "Dynamic Group for Windows devices (to be used with Autopilot and Intune)"
$MemberRule = "(device.deviceOSType -contains ""Windows"")"

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Unload the AzureAD module (or continue if it's already unloaded)
Remove-Module AzureAD -ErrorAction SilentlyContinue
# Load the AzureADPreview module
Import-Module AzureADPreview
#Import-Module AzureAD
Connect-AzureAD

#Create Group:
New-AzureADMSGroup -DisplayName $GroupName -Description $GroupDescription -MailEnabled $False -MailNickName $False -SecurityEnabled $True -GroupTypes "DynamicMembership" -MembershipRule $MemberRule -MembershipRuleProcessingState "On"

#Disconnect from AAD Session:
Disconnect-AzureAD

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------