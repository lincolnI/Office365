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
$name = read-host "Enter the username of the mailbox to convert to shared"

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Get-Mailbox -identity $name | set-mailbox -type “Shared”

Try { 
Set-Mailbox -identity $name -type "Shared" -EA Stop
Write-Host -foregroundcolor $OutputColor "`n...$name has been converted to a Shared Mailbox"
} 
Catch { 
Write-Host -foregroundcolor $ErrorColor "`n...Error converting $name"
"     " 
$error
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------