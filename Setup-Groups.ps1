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
$DynamicGroupNames = @(
    "AAD - Autopilot"
)
$DynamicGroupDescriptions = @(
    "Dynamic Group for Autopilot devices (to be used with Autopilot)"
)
$DynamicMemberRules = @(
    "(device.devicePhysicalIDs -any _ -contains ""[ZTDId]"")"
)

$AssignedGroupNames = @(
    "AAD - Intune Exclude",
    "AAD - Intune Test",
    "AAD - USB Exclude",
    "AAD - Windows Hello",
    "AAD - MFA Exclude"
)
$AssignedGroupDescriptions = @(
    "Exclude assigned users/devices from Intune Policies",
    "Canary Group for new Intune policies",
    "Exclude assigned users from USB Control policies",
    "Windows Hello assigned users",
    "Excluded group from MFA"
)

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

#Create Groups:
if ($DynamicGroupNames.Count -gt 0)
{
    for ($i = 0; $i -lt $DynamicGroupNames.Count; $i++ )
    {
        New-AzureADMSGroup -DisplayName $DynamicGroupNames[$i] -Description $DynamicGroupDescriptions[$i] -MailEnabled $False -MailNickName $False -SecurityEnabled $True -GroupTypes "DynamicMembership" -MembershipRule $DynamicMemberRules[$i] -MembershipRuleProcessingState "On"
    }
}

if ($AssignedGroupNames.Count -gt 0)
{
    for ($j = 0; $j -lt $AssignedGroupNames.Count; $j++ )
    {
        New-AzureADGroup -DisplayName $AssignedGroupNames[$j] -Description $AssignedGroupDescriptions[$j] -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
    }
}

#Disconnect from AAD Session:
Disconnect-AzureAD

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------