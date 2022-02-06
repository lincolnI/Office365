## Display all mailbox SMTP addresses in tidy format

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"

$mailboxes=(get-recipient)
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

foreach ($mailbox in $mailboxes)
{
    write-host -foregroundcolor $OutputColor "Alias =",$mailbox.name 
    write-host "Primary =",$mailbox.primarysmtpaddress
    foreach ($n in $mailbox.emailaddresses) {
        if ($n -clike 'smtp*')
        {
            write-host "Alternate =",($n -replace ".*:")
        }
    }
Write-output ""
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------