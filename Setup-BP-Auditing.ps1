<#
    .Link
    https://github.com/directorcia/patron/blob/master/o365-audit-enable.ps1

    .Description
    Enabled auditing in tenant. Unified audit log plus Exchange mailbox logging
 
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$emailloglimit = 180
$script_debug=$false         ## pause after each stage and wait for key press. Set to $false to disable


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

## Enable audit log search
## enable-organizationcustomization maybe required in some circumstances prior to successfully running this command
Write-host -ForegroundColor $processmessagecolor "Start - Enable Audit Log Search"
Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
Write-host -ForegroundColor $processmessagecolor "Start - Enable Audit Log Search`n"

If ($script_debug) {Read-Host -Prompt "Press Enter to continue"}

## Enable audit logging for all user mailboxes
Write-host -ForegroundColor $processmessagecolor "Start - Enable Auditing for all mailboxes"
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -AuditEnabled $true
Write-host -ForegroundColor $processmessagecolor "Finish - Enable Auditing for all mailboxes`n"

If ($script_debug) {Read-Host -Prompt "Press Enter to continue"}

## Mailbox auditing actions - https://support.office.com/en-us/article/enable-mailbox-auditing-in-office-365-aaca8987-5b62-458b-9882-c28476a66918#ID0EABAAA=Mailbox_auditing_actions
Write-host -ForegroundColor $processmessagecolor "Start - Enable Full Auditing actions for all mailboxes"
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -Auditadmin @{Add="Copy","Create","FolderBind","HardDelete","MessageBind","Move","MoveToDeletedItems","SendAs","SendOnBehalf","SoftDelete","Update","UpdateFolderPermissions","UpdateInboxRules","UpdateCalendarDelegation"}

Get-Mailbox -ResultSize Unlimited | Set-Mailbox –Auditdelegate @{Add="Create","FolderBind","HardDelete","Move","MoveToDeletedItems","SendAs","SendOnBehalf","SoftDelete","Update","UpdateFolderPermissions","UpdateInboxRules"}
## "UpdateInboxRules","UpdateCalendarDelegation" currently produce an error but actually get set. Expect fix July 2018

Get-Mailbox -ResultSize Unlimited | Set-Mailbox –Auditowner @{Add="Create","HardDelete","Move","Mailboxlogin","MoveToDeletedItems","SoftDelete","Update","UpdateFolderPermissions","UpdateInboxRules","UpdateCalendarDelegation"}
Write-host -ForegroundColor $processmessagecolor "Finish - Enable Full Auditing actions for all mailboxes`n"

If ($script_debug) {Read-Host -Prompt "Press Enter to continue"}

## Extend audit log beyond the default 90 days 
Write-host -ForegroundColor $processmessagecolor "Start - Extend mailbox audit log limit to ",$emailloglimit,"days"
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -AuditLogAgeLimit $emailloglimit
Write-host -ForegroundColor $processmessagecolor "Finish - Extend mailbox audit log limit`n"

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------