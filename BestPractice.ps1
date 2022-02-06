#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$ProcessMessageColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"
$Black = "Black"
$White = "White"


$Mailboxes = Get-Mailbox -ResultSize Unlimited
$LitigationUsers = ($Mailboxes | Where-Object {$_.LitigationHoldEnabled -eq $false}).UserPrincipalName
#$DeleteItems = ($Mailboxes | Where-Object {$_.retaindeleteditemsfor -ne 30}).UserPrincipalName
#$CASMailboxes = Get-Casmailbox -ResultSize Unlimited
#$PopUsers = ($CASMailboxes | Where-Object {$_.popenabled -eq $true}).UserPrincipalName
#$IMAPUsers = ($CASMailboxes | Where-Object {$_.popenabled -eq $true}).UserPrincipalName
$AuditMailbox = Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} 
$FiveTB = 5242880

### OPTIONAL SECTION
$ModernAuth = Read-Host "`nWould you like to turn on Modern Auth for Office 365 (MFA) (Y\N)?"
$FirstTime = Read-Host "`nHas this script been run before (Y\N)?"
$ATP_Available = Read-Host "`nWould you like to configure RT's Default Advanced Threat Protection (ATP) for the first time (Y\N)?"
$MailboxForward = Read-Host "`nWould you like to check if any mailboxes have forwarding option set (Y\N)?"
$EmailAlerts = Read-Host "`nWould you like to turn on standard Email Alerts? (Y\N)?"

## Spam Policy
$CreateSpamPolicy = Read-Host "`nWould you like to create RTs standard spam policy for the first time (Y\N)?"
$Domains = Get-MsolDomain
$PolicyName = "RT Standard Spam Policy"
$RuleName = "Standard Spam Policy"

## ATP Policy Names
$SafeLinksPolicyName = "O365 Links Policy"  
$SafeLinksRuleName = "O365 Links Rule"
$SafeAttachPolicyName = "O365 Attachment Policy"
$SafeAttachRuleName = "O365 Attachment Rule"
$PhishingPolicyName = "O365 Phishing Policy"
$PhishingRuleName = "O365 Phishing Rule"

## Users who will notified for alerts. Separate multiple email addresses with comma (,) e.g."user1@domain.com", "user2@domain.com", "user3@domain.com"
$notifyusers = "admin@relianceit.com.au"
## Users who will have the alerts applied to
## blank = any user in your organization performs specific activity
## Select users = "user1@domain.com", "user2@domain.com", "user3@domain.com"
$userids = $null

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $Black -BackgroundColor $White "`n`n`nScript Started"
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Office 365 Best Practice ################
#----------------------------------------------------------------
#### Enable legal hold mailboxes for all users ####
##get-mailbox | set-mailbox -litigationholdenabled $true

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Legal Hold on All Mailboxes"
Foreach ($User in $LitigationUsers){
    Set-Mailbox -identity $User -LitigationHoldEnabled:$true
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Legal Hold on All Mailboxes"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable global audit logging ####
## Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -or RecipientTypeDetails -eq "SharedMailbox" -or RecipientTypeDetails -eq "RoomMailbox" -or RecipientTypeDetails -eq "DiscoveryMailbox"} | Set-Mailbox -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Global Audit Logging"
Foreach ($user in $AuditMailbox)
{
$UPN = $user.UserPrincipalName
	Set-Mailbox -identity $UPN -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems
	
	#Set-Mailbox -identity $UPN -AuditEnabled $true -AuditLogAgeLimit 180 -AuditAdmin Update, MoveToDeletedItems, SoftDelete, HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission, UpdateInboxRules, UpdateCalendarDelegation, UpdateInboxRules, UpdateCalendarDelegation -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf, UpdateInboxRules, UpdateCalendarDelegation, UpdateInboxRules, UpdateCalendarDelegation -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems, UpdateInboxRules, UpdateCalendarDelegation
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Global Audit Logging"
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

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Changing All Mailboxes to Maximum 30 Days Deleted Items"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-Mailbox -identity $UPN -retaindeleteditemsfor 30
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Changing All Mailboxes to Maximum 30 Days Deleted Items"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable auto-expanding archiving for organisation ####

If ($FirstTime -eq "N") {
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Auto-Expanding Archiving for Organisation"
Set-OrganizationConfig -AutoExpandingArchive
write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Auto-Expanding Archiving for Organisation"
}
#----------------------------------------------------------------

#----------------------------------------------------------------
#### To set all mailboxes to English (Australia) and Sydney EST timezone ####
## get-mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language 3081 -TimeZone "AUS Eastern Standard Time"

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Setting All Mailboxes to English (Australia) and Sydney EST Timezone"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-MailboxRegionalConfiguration -identity $UPN -Language 3081 -TimeZone "AUS Eastern Standard Time" -DateFormat "dd/MM/yyyy"
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Setting All Mailboxes to English (Australia) and Sydney EST Timezone"
#----------------------------------------------------------------


#----------------------------------------------------------------
#### Turn Focused Inbox Off in your organization ####
## https://docs.microsoft.com/en-us/office365/admin/setup/configure-focused-inbox?view=o365-worldwide ##

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Turning Focused Inbox Off in your organizatione"
Set-OrganizationConfig -FocusedInboxOn $false
write-host -foregroundcolor $SystemMessageColor "`nFinish - Turning Focused Inbox Off in your organizatione"
#----------------------------------------------------------------


#----------------------------------------------------------------
#### Enable modern authentication in Exchange Online ####

If ($ModernAuth -eq "y") {
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Modern Authentication in Exchange Online"

$org=get-organizationconfig
write-host -ForegroundColor $White "Exchange setting is currently",$org.OAuth2ClientProfileEnabled
## Run this command to enable modern authentication for Exchange Online
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
write-host -foregroundcolor $processmessagecolor "Exchange command completed"
$org=get-organizationconfig
write-host -ForegroundColor $White "Exchange setting updated to",$org.OAuth2ClientProfileEnabled

<# 
Write-host -ForegroundColor $processmessagecolor "`nStart - Disable basic authentication for tenant`n"
New-AuthenticationPolicy -Name "Block Basic Auth"
Set-OrganizationConfig -DefaultAuthenticationPolicy "Block Basic Auth"
Write-host -ForegroundColor $processmessagecolor "`nFinish - Disable basic authentication for tenant`n"
#>

write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Modern Authentication in Exchange Online"
}
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable users ability to add apps to their environment e.g. can't add store apps to Outlook ###
## http://blog.ciaops.com/2018/07/thwarting-office-365-ransomware-cloud.html

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Disabling Users Ability to Add Apps"
Set-MsolCompanysettings -UsersPermissionToUserConsentToAppEnabled $false
write-host -foregroundcolor $SystemMessageColor "`nFinish - Disabling Users Ability to Add Apps"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable all mailbox POP3 ####
## Get-mailbox | set-casmailbox -popenabled $false

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Disabling POP3"
Foreach ($User in $Mailboxes)
{
$UPN = $User.UserPrincipalName
    Set-casmailbox -identity $UPN -popenabled $false
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Disabling POP3"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable all mailbox IMAP ####
## Get-mailbox | set-casmailbox -imapenabled $false

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Disabling IMAP"
Foreach ($user in $Mailboxes)
{
$UPN = $user.UserPrincipalName
    Set-casmailbox -identity $UPN -imapenabled $false
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Disabling IMAP"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Disable IMAP and POP3 for new users ####

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Disabling POP3 and IMAP for new Users"
Get-CASMailboxPlan | Set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false
write-host -foregroundcolor $SystemMessageColor "`nFinish - Disabling POP3 and IMAP for new Users"
#----------------------------------------------------------------



#----------------------------------------------------------------
################# SharePoint ################
#----------------------------------------------------------------

#----------------------------------------------------------------
#### OneDrive 5TB ####
## this will set new users ODFB = 5TB when provisioned
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Setting OneDrive Limit to 5TB"
set-spotenant -OneDriveStorageQuota $FiveTB
write-host -foregroundcolor $SystemMessageColor "`nFinish - Setting OneDrive Limit to 5TB"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Prevent download of infected files from SharePoint Online ####
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Preventing download of infected files from SharePoint Online"
set-spotenant -disallowinfectedfiledownload $true
write-host -foregroundcolor $SystemMessageColor "`nFinish - Preventing download of infected files from SharePoint Online"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Prevent Prevent External users from resharing ####
Write-host -ForegroundColor $SystemMessageColor "`n`nStart - Prevent Extenernal users from resharing"
set-spotenant -PreventExternalUsersFromResharing $true
Write-host -ForegroundColor $SystemMessageColor "`nFinish - Prevent External users from resharing"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### enable # and % in Sharepoint Online and OneDrive for Business ####
Write-host -ForegroundColor $SystemMessageColor "`n`nStart - Enable SharePoint/ODFB special characters"
Set-spotenant -SpecialCharactersStateInFileFolderNames allowed
Write-host -ForegroundColor $SystemMessageColor "`nFinish - Enable SharePoint/ODFB special characters"
#----------------------------------------------------------------


#----------------------------------------------------------------
################# SharePoint ################
#----------------------------------------------------------------

If ($EmailAlerts -eq "y") {

## Alert Activities found here - https://support.office.com/en-us/article/search-the-audit-log-in-the-office-365-security-compliance-center-0d4d0f35-390b-4518-800e-0c7ec95e946c?ui=en-US&rs=en-US&ad=US#auditlogevents&PickTab=Activities
Write-host -ForegroundColor $processmessagecolor "Start - Set Activity alerts"
write-host -foregroundcolor $processmessagecolor "Added - Create File and Page Alert" 
$fileandpagepolicyparams = @{
    "Name" = "File and Page Alert";
    "operation" = "Filemalwaredetected";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "SharePoint anti-virus engine detects malware in a file.";
}
$result=New-ActivityAlert @fileandpagepolicyparams 

write-host -foregroundcolor $processmessagecolor "Added - Create Anonymous Links Alert"
$anonlinkspolicyparams = @{
    "Name" = "Anonymous Links Alert";
    "operation" = "Anonymouslinkcreated","Anonymouslinkupdated","Anonymouslinkused";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "User created an anonymous link to a resource. User updated an anonymous link to a resource. An anonymous user accessed a resource by using an anonymous link.";
}
$result=New-ActivityAlert @anonlinkspolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create File Sharing Alert"
$sharingpolicyparams = @{
    "Name" = "Sharing Alert";
    "operation" = "Sharinginvitationcreated","Sharingpolicychanged";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "User shared a resource in SharePoint Online or OneDrive for Business with a user who isn't in your organization's directory. A SharePoint or global administrator changed a SharePoint sharing policy.";
}
$result=New-ActivityAlert @sharingpolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Access Policy"
$accesspolicyparams = @{
    "Name" = "Access Alert";
    "operation" = "Deviceaccesspolicychanged","Networkaccesspolicychanged";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Change in the unmanaged devices policy. Change in the location-based access policy (also called a trusted network boundary).";
}
$result=New-ActivityAlert @accesspolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Site Alert"
$sitepolicyparams = @{
    "Name" = "Site Alert";
    "operation" = "Sitecollectioncreated","Sitedeleted","Sitecollectionadminadded";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Creation of a new site collection OneDrive for Business site provisioned. A site was deleted.Site collection administrator or owner adds a person as a site collection administrator for a site.";
}
$result=New-ActivityAlert @sitepolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Office Software Alert"
$officepolicyparams = @{
    "Name" = "Office Alert";
    "operation" = "Officeondemandset";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Site administrator enables Office on Demand, which lets users access the latest version of Office desktop applications.";
}
$result=New-ActivityAlert @officepolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Mailbox Permissions Alert"
$mailboxpolicyparams = @{
    "Name" = "Mailbox Alert";
    "operation" = "Add-mailboxpermission","Remove-mailboxpermission";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "An administrator assigned/removed the FullAccess mailbox permission to a user (known as a delegate) to another person's mailbox";
}
$result=New-ActivityAlert @mailboxpolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Passwords Alert"
$passwordpolicyparams = @{
    "Name" = "Password Alert";
    "operation" = "Change user password.","Reset user password.","Set force change user password.";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "User password changes";
}
$result=New-ActivityAlert @passwordpolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Role Alert"
$rolepolicyparams = @{
    "Name" = "Role Alert";
    "operation" = "Add member to role.","Remove member from role.";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Added/Removed a user to an admin role in Office 365.";
}
$result=New-ActivityAlert @rolepolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Company Information Alert"
$companyinfopolicyparams = @{
    "Name" = "Company Information Alert";
    "operation" = "Set company contact information.","Set company information.","Set password policy.","Remove partner from company.";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Change company information or password policy";
}
$result=New-ActivityAlert @companyinfopolicyparams

write-host -foregroundcolor $processmessagecolor "Added - Create Domain Alert"
$domainpolicyparams = @{
    "Name" = "Domain Alert";
    "operation" = "Add domain to company.","Remove domain from company.","Update domain.";
    "notifyuser" = $notifyusers;
    "userid" = $userids;
    "Description" = "Change of a custom domain in a tenant";
}
$result=New-ActivityAlert @domainpolicyparams

Write-host -ForegroundColor $processmessagecolor "`nFinish - Set Activity alerts`n"


Write-host -ForegroundColor $processmessagecolor "`n`nStart - Set Protection alerts`n"
$category = "ThreatManagement"
write-host -foregroundcolor $processmessagecolor "Added - User Submitted Email Protection Alert" 
$result=New-protectionalert -category $category -name "User submitted email" -Description "User reported a problem with mail filtering. This can include false positives, missed spam, or missed phishing email messages." -ThreatType activity -NotifyUser $notifyusers -Operation usersubmission -Filter "Activity.SubmissionType -eq 'Phish'" -AggregationType none -Severity Low

write-host -foregroundcolor $processmessagecolor "Added - Detected mailware in files Protection Alert" 
$result=New-protectionalert -category $category -name "Detected malware in files" -Description "Office 365 detected malware in either a SharePoint or OneDrive file." -ThreatType activity -NotifyUser $notifyusers -Operation filemalwaredetected -AggregationType none -Severity High

$category = "DataGovernance"
write-host -foregroundcolor $processmessagecolor "Added - DLP policy match Protection Alert" 
$result=New-protectionalert -category $category -name "DLP policy match" -Description "A data loss prevention policy match is detected." -ThreatType activity -NotifyUser $notifyusers -Operation dlpincident -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Created site collection Protection Alert" 
$result=New-protectionalert -category $category -name "Created site collection" -Description "Global administrator creates a new site collection in your SharePoint Online organization." -ThreatType activity -NotifyUser $notifyusers -Operation sitecollectioncreated -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Set host site Protection Alert" 
$result=New-protectionalert -category $category -name "Set host site" -Description "Global administrator changes the designated site to host personal or OneDrive for Business sites." -ThreatType activity -NotifyUser $notifyusers -Operation hostsiteset -AggregationType none -Severity Medium

$category = "AccessGovernance"
write-host -foregroundcolor $processmessagecolor "Added - Shared file externally Protection Alert" 
$result=New-protectionalert -category $category -name "Shared file externally" -Description "User shared, granted access of a file or folder to an external user, or created an anonymous link for it." -ThreatType activity -NotifyUser $notifyusers -Operation externalfilesharing -AggregationType none -Severity Low

write-host -foregroundcolor $processmessagecolor "Added - Granted Exchange admin permission Protection Alert" 
$result=New-protectionalert -category $category -name "Granted Exchange admin permission" -Description "User granted admin permission to same or another user." -ThreatType activity -NotifyUser $notifyusers -Operation grantadminpermission -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Granted mailbox permission Protection Alert" 
$result=New-protectionalert -category $category -name "Granted mailbox permission" -Description "User granted permission for same or another user to access a target mailbox." -ThreatType activity -NotifyUser $notifyusers -Operation addmailboxpermission -AggregationType none -Severity Low

write-host -foregroundcolor $processmessagecolor "Added - Created anonymous link Protection Alert" 
$result=New-protectionalert -category $category -name "Created anonymous link" -Description "User created an anonymous link to a resource. Anyone with this link can access the resource without having to be authenticated." -ThreatType activity -NotifyUser $notifyusers -Operation anonymouslinkcreated -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Created sharing invitation Protection Alert" 
$result=New-protectionalert -category $category -name "Created sharing invitation" -Description "User shared a resource in SharePoint Online or OneDrive for Business with a user who isn't in your organization's directory." -ThreatType activity -NotifyUser $notifyusers -Operation sharinginvitationcreated -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Additional Site Collection Admin Protection Alert" 
$result=New-protectionalert -category $category -name "Added site collection admin" -Description "Site collection administrator or owner adds a person as a site collection administrator for a site. Site collection administrators have full control permissions for the site collection and all subsites." -ThreatType activity -NotifyUser $notifyusers -Operation sitecollectionadminadded -AggregationType none -Severity High

write-host -foregroundcolor $processmessagecolor "Added - Changed sharing policy Protection Alert" 
$result=New-protectionalert -category $category -name "Changed sharing policy" -Description "An administrator changed a SharePoint sharing policy by using the Office 365 Admin center, SharePoint admin center, or SharePoint Online Management Shell. Any change to the settings in the sharing policy in your organization will be logged. The policy that was changed is identified in the ModifiedProperty field property when you export the search results." -ThreatType activity -NotifyUser $notifyusers -Operation sharingpolicychanged -AggregationType none -Severity Medium

write-host -foregroundcolor $processmessagecolor "Added - Failed User Login Attempt Protection Alert" 
$result=New-protectionalert -category $category -name "Failed USer Login Attempt" -Description "A user failed to login to the tenant. This is typically because of an incorrect password." -ThreatType activity -NotifyUser $notifyusers -Operation Userloginfailed -AggregationType none -Severity Medium

$category = "Others"
write-host -foregroundcolor $processmessagecolor "Added - Added exempt user agent Protection Alert" 
$result=New-protectionalert -category $category -name "Added exempt user agent" -Description "Global administrator adds a user agent to the list of exempt user agents in the SharePoint admin center." -ThreatType activity -NotifyUser $notifyusers -Operation exemptuseragentset -AggregationType none -Severity Medium

$Category ="None"

Write-host -ForegroundColor $processmessagecolor "Finish - Set Protection alerts`n"

}

#----------------------------------------------------------------





		#----------------------------------------------------------------
		################# OPTIONAL SECTION ################
		#----------------------------------------------------------------

		#----------------------------------------------------------------
		################## O365 Advanced Threat Protection (ATP) ##################

		If ($ATP_Available -eq "y") {
		write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Advanced Threat Protection"

		$RecipientDomain = Get-MsolDomain
		$Users = Get-MsolUser -All | where {$_.isLicensed -eq $true}

			# Default policy
				Set-atppolicyforo365 -allowclickthrough $false -enablesafelinksforclients $true -enableatpforspoteamsodb $true -trackclicks $true
				## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/set-atppolicyforo365?view=exchange-ps
				
			## SafeLinks
				New-safelinkspolicy -name $safelinkspolicyname -admindisplayname $safelinkspolicyname -donotallowclickthrough $true -donottrackuserclicks $false -enableforinternalsender $true -scanurls $true -trackclicks $true #-enabled $true
				## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safelinkspolicy?view=exchange-ps

				New-SafeLinksRule -Name $safelinksrulename -SafelinksPolicy $safelinkspolicyname -enabled $true -priority 0 -recipientdomainis $RecipientDomain.name
				## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safelinksrule?view=exchange-ps

			## SafeAttachments
			## Action options = Block | Replace | Allow | DynamicDelivery
				New-safeattachmentpolicy -name $safeattachpolicyname -admindisplayname $safeattachpolicyname -enable $true -action dynamicdelivery -actiononerror $true -redirect $false
				## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safeattachmentpolicy?view=exchange-ps

				New-SafeAttachmentRule -Name $safeattachrulename -SafeAttachmentPolicy $safeattachpolicyname -enabled $true -priority 0 -recipientdomainis $RecipientDomain.name
				## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safeattachmentrule?view=exchange-ps


			## Anti-Phishing policy

			## Users who will be protected saved to variable $userstoprotect
			## Select users = "Displayname1;user1@domain.com", "DisplayName2;user2@domain.com", "Displayname3;user3@domain.com"
			## Need to set both policy and rule for this to take effect
			
			<# 
			$UsersToProtect = Foreach ($User in $Users){
				$User.DisplayName + ";" + $User.UserPrincipalName
			}
			#>

			$imperspolicyparams=@{
				'Name' = $phishingpolicyname;
				'AdminDisplayName' = $phishingpolicyname
				'AuthenticationFailAction' =  'MoveToJmf';
				'EnableAntispoofEnforcement' = $true;
				'EnableAuthenticationSafetyTip' = $true;
				'EnableAuthenticationSoftPassSafetyTip' = $true;
				'Enabled' = $true;
				'EnableMailboxIntelligence' = $true;
				'EnableOrganizationDomainsProtection' = $true;
				'EnableSimilarDomainsSafetyTips' = $true;
				'EnableSimilarUsersSafetyTips' = $true;
				'EnableTargetedDomainsProtection' = $false;
				'EnableTargetedUserProtection' = $true;
				'TargetedUsersToProtect' = $userstoprotect;
				'EnableUnusualCharactersSafetyTips' = $true;
				'PhishThresholdLevel' = 1;
				'TargetedDomainProtectionAction' =  'MoveToJmf';
				'TargetedUserProtectionAction' =  'MoveToJmf';
				'TreatSoftPassAsAuthenticated' = $true
			}
			New-AntiPhishPolicy @imperspolicyparams
			## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishpolicy?view=exchange-ps

			## Domains that will be protected saved to variable $recipientdomain
			## Select domains = "domain1.com", "domain2.com", "domain3.com"
			$imperruleparams = @{
			'Name' = $phishingrulename;
			'AntiPhishPolicy' = $phishingpolicyname;  ## Needs to match the above policy name
			'RecipientDomainis' = $RecipientDomain.name;
			'Enabled' = $true;
			'Priority' = 0
			}
			New-antiphishrule @imperruleparams
			## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishrule?view=exchange-ps

			write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Advanced Threat Protection"
		}

		#----------------------------------------------------------------

		#----------------------------------------------------------------
		################## Configure a new Exchange Online spam filtering policy ##################

		If ($CreateSpamPolicy -eq "y") {
			write-host -foregroundcolor $SystemMessageColor "`n`nStart - Creating New Spam Policy"
			
			$PolicyParams = @{
				"name" = $PolicyName;
				'Bulkspamaction' =  'movetojmf';
				'bulkthreshold' =  '7';
				'highconfidencespamaction' =  'movetojmf';
				'inlinesafetytipsenabled' = $true;
				'markasspambulkmail' = 'on';
				'enablelanguageblocklist' = $true;
				'languageblocklist' = 'af','sq','ar','hy','az','bn','eu','be','bs','br','bg','ca','zh-cn','zh-tw','hr','cs','da','nl','eo','et','fo','tl','fi','fr','fy','gl','ka','de','el','kl','gu','ha','he','hi','hu','is','id','ga','zu','it','ja','kn','kk','sw','ko','ku','ky','la','lv','lt','lb','mk','ms','ml','mt','mi','mr','mn','nb','nn','ps','fa','pl','pt','pa','ro','rm','ru','se','sr','sk','sl','wen','es','sv','ta','te','th','tr','uk','ur','uz','vi','cy','yi';
				'enableregionblocklist' = $true;
				'regionblocklist' = 'AF','AL','DZ','AO','AI','AM','AZ','BD','BY','BZ','BJ','BT','BO','BQ','BW','BV','BF','BI','CV','CM','CF','TD','KM','CG','CD','CI','CW','DJ','DM','DO','EC','EG','SV','GQ','ER','ET','GA','GM','GE','GH','GP','GT','GN','GW','GY','HT','HM','HN','IR','IQ','XJ','SJ','JO','KZ','KG','LA','LV','LB','LS','LR','LY','MO','MK','MW','MV','ML','MR','MU','YT','MF','MN','ME','MS','MZ','MM','NA','NE','NG','NU','KP','MP','OM','PK','PW','PS','PA','PY','PE','RE','RU','RW','XS','BL','KN','LC','PM','VC','ST','SN','RS','SC','SL','XE','SX','SI','SO','SH','SD','SR','SZ','SY','TJ','TZ','TK','TN','TM','TC','TV','UG','UA','UY','UZ','VE','WF','YE','ZM','ZW';
				'increasescorewithimagelinks' = 'off'
				'increasescorewithnumericips' = 'on'
				'increasescorewithredirecttootherport' = 'on'
				'increasescorewithbizorinfourls' = 'on';
				'markasspamemptymessages' ='on';
				'markasspamjavascriptinhtml' = 'on';
				'markasspamframesinhtml' = 'off';
				'markasspamobjecttagsinhtml' = 'off';
				'markasspamembedtagsinhtml' ='off';
				'markasspamformtagsinhtml' = 'off';
				'markasspamwebbugsinhtml' = 'off';
				'markasspamsensitivewordlist' = 'on';
				#'markasspamspfrecordhardfail' = 'on';
				#'markasspamfromaddressauthfail' = 'on';
				'markasspamndrbackscatter' = 'on';
				'phishspamaction' = 'movetojmf';
				'spamaction' = 'movetojmf';
				'zapenabled' = $true
			}
			
			new-hostedcontentfilterpolicy @policyparams
			
			write-host -foregroundcolor Cyan "Set new filter rule"
			
			$ruleparams = @{
				'name' = $RuleName;
				'hostedcontentfilterpolicy' = $PolicyName;     ## this needs to match the above policy name
				'recipientdomainis' = $Domains.name;
				'Enabled' = $true
				}
			
			New-hostedcontentfilterrule @ruleparams
			
			write-host -foregroundcolor $SystemMessageColor "`nFinish - Creating New Spam Policy"
			}
		#----------------------------------------------------------------

		#----------------------------------------------------------------
		################## Check which email boxes have forwarding options set ##################

		If ($MailboxForward -eq "y") {
			write-host -foregroundcolor $SystemMessageColor "`n`nStart - Checking if any mailboxes have the forwarding option set"
			
		## Green - no forwarding enabled and no forwarding address present
		## Yellow - forwarding disabled but forwarding address present
		## Red - forwarding enabled

		write-host -foregroundcolor Cyan "`nCheck Exchange Forwards"

		foreach ($mailbox in $mailboxes) {
			if ($mailbox.DeliverToMailboxAndForward) { ## if email forwarding is active
				Write-host
				Write-host "**********" -foregroundcolor $ErrorColor
				Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress) - Forwarding = $($mailbox.delivertomailboxandforward)" -foregroundColor $ErrorColor
				Write-host "Forwarding address = $($mailbox.forwardingsmtpaddress)" -foregroundColor $ErrorColor
				Write-host "**********" -foregroundcolor $ErrorColor
				write-host
			}
			else {
				if ($mailbox.forwardingsmtpaddress){ ## if email forward email address has been set
					Write-host
					Write-host "**********" -foregroundcolor $InfoColor
					Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress) - Forwarding = $($mailbox.delivertomailboxandforward)" -foregroundColor $InfoColor
					Write-host "Forwarding address = $($mailbox.forwardingsmtpaddress)" -foregroundColor $InfoColor
					Write-host "**********" -foregroundcolor $InfoColor
					write-host
				}
				else {
					Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress) - Forwarding = $($mailbox.delivertomailboxandforward)" -foregroundColor $NoErrorColor
				}
			}
		}

		write-host -foregroundcolor Cyan "`nCheck Outlook Rule Forwards"

		foreach ($mailbox in $mailboxes)
		{
			Write-Host -foregroundcolor gray "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
		$rules = get-inboxrule -mailbox $mailbox.identity
		foreach ($rule in $rules)
			{
			If ($rule.enabled) {
				if ($rule.forwardto -or $rule.RedirectTo -or $rule.CopyToFolder -or $rule.DeleteMessage -or $rule.ForwardAsAttachmentTo -or $rule.SendTextMessageNotificationTo) { write-host "`nSuspect Enabled Rule name -",$rule.name }
				If ($rule.forwardto) { write-host -ForegroundColor $ErrorColor "Forward to:",$rule.forwardto }
				If ($rule.RedirectTo) { write-host -ForegroundColor $ErrorColor "Redirect to:",$rule.redirectto }
				If ($rule.CopyToFolder) { write-host -ForegroundColor $ErrorColor "Copy to folder:",$rule.copytofolder }
				if ($rule.DeleteMessage) { write-host -ForegroundColor $ErrorColor "Delete message:", $rule.deletemessage }
				if ($rule.ForwardAsAttachmentTo) { write-host -ForegroundColor $ErrorColor "Forward as attachment to:",$rule.forwardasattachmentto}
				if ($rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $ErrorColor "Sent TXT msg to:",$rule.sendtextmessagenotificationto }
				}
				else {
				if ($rule.forwardto -or $rule.RedirectTo -or $rule.CopyToFolder -or $rule.DeleteMessage -or $rule.ForwardAsAttachmentTo -or $rule.SendTextMessageNotificationTo) { write-host "`nSuspect Disabled Rule name -",$rule.name }
				If ($rule.forwardto) { write-host -ForegroundColor $InfoColor "Forward to:",$rule.forwardto }
				If ($rule.RedirectTo) { write-host -ForegroundColor $InfoColor "Redirect to:",$rule.redirectto }
				If ($rule.CopyToFolder) { write-host -ForegroundColor $InfoColor "Copy to folder:",$rule.copytofolder }
				if ($rule.DeleteMessage) { write-host -ForegroundColor $InfoColor "Delete message:", $rule.deletemessage }
				if ($rule.ForwardAsAttachmentTo) { write-host -ForegroundColor $InfoColor "Forward as attachment to:",$rule.forwardasattachmentto}
				if ($rule.SendTextMessageNotificationTo) { write-host -ForegroundColor $InfoColor "Sent TXT msg to:",$rule.sendtextmessagenotificationto }
				}
			}
		}

			write-host -ForegroundColor $InfoColor "`n`n`nCheck for any mailboxes have the forwarding option finished:
		> Green - no forwarding enabled and no forwarding address present
		> Yellow - forwarding disabled but forwarding address present
		> Red - forwarding enabled"
		}
		#----------------------------------------------------------------

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------