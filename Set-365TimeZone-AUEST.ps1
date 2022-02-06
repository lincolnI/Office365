<#
    .Link

    .Description
    Set all mailboxes to English (Australia) and Sydney EST timezone
 
    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
        Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
        Set-Executionpolicy remotesigned
        Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force

    Disconnect PowerShell Sessions:
    - Get-PSSession | Remove-PSSession

#>

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Mailboxes = Get-Mailbox -ResultSize Unlimited


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

#----------------------------------------------------------------
#### To set all mailboxes to English (Australia) and Sydney EST timezone ####
## get-mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language 3081 -TimeZone "AUS Eastern Standard Time"

write-host -foregroundcolor $SystemMessageColor "`nStart - Setting All Mailboxes to English (Australia) and Sydney EST Timezone`n"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-MailboxRegionalConfiguration -identity $UPN -Language 3081 -TimeZone "AUS Eastern Standard Time" -DateFormat "dd/MM/yyyy"
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Setting All Mailboxes to English (Australia) and Sydney EST Timezone`n"
#----------------------------------------------------------------

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------