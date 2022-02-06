<#
    .Link
    https://gcits.com/knowledge-base/block-inbox-rules-forwarding-mail-externally-office-365-using-powershell/
    https://gcits.com/knowledge-base/find-inbox-rules-forward-mail-externally-office-365-powershell/
    https://o365info.com/forward-mail-powershell-commands-quick/#SUB-3

    .Description
    Script designed to check which email boxes have forwarding options set

    Disable (cancel) ADMIN Forwarding (ForwardingAddress) ALL MAILBOXES (BULK mode)
    PowerShell command Example:
    Get-Mailbox -ResultSize Unlimited| Where-Object {($_.ForwardingAddress -ne $Null) } | Set-Mailbox -ForwardingAddress $Null


    Disable (cancel) USER Forwarding (ForwardingsmtpAddress) ALL MAILBOXES (BULK mode)
    PowerShell command Example:
    Get-Mailbox -ResultSize Unlimited | Where-Object {($_.ForwardingsmtpAddress -ne $Null) } | Set-Mailbox -ForwardingsmtpAddress $Null
 
    .Notes
    Prerequisites = 1
        1. Ensure connection to Exchange Online has already been completed
    
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
$ProcessMessageColor = "Green"
$OutputColor = "Green"
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UserName = Read-Host -Prompt 'Enter Email of User to Check'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "OutlookRules-" + $UserName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$outputfile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}



## Get all mailboxes
get-inboxrule -mailbox $UserName | select-object mailboxownerid, name, Description, enabled, From, redirecto, forwardto, copyfolderto, SentTo , deletemessage,forwardasattachmentto, MoveToFolder ,sendtextmessagenotificationto | export-csv $outputfile -notypeinformation -append



write-host -foregroundcolor $OutputColor "`nFile $outputfile Created"
Invoke-Item $ReportPath
Invoke-Item $outputfile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------