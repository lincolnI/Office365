#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$ErrorColor = "Red"
$error.clear()

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$RegularUsers = ($Mailboxes | Where-Object {$_.RecipientTypeDetails -eq 'UserMailbox'}).UserPrincipalName


#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Get-Mailbox -identity $name | set-mailbox -type “Shared”

read-host "Are you sre you would like to convert all mailboxes in this tenant to Shared Mailboxes"
Pause

Try { 

    Foreach ($User in $RegularUsers){
        Set-Mailbox -identity $User -Type Shared
     }
} 
Catch { 
Write-Host -foregroundcolor $ErrorColor "`n...Error converting $name"
"     " 
$error
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------