## Display all mailbox SMTP addresses in tidy format

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$mailboxes=(get-recipient)
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------

Clear-Host

write-host -foregroundcolor Cyan "`nScript started`n`n"

foreach ($mailbox in $mailboxes)
{
    write-host -foregroundcolor green "Alias =",$mailbox.name 
    write-host "Primary =",$mailbox.primarysmtpaddress
    foreach ($n in $mailbox.emailaddresses) {
        if ($n -clike 'smtp*')
        {
            write-host "Alternate =",($n -replace ".*:")
        }
    }
Write-output ""
}

write-host -foregroundcolor Cyan "`nScript complete`n"
#----------------------------------------------------------------