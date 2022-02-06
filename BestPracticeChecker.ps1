## Description
## Script designed to check and report the status of mailbox in the tenant

## Prerequisites = 2
## 1. Connect to Office 365 tenant (MSOnline)
## 2. Connected to Exchange Online

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$auditlogagelimitdefault = 90
$retaindeleteditemsfordefault = 14
$systemmessagecolor = "cyan"

$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Day = (Get-Date).Day
$Month = (Get-Date).Month
$Year = (Get-Date).Year
$ReportName = ( "$Year" + "-" + "$Month" + "-" + "$Day" + "-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$mailboxfile = Join-Path -Path $ReportPath -ChildPath "$ReportName-Mailbox.csv"      ## mailbox output file
$mailboxfile2 = Join-Path -Path $ReportPath -ChildPath "$ReportName-CASMailbox.csv"     ## casmailbox output file
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

write-host -foregroundcolor $systemmessagecolor "Script started"

## Check and delete existing export file
if ([system.io.file]::exists($mailboxfile)) {
    remove-item $mailboxfile
    write-host -ForegroundColor $systemmessagecolor "Deleted old file",$mailboxfile
}

if ([system.io.file]::exists($mailboxfile2)) {
    remove-item $mailboxfile2
    write-host -ForegroundColor $systemmessagecolor "Deleted old file",$mailboxfile2
}
    
## set-executionpolicy remotesigned
## May be required once to allow ability to runs scripts in PowerShell

write-host -ForegroundColor $systemmessagecolor "Getting Mailboxes"
$mailboxes=get-mailbox -ResultSize unlimited
write-host -ForegroundColor $systemmessagecolor "Start checking mailboxes"
write-host
foreach ($mailbox in $mailboxes){
    write-host -foregroundcolor yellow -BackgroundColor Black "Mailbox =",$mailbox.displayname
    
    ## each mailbox should have auditing enabled
    
    if ($mailbox.auditenabled) {
        write-host -foregroundcolor green "  Audit enabled =",$mailbox.AuditEnabled
    } else {
        write-host -foregroundcolor red "  Audit enabled =",$mailbox.AuditEnabled
    }

    ## each mailbox should have the audit log limit extended beyond the default

    if ([timespan]::parse($mailbox.auditlogagelimit) -gt $auditlogagelimitdefault) {
        write-host -foregroundcolor green "  Audit login limit (days)",$mailbox.Auditlogagelimit
    } else {
        write-host -foregroundcolor red "  Audit login limit (days)",$mailbox.Auditlogagelimit
    }

    ## each mailbox should have deleted items retention extended to the maximum of 30 days

    if ([timespan]::parse($mailbox.retaindeleteditemsfor) -gt $retaindeleteditemsfordefault) {
        write-host -foregroundcolor green "  Retain Deleted items for (days) =",$mailbox.retaindeleteditemsfor
    } else {
        write-host -foregroundcolor red "  Retain Deleted items for (days) =",$mailbox.retaindeleteditemsfor
    }

    ## mailboxes should not be forwarding to other email addresses

    if ($mailbox.forwardingaddress -ne $null){
        write-host -foregroundcolor red "  Forwarding address =",$mailbox.forwardingaddress
    }
    if ($mailbox.forwardingsmtpaddress -ne $null){
        write-host -foregroundcolor red "  Forwarding SMTP address =",$mailbox.forwardingsmtpaddress
    }

    ## mailboxes should have litigation hold enabled

    if ($mailbox.LitigationHoldEnabled) {
        write-host -foregroundcolor green "  Litigation hold =",$mailbox.litigationholdenabled
    } else {
        write-host -foregroundcolor red "  Litigation hold =",$mailbox.litigationholdenabled
    }

    ## mailboxes should have archiving enabled

    if ($mailbox.archivestatus -eq "active") {
        Write-host -foregroundcolor Green "  Archive status =",$mailbox.archivestatus
    } else {
        Write-host -foregroundcolor red "  Archive status =",$mailbox.archivestatus
    }

    ## report mailbox maximum send and receive size

    Write-host "  Max send size =",$mailbox.maxsendsize
    write-host "  Max receive size =",$mailbox.maxreceivesize
    $extramailbox=get-casmailbox -Identity $mailbox.displayname

    ## mailboxes should not have POP3 enabled

    if (-not $extramailbox.popenabled) {
        write-host -foregroundcolor green "  POP3 enabled =",$extramailbox.popenabled
    } else {
        write-host -foregroundcolor red "  POP3 enabled =",$extramailbox.popenabled
    }

    ## mailboxes should not have IMAP enabled

    if (-not $extramailbox.ImapEnabled) {
        write-host -foregroundcolor green "  IMAP enabled =",$extramailbox.imapenabled
    } else {
        write-host -foregroundcolor red "  IMAP enabled =",$extramailbox.imapenabled
    }

    ## Export mailbox results to CSV
    $mailbox | Select Displayname,auditenabled,auditadmin,auditdelegate,auditowner,auditlogagelimit,retaindeleteditemsfor,forwardingaddress,formwardingsmtpaddress,litigationholdenabled,archivestatus,maxsendsize,maxreceivesize | export-csv -path $mailboxfile -notypeinformation -append
    $extramailbox | select DisplayName,ActiveSyncEnabled,ImapEnabled,PopEnabled,OwaMailboxPolicy | export-csv -path $mailboxfile2 -notypeinformation -append
    write-host
}
write-host -ForegroundColor $systemmessagecolor "Finish checking mailboxes"
write-host -ForegroundColor $systemmessagecolor "Check tenant settings"
write-host
$domain=get-remotedomain default 

## auto forwarding for the domain should be disabled

if (-not $domain.AutoForwardEnabled) {
    Write-host -foregroundcolor green "Domain email auto forward is set to",$domain.AutoForwardEnabled
} else {
    Write-host -foregroundcolor red "Domain email auto forward is set to",$domain.AutoForwardEnabled
}
$corp = Get-MsolCompanyInformation

## users shoul dnot be allowed to approve add ins

if (-not $corp.UsersPermissionToUserConsentToAppEnabled) {
    write-host -foregroundcolor green "Users are allowed to enable store apps is set to",$corp.UsersPermissionToUserConsentToAppEnabled
} else {
    write-host -foregroundcolor red "Users are allowed to enable store apps is set to",$corp.UsersPermissionToUserConsentToAppEnabled
}
$corplogs = get-adminauditlogconfig

## audit logs for the tenant should be enabled

if ($corplogs.unifiedauditlogingestionenabled) {
    write-host -foregroundcolor green "Tenant audit logs are enabled is",$corplogs.unifiedauditlogingestionenabled
} else {
    write-host -foregroundcolor red "Tenant audit logs are enabled is",$corplogs.unifiedauditlogingestionenabled
}
write-host "Audit log age limit is",$corplogs.adminauditlogagelimit
write-host
write-host -ForegroundColor Cyan "Finish checking tenant"

write-host -foregroundcolor green "`nFile $mailboxfile and $mailboxfile2 Created"
Invoke-Item $ReportPath

write-host -ForegroundColor $systemmessagecolor "Finish script"

#----------------------------------------------------------------