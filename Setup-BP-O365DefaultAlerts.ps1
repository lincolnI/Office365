## Version 2.0
## Script to create a number of standard Office 365 alerts
## Need to connect to security and compliance center first
## Alert Activities found here - https://support.office.com/en-us/article/search-the-audit-log-in-the-office-365-security-compliance-center-0d4d0f35-390b-4518-800e-0c7ec95e946c?ui=en-US&rs=en-US&ad=US#auditlogevents&PickTab=Activities


#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
## Users who will notified. Separate multiple email addresses with comma (,) e.g."user1@domain.com", "user2@domain.com", "user3@domain.com"
$notifyusers="admin@M365B618138.onmicrosoft.com"

## Users who will have the alerts applied to
## blank = any user in your organization performs specific activity
## Select users = "user1@domain.com", "user2@domain.com", "user3@domain.com"
$userids = $null
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Script ################
#----------------------------------------------------------------
write-host -foregroundcolor green "Create File and Page Alert" 
$fileandpagepolicyparams = @{
"Name" = "File and Page Alert";
"operation" = "Filemalwaredetected";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "SharePoint anti-virus engine detects malware in a file.";
}
$result=New-ActivityAlert @fileandpagepolicyparams 

write-host -foregroundcolor green "Create Anonymous Links Alert"
$anonlinkspolicyparams = @{
"Name" = "Anonymous Links Alert";
"operation" = "Anonymouslinkcreated","Anonymouslinkupdated","Anonymouslinkused";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "User created an anonymous link to a resource. User updated an anonymous link to a resource. An anonymous user accessed a resource by using an anonymous link.";
}
$result=New-ActivityAlert @anonlinkspolicyparams

write-host -foregroundcolor green "Create File Sharing Alert"
$sharingpolicyparams = @{
"Name" = "Sharing Alert";
"operation" = "Sharinginvitationcreated","Sharingpolicychanged";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "User shared a resource in SharePoint Online or OneDrive for Business with a user who isn't in your organization's directory. A SharePoint or global administrator changed a SharePoint sharing policy.";
}
$result=New-ActivityAlert @sharingpolicyparams

write-host -foregroundcolor green "Create Access Policy"
$accesspolicyparams = @{
"Name" = "Access Alert";
"operation" = "Deviceaccesspolicychanged","Networkaccesspolicychanged";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Change in the unmanaged devices policy.Change in the location-based access policy (also called a trusted network boundary).";
}
$result=New-ActivityAlert @accesspolicyparams

write-host -foregroundcolor green "Create Site Alert"
$sitepolicyparams = @{
"Name" = "Site Alert";
"operation" = "Sitecollectioncreated","Sitedeleted","Sitecollectionadminadded";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Creation of a new site collection OneDrive for Business site provisioned. A site was deleted.Site collection administrator or owner adds a person as a site collection administrator for a site.";
}
$result=New-ActivityAlert @sitepolicyparams

write-host -foregroundcolor green "Create Office Software Alert"
$officepolicyparams = @{
"Name" = "Office Alert";
"operation" = "Officeondemandset";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Site administrator enables Office on Demand, which lets users access the latest version of Office desktop applications.";
}
$result=New-ActivityAlert @officepolicyparams

write-host -foregroundcolor green "Create Mailbox Permissions Alert"
$mailboxpolicyparams = @{
"Name" = "Mailbox Alert";
"operation" = "Add-mailboxpermission","Remove-mailboxpermission";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "An administrator assigned/removed the FullAccess mailbox permission to a user (known as a delegate) to another person's mailbox";
}
$result=New-ActivityAlert @mailboxpolicyparams

write-host -foregroundcolor green "Create Passwords Alert"
$passwordpolicyparams = @{
"Name" = "Password Alert";
"operation" = "Change user password.","Reset user password.","Set force change user password.";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "User password changes";
}
$result=New-ActivityAlert @passwordpolicyparams

write-host -foregroundcolor green "Create Role Alert"
$rolepolicyparams = @{
"Name" = "Role Alert";
"operation" = "Add member to role.","Remove member from role.";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Added/Removed a user to an admin role in Office 365.";
}
$result=New-ActivityAlert @rolepolicyparams

write-host -foregroundcolor green "Create Company Information Alert"
$companyinfopolicyparams = @{
"Name" = "Company Information Alert";
"operation" = "Set company contact information.","Set company information.","Set password policy.","Remove partner from company.";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Change company information or password policy";
}
$result=New-ActivityAlert @companyinfopolicyparams

write-host -foregroundcolor green "Create Domain Alert"
$domainpolicyparams = @{
"Name" = "Domain Alert";
"operation" = "Add domain to company.","Remove domain from company.","Update domain.";
"notifyuser" = $notifyusers;
"userid" = $userids;
"Description" = "Change of a custom domain in a tenant";
}
$result=New-ActivityAlert @domainpolicyparams

#----------------------------------------------------------------