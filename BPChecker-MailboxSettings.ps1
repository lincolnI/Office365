<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Report-on-mailbox-settings
    Source - https://github.com/directorcia/patron/blob/master/o365-mx-audit-get.ps1

    .Description
    Display details for all mailboxes

 
    .Notes
    Prerequisites = 1
        1. Ensure connected to Exchange Online

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
$ErrorMessageColor = "Red"

$script_debug = $true                           ## pause after each stage and wait for key press. Set to $false to disable


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -ForegroundColor $systemmessagecolor "Script started`n"

$mailboxes=get-mailbox -ResultSize unlimited
write-host -ForegroundColor $systemmessagecolor "Start checking mailboxes`n"
write-host
foreach ($mailbox in $mailboxes){
    write-host -foregroundcolor yellow -BackgroundColor Black "Mailbox =",$mailbox.displayname

## Report mailbox maximum send and receive sizes
    write-host "  User Principal Name =",$mailbox.userprincipalname
    write-host "  When mailbox created =", $mailbox.whenmailboxcreated
    if ($mailbox.isshared) {
        write-host -foregroundcolor yellow "  Shared mailbox =",$mailbox.isshared
    } else {
        write-host -foregroundcolor $processmessagecolor "  Shared mailbox =",$mailbox.isshared
    }
    $size = get-mailboxstatistics $mailbox.userprincipalname
    Write-host "  Mailbox size =",$size.totalitemsize 
    write-host "  Mailbox items =",$size.itemcount
    write-host "  Total deleted size",$size.TotalDeletedItemSize

    ## Report mailbox maximum send and receive sizes

    Write-host "  Max send size =",$mailbox.maxsendsize
    write-host "  Max receive size =",$mailbox.maxreceivesize
    $extramailbox = get-casmailbox -Identity $mailbox.userprincipalname

    ## Mailboxes should have their retained deleted item retention period extended to 30 days

    if ([timespan]::parse($mailbox.retaindeleteditemsfor).days -gt $retaindeleteditemsfordefault) {
        write-host -foregroundcolor $processmessagecolor "  Retain Deleted items for (days) =",$mailbox.retaindeleteditemsfor
    } else {
        write-host -foregroundcolor $errormessagecolor "  Retain Deleted items for (days) =",$mailbox.retaindeleteditemsfor
    }

    ## Mailboxes should not be forwarding to other email addresses

    if ($mailbox.forwardingaddress -ne $null){
        write-host -foregroundcolor $errormessagecolor "  Forwarding address =",$mailbox.forwardingaddress
    }
    if ($mailbox.forwardingsmtpaddress -ne $null){
        write-host -foregroundcolor $errormessagecolor "  Forwarding SMTP address =",$mailbox.forwardingsmtpaddress
    }

    ## Mailboxes should have litigation hold enabled

    if ($mailbox.LitigationHoldEnabled) {
        write-host -foregroundcolor $processmessagecolor "  Litigation hold =",$mailbox.litigationholdenabled
    } else {
        write-host -foregroundcolor $errormessagecolor "  Litigation hold =",$mailbox.litigationholdenabled
    }

    ## Mailboxes should have archive enabled

    if ($mailbox.archivestatus -eq "active") {
        Write-host -foregroundcolor $processmessagecolor "  Archive status =",$mailbox.archivestatus
    } else {
        Write-host -foregroundcolor $errormessagecolor "  Archive status =",$mailbox.archivestatus
    }

    ## Mailboxes should not have POP3 enabled

    if (-not $extramailbox.popenabled) {
        write-host -foregroundcolor $processmessagecolor "  POP3 enabled =",$extramailbox.popenabled
    } else {
        write-host -foregroundcolor $errormessagecolor "  POP3 enabled =",$extramailbox.popenabled
    }

    ## mailboxes should not have IMAP enabled

    if (-not $extramailbox.ImapEnabled) {
        write-host -foregroundcolor $processmessagecolor "  IMAP enabled =",$extramailbox.imapenabled
    } else {
        write-host -foregroundcolor $errormessagecolor "  IMAP enabled =",$extramailbox.imapenabled
    }
    write-host
    If ($script_debug) {Read-Host -Prompt "Press Enter to continue"}
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------