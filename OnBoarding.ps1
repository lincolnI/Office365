#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"


$Mailboxes = Get-Mailbox -ResultSize Unlimited
$LitigationUsers = ($Mailboxes | Where-Object {$_.LitigationHoldEnabled -eq $false}).UserPrincipalName
#$DeleteItems = ($Mailboxes | Where-Object {$_.retaindeleteditemsfor -ne 30}).UserPrincipalName
#$CASMailboxes = Get-Casmailbox -ResultSize Unlimited
#$PopUsers = ($CASMailboxes | Where-Object {$_.popenabled -eq $true}).UserPrincipalName
#$IMAPUsers = ($CASMailboxes | Where-Object {$_.popenabled -eq $true}).UserPrincipalName
$AuditMailbox = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} 
$FiveTB = 5242880

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

write-host -foregroundcolor Black -BackgroundColor White "`n`n`nScript Started"
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Office 365 Best Practice ################
#----------------------------------------------------------------
#### Enable legal hold mailboxes for all users ####
##get-mailbox | set-mailbox -litigationholdenabled $true

write-host -foregroundcolor $SystemMessageColor "`n`nEnabling Legal Hold on All Mailboxes"
Foreach ($User in $LitigationUsers){
    Set-Mailbox -identity $User -LitigationHoldEnabled:$true
 }
write-host -foregroundcolor $SystemMessageColor "`nLegal Hold Enabled for all Eligable Mailboxes"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable global audit logging ####
## Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems

write-host -foregroundcolor $SystemMessageColor "`n`nEnabling Global Audit Logging"
Foreach ($user in $AuditMailbox)
{
$UPN = $user.UserPrincipalName
    Set-Mailbox -identity $UPN -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems
 }
write-host -foregroundcolor $SystemMessageColor "`nGlobal Audit Logging Enabled"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable 180 Day Audit log ####
## write-host -foregroundcolor $SystemMessageColor "Enabling 180 Day Audit log"
## Get-Mailbox -ResultSize Unlimited | Set-Mailbox -AuditLogAgeLimit 180
## write-host -foregroundcolor $SystemMessageColor "180 Day Audit log Enabled"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Set all mailboxes to maximum 30 days deleted items ####
## Get-mailbox | set-mailbox -retaindeleteditemsfor 30

write-host -foregroundcolor $SystemMessageColor "`n`nChanging All Mailboxes to Maximum 30 Days Deleted Items"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-Mailbox -identity $UPN -retaindeleteditemsfor 30
 }
write-host -foregroundcolor $SystemMessageColor "`n30 Days Deleted Items Enabled on All Mailboxes"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable auto-expanding archiving for organisation ####

If ($FirstTime -eq "N") {
write-host -foregroundcolor $SystemMessageColor "`n`nEnabling Auto-Expanding Archiving for Organisation"
Set-OrganizationConfig -AutoExpandingArchive
write-host -foregroundcolor $SystemMessageColor "`nAuto-Expanding Archiving Enabled for Organisation"
}
#----------------------------------------------------------------

#----------------------------------------------------------------
#### To set all mailboxes to English (Australia) and Sydney EST timezone ####
## get-mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language 3081 -TimeZone "AUS Eastern Standard Time"

write-host -foregroundcolor $SystemMessageColor "`n`nSetting All Mailboxes to English (Australia) and Sydney EST Timezone"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-MailboxRegionalConfiguration -identity $UPN -Language 3081 -TimeZone "AUS Eastern Standard Time" -DateFormat "dd/MM/yyyy"
 }
write-host -foregroundcolor $SystemMessageColor "`nAll Mailboxes Set to English (Australia) and Sydney EST Timezone"
#----------------------------------------------------------------


#----------------------------------------------------------------
#### Turn Focused Inbox Off in your organization ####
## https://docs.microsoft.com/en-us/office365/admin/setup/configure-focused-inbox?view=o365-worldwide ##

write-host -foregroundcolor $SystemMessageColor "`n`nTurning Focused Inbox Off in your organizatione"
Set-OrganizationConfig -FocusedInboxOn $false
write-host -foregroundcolor $SystemMessageColor "`nFoced Inbox has been turned Off in Tenant"
#----------------------------------------------------------------


<#----------------------------------------------------------------
#### Enable modern authentication in Exchange Online ####

write-host -foregroundcolor $SystemMessageColor "`n`nEnabling Modern Authentication in Exchange Online"
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
write-host -foregroundcolor $SystemMessageColor "`nModern Authentication Enabled in Exchange Online"
#----------------------------------------------------------------#>

<#----------------------------------------------------------------
#### Disable users ability to add apps to their environment e.g. can't add store apps to Outlook ###
## http://blog.ciaops.com/2018/07/thwarting-office-365-ransomware-cloud.html

write-host -foregroundcolor $SystemMessageColor "`n`nDisabling Users Ability to Add Apps"
Set-MsolCompanysettings -UsersPermissionToUserConsentToAppEnabled $false
write-host -foregroundcolor $SystemMessageColor "`nUsers Ability to Add Apps Has Been Disabled"
#----------------------------------------------------------------#>

#----------------------------------------------------------------
#### Disable all mailbox POP3 ####
## Get-mailbox | set-casmailbox -popenabled $false

write-host -foregroundcolor $SystemMessageColor "`n`nDisabling POP3"
Foreach ($User in $Mailboxes)
{
$UPN = $User.UserPrincipalName
    Set-casmailbox -identity $UPN -popenabled $false
 }
write-host -foregroundcolor $SystemMessageColor "`nPOP3 Disabled"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable all mailbox IMAP ####
## Get-mailbox | set-casmailbox -imapenabled $false

write-host -foregroundcolor $SystemMessageColor "`n`nDisabling IMAP"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-casmailbox -identity $UPN -imapenabled $false
 }
write-host -foregroundcolor $SystemMessageColor "`nIMAP Disabled"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable IMAP and POP3 for new users ####

write-host -foregroundcolor $SystemMessageColor "`n`nDisabling POP3 and IMAP for new Users"
Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false
write-host -foregroundcolor $SystemMessageColor "`nPOP3 and IMAP for new Users has been Disabled"
#----------------------------------------------------------------



#----------------------------------------------------------------
################# SharePoint ################
#----------------------------------------------------------------

#----------------------------------------------------------------
#### OneDrive 5TB ####
## this will set new users ODFB = 5TB when provisioned
write-host -foregroundcolor $SystemMessageColor "`n`nSetting OneDrive Limit to 5TB"
set-spotenant -OneDriveStorageQuota $FiveTB
write-host -foregroundcolor $SystemMessageColor "`nOneDrive Default Limit is now 5TB"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Prevent download of infected files from SharePoint Online ####
write-host -foregroundcolor $SystemMessageColor "`n`nPreventing download of infected files from SharePoint Online"
set-spotenant -disallowinfectedfiledownload $true
write-host -foregroundcolor $SystemMessageColor "`nDownload of infected files from SharePoint Online has been turned on"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### enable # and % in Sharepoint Online and OneDrive for Business ####
Write-host -ForegroundColor $processmessagecolor "`n`nStart - Enable SharePoint/ODFB special characters"
Set-spotenant -SpecialCharactersStateInFileFolderNames allowed
Write-host -ForegroundColor $processmessagecolor "`nFinish - Enable SharePoint/ODFB special characters"
#----------------------------------------------------------------


#----------------------------------------------------------------

Write-Host -foregroundcolor $systemmessagecolor "`nScript complete`n"
#----------------------------------------------------------------