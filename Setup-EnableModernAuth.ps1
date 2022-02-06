## Description
## Enables modern authentication for a tenant

## Source - https://github.com/directorcia/Office365/blob/master/o365-modern-auth.ps1
## https://github.com/vanvfields/Microsoft-365/blob/master/Exchange%20Online/Block-BasicAuth.ps1

## Prerequisites = 1
## 1. Ensure connected to Skype for Business onlin
## 2. Ensure connected to Exchange Online

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
##  set-executionpolicy -executionpolicy bypass -scope currentuser -force

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "green"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

write-host
$org=get-organizationconfig
write-host -ForegroundColor white "Exchange setting is currently",$org.OAuth2ClientProfileEnabled

## Run this command to enable modern authentication for Exchange Online
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
write-host -foregroundcolor $processmessagecolor "Exchange command completed"

$org=get-organizationconfig
write-host -ForegroundColor white "Exchange setting updated to",$org.OAuth2ClientProfileEnabled

write-host
$org=get-csoauthconfiguration
write-host -ForegroundColor white "Skype setting is currently",$org.clientadalauthoverride

## Run this command to enable modern authentication for Skype for Business Online
Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
write-host -foregroundcolor $processmessagecolor "Skype command completed"

$org=get-csoauthconfiguration
write-host -ForegroundColor white "Skype setting updated to",$org.clientadalauthoverride
write-host

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------