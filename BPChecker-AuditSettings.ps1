<#
    .Link
    Description - Gets auditing settings for all mailboxes and checks these against best practices.
    Documentation - https://github.com/directorcia/patron/wiki/Get-mailbox-audit-settings
    Source - https://github.com/directorcia/patron/blob/master/o365-mx-alert-get.ps1
    Reference - https://docs.microsoft.com/en-us/office365/securitycompliance/enable-mailbox-auditing#mailbox-actions-for-user-mailboxes-and-shared-mailboxes

    .Description
    Gets auditing settings for all mailboxes and checks these against best practices.

 
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
$OutputColor = "Green"
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

$emailloglimit = 90                            ## Retention period in days for mailbox audit logs


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -ForegroundColor $systemmessagecolor "Script started`n"

<#      Check mailboxes for auditing enabled        #>
Write-host -ForegroundColor $processmessagecolor "Check Auditing for all mailboxes"
$mailboxes = Get-Mailbox -ResultSize Unlimited
foreach ($mailbox in $mailboxes) {
    Write-Host "Mailbox = ",$mailbox.identity
    write-host "User = ",$mailbox.userprincipalname  
    if ($mailbox.AuditEnabled -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Auditing is not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Auditing is enabled"
    } 
    if ([int]$mailbox.AuditLogAgeLimit.split('.')[0] -lt $emailloglimit){            
        write-host -foregroundcolor $errormessagecolor "   Audit log age limit = ",$mailbox.AuditLogAgeLimit
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Audit log age limit = ",$mailbox.AuditLogAgeLimit
    }
    <#          Auditadmin                  #>
    write-host -foregroundcolor $processmessagecolor "`n   *** Auditadmin settings",$mailbox.identity,"***"
    if ($mailbox.Auditadmin.contains("Copy") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin Copy audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Admin Copy audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("Create") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin Create audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin Create audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("FolderBind") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin FolderBind audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin FolderBind audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("HardDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin HardDelete audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin HardDelete audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("MessageBind") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin MessageBind audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin MessageBind audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("Move") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin Move audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin Move audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("MoveToDeletedItems") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin MoveToDeletedItems audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin MovetoDeletedItems audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("SendAs") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin SendAs audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin SendAs audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("SendOnBehalf") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin SendOnBehalf audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin SendOnBehalf audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("SoftDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin SoftDelete audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin SoftDelete audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("Update") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin Update audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin Update audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("UpdateFolderPermissions") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin UpdateFolderPermissions audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin UpdateFolderPermissions audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("UpdateInboxRules") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin UpdateInboxRules audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin UpdateInboxRules audit is enabled"
    }
    if ($mailbox.Auditadmin.contains("UpdateCalendarDelegation") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Admin UpdateCalendarDelegation audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Admin UpdateCalendarDelegation audit is enabled"
    }
    <#          Auditdelegate       #>
    write-host -foregroundcolor $processmessagecolor "`n   *** Auditdelegate settings",$mailbox.identity,"***"
    if ($mailbox.Auditdelegate.contains("Create") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate Create audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate Create audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("FolderBind") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate FolderBind audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate FolderBind audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("HardDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate HardDelete audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate HardDelete audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("Move") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate Move audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate Move audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("MoveToDeletedItems") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate MoveToDeletedItems audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate MoveToDeletedItems audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("SendAs") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate SendAs audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate SendAs audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("SendOnBehalf") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate SendOnBehalf audit not enabled"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Delegate SendOnBehalf audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("SoftDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate SoftDelete audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Delegate SoftDelete audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("Update") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate Update audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Delegate Update audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("UpdateFolderPermissions") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate UpdateFolderPermissions audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Delegate UpdateFolderPermissions audit is enabled"
    }
    if ($mailbox.Auditdelegate.contains("UpdateInboxRules") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Delegate UpdateInboxRules audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Delegate UpdateInboxRules audit is enabled"
    }

    <#          AuditOwner          #>
    write-host -foregroundcolor $processmessagecolor "`n   *** AuditOwner settings",$mailbox.identity,"***"
    if ($mailbox.Auditowner.contains("Create") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner Create audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner Create audit is enabled"
    }
    if ($mailbox.Auditowner.contains("HardDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner HardDelete audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner HardDelete audit is enabled"
    }
    if ($mailbox.Auditowner.contains("Move") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner Move audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner Move audit is enabled"
    }
    if ($mailbox.Auditowner.contains("MailboxLogin") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner MailBoxLogin audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner MailBoxLogin audit is enabled"
    }
    if ($mailbox.Auditowner.contains("MoveToDeletedItems") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner MoveToDeletedItems audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner MoveToDeletedItems audit is enabled"
    }
    if ($mailbox.Auditowner.contains("SoftDelete") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner SoftDelete audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner SoftDelete audit is enabled"
    }
    if ($mailbox.Auditowner.contains("Update") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner Update audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner Update audit is enabled"
    }
    if ($mailbox.Auditowner.contains("UpdateFolderPermissions") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner UpdateFolderPermissions audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner UpdateFolderPermissions audit is enabled"
    }
    if ($mailbox.Auditowner.contains("UpdateInboxRules") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner UpdateInboxRules audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner UpdateInboxRules audit is enabled"
    }
    if ($mailbox.Auditowner.contains("UpdateCalendarDelegation") -ne $true){            
        write-host -foregroundcolor $errormessagecolor "   Owner UpdateCalendarDelegation audit not enabled"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Owner UpdateCalendarDelegation audit is enabled"
    }
    Write-Host
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------