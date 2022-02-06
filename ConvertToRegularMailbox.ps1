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
$Name = read-host "Enter the username of the shared mailbox to convert to full mailbox"

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Get-Mailbox -identity $name | set-mailbox -type “Shared”

Try { 
Set-Mailbox $Name -Type Regular -EA Stop
Write-Host -foregroundcolor $OutputColor "`n...$Name has been converted to a Regular Mailbox"
} 
Catch { 
Write-Host -foregroundcolor $ErrorColor "`n...Error converting $Name"
"     " 
$error
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------