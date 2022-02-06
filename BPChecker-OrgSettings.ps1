<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Get-Exchange-organization-settings
    Source - https://github.com/directorcia/patron/blob/master/o365-mx-org-get.ps1

    .Description
    Get Exchange organizational and compare to best practices

 
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


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -ForegroundColor $systemmessagecolor "Script started`n"

write-host -ForegroundColor $processmessagecolor "Getting current Exchange organizational configuration"
$results = Get-Organizationconfig

foreach ($result in $results){
    if ($result.Activitybasedauthenticationtimeoutenabled -ne $true ){     ## The ActivityBasedAuthenticationTimeoutEnabled parameter specifies whether the timed logoff feature is enabled              
        write-host -foregroundcolor $errormessagecolor "   Activitybasedauthenticationtimeoutenabled disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Activitybasedauthenticationtimeoutenabled enabled"
    }
    ## The ActivityBasedAuthenticationTimeoutInterval parameter specifies the time span for logoff
    $hours = [int]$result.ActivityBasedAuthenticationTimeoutInterval.split(':')[0]
    $minutes = [int]$result.ActivityBasedAuthenticationTimeoutInterval.split(':')[1]
    if ($hours -gt 0 ){     
        write-host -foregroundcolor $errormessagecolor "   ActivityBasedAuthenticationTimeoutInterval = ", $result.ActivityBasedAuthenticationTimeoutInterval
    }
    else {
        if ($minutes -gt 30){
            write-host -foregroundcolor $errormessagecolor "   ActivityBasedAuthenticationTimeoutInterval = ", $result.ActivityBasedAuthenticationTimeoutInterval
        } else {
            write-host -foregroundcolor $processmessagecolor "   ActivityBasedAuthenticationTimeoutInterval = ", $result.ActivityBasedAuthenticationTimeoutInterval
        }     
    }
    if ($result.ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled -ne $true ){     ## The ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled parameter specifies whether to keep single sign-on enabled
        write-host -foregroundcolor $errormessagecolor "   ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled enabled"
    }
    if ($result.AppsforOfficeEnabled -ne $true ){     ## The AppsForOfficeEnabled parameter specifies whether to enable apps for Outlook features. By default, the parameter is set to $true. If the flag is set to $false, no new apps can be activated for any user in the organization
        write-host -foregroundcolor $errormessagecolor "   AppsforOfficeEnabled disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   AppsforOfficeEnabled enabled"
    }
    if ($result.AuditDisabled -ne $false ){     ## The AuditDisabled parameter specifies whether to disable or enable mailbox auditing for the organization
        write-host -foregroundcolor $errormessagecolor "   Disable Auditing is True"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Disable Auditing is False"
    }
    if ($result.AutoExpandingArchiveEnabled -ne $true ){     ## The AutoExpandingArchive switch enables the unlimited archiving feature (called auto-expanding archiving) in an Exchange Online organization. 
        write-host -foregroundcolor $errormessagecolor "   AutoExpanding Archives is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   AutoExpanding Archives is enabled"
    }
    if ($result.BookingsEnabled -ne $true ){     ## The BookingsEnabled parameter specifies whether to enable Microsoft Bookings in an Exchange Online organization
        write-host -foregroundcolor $errormessagecolor "   Bookings is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Bookings is enabled"
    }
    if ($result.BookingsPaymentsEnabled -ne $true ){     ## The BookingsPaymentsEnabled parameter specifies whether to enable online payment node inside Bookings
        write-host -foregroundcolor $errormessagecolor "   Bookings Payments is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Bookings Payments is enabled"
    }
    if ($result.BookingsSocialSharingRestricted -ne $false ){     # The BookingsSocialSharingRestricted parameter allows you to control whether, or not, your users can see social sharing options inside Bookings
        write-host -foregroundcolor $errormessagecolor "   Bookings Social Sharing is enabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Bookings Social Sharing is disabled"
    }
    if ($result.ConnectorsActionableMessagesEnabled -ne $true ){    ## The ConnectorsActionableMessagesEnabled parameter specifies whether to enable or disable actionable buttons in messages (connector cards) from connected apps on Outlook on the web 
        write-host -foregroundcolor $errormessagecolor "   Connectors Actionable Messages is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors Actionable Messages is enabled"
    }
    if ($result.ConnectorsEnabled -ne $true ){    ## The ConnectorsEnabled parameter specifies whether to enable or disable all connected apps in organization. The workloads that are affected by this parameter are Outlook, SharePoint, Teams, and Yammer
        write-host -foregroundcolor $errormessagecolor "   Connectors is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors is enabled"
    }
    if ($result.connectorsenabledforOutlook -ne $true ){    ## The ConnectorsEnabledForOutlook parameter specifies whether to enable or disable connected apps in Outlook on the web.
        write-host -foregroundcolor $errormessagecolor "   Connectors for Outlook is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors for Outlook is enabled"
    }
    if ($result.connectorsenabledforsharepoint -ne $true ){    ## The ConnectorsEnabledForSharepoint parameter specifies whether to enable or disable connected apps on Sharepoint.
        write-host -foregroundcolor $errormessagecolor "   Connectors for SharePoint is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors for SharePoint is enabled"
    }
    if ($result.connectorsenabledforteams -ne $true ){    ## The ConnectorsEnabledForTeams parameter specifies whether to enable or disable connected apps on Teams.
        write-host -foregroundcolor $errormessagecolor "   Connectors for Teams is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors for Teams is enabled"
    }
    if ($result.connectorsenabledforYammer -ne $true ){    ## The ConnectorsEnabledForYammer parameter specifies whether to enable or disable connected apps on Yammer.
        write-host -foregroundcolor $errormessagecolor "   Connectors for Yammer is disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Connectors for Yammer is enabled"
    }
    if ($result.defaultgroupaccesstype -ne "private" ){   ## The DefaultGroupAccessType parameter specifies the default access type for Office 365 groups. 
        write-host -foregroundcolor $errormessagecolor "   Default Group access type is not private"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Default Group access type is private"
    }
    if ($result.distributiongroupnameblockedwordslist -ne $null ){   ## The DistributionGroupNameBlockedWordsList parameter specifies words that can't be included in the names of distribution groups.
        write-host -foregroundcolor $errormessagecolor "   Distribution Group Name Block Words list is not empty"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Distribution Group Name Blocks Words List is empty"
    }
    if ($result.ewsallowentourage -ne $false ){   ## The EwsAllowEntourage parameter specifies whether to enable or disable Entourage 2008 to access Exchange Web Services (EWS) for the entire organization. 
    write-host -foregroundcolor $errormessagecolor "   Entourage 2008 access is not disabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Entourage 2008 access is disabled"
    }
    if ($result.exchangenotificationenabled -ne $true ){   ## The ExchangeNotificationEnabled parameter enables or disables Exchange notifications sent to administrators regarding their organizations
        write-host -foregroundcolor $errormessagecolor "   Exchange notifications is disabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Exchange notifications is enabled"
    }
    if ([string]::IsNullOrEmpty($result.ExchangeNotificationRecipients)){          ## The ExchangeNotificationRecipients parameter specifies the recipients for Exchange notifications sent to administrators regarding their organizations. If the ExchangeNotificationEnabled parameter is set to $false, no notification messages are sent. Be sure to enclose values that contain spaces in quotation marks (") and separate multiple values with commas. If this parameter isn't set, Exchange notifications are sent to all administrators.
        write-host -foregroundcolor $errormessagecolor "   Notification Recipient list is empty"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Notification Recipient = ", $result.ExchangeNotificationRecipients
    }
    if ($result.focusedinboxon -ne $false ){   ## The FocusedInboxOn parameter enables or disables Focused Inbox for the organization.
        write-host -foregroundcolor $errormessagecolor "   Focused Inbox is enabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Focused Inbox is disabled"
    }
    if ($result.linkpreviewenabled -ne $true ){   ## The LinkPreviewEnabled parameter specifies whether link preview of URLs in email messages is allowed for the organization.
        write-host -foregroundcolor $errormessagecolor "   Link Preview is disabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Link Preview is enabled"
    }
    if ($result.mailtipsalltipsenabled -ne $true ){   ## The MailTipsAllTipsEnabled parameter specifies whether MailTips are enabled.
        write-host -foregroundcolor $errormessagecolor "   Mail Tips is disabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Mail Tips is enabled"
    }
    if ($result.mailtipsexternalrecipientstipsenabled -ne $false ){     ## The MailTipsExternalRecipientsTipsEnabled parameter specifies whether MailTips for external recipients are enabled.  
        write-host -foregroundcolor $errormessagecolor "   Mail Tips for external users is enabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Mail Tips for external users is disabled"
    }
    if ($result.mailtipsgroupmetricsenabled -ne $true ){     ## The MailTipsGroupMetricsEnabled parameter specifies whether MailTips that rely on group metrics data are enabled. 
        write-host -foregroundcolor $errormessagecolor "   Mail Tips group metrics is disabled"
        }
    else {
            write-host -foregroundcolor $processmessagecolor "   Mail Tips group metrics is enabled"
    }
    if ($result.MailTipsMailboxSourcedTipsEnabled -ne $true ){     ## The MailTipsMailboxSourcedTipsEnabled parameter specifies whether MailTips that rely on mailbox data (out-of-office or full mailbox) are enabled.
        write-host -foregroundcolor $errormessagecolor "   Mail Tips from mailboxes is disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mail Tips from mailboxes is enabled"
    }
    if ($result.OAuth2ClientProfileEnabled -ne $true ){     ## The OAuth2ClientProfileEnabled parameter enables or disables modern authentication in the Exchange organization.
        write-host -foregroundcolor $errormessagecolor "   Modern authentication is disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Modern authentication is enabled"
    }
    if ($result.OutlookPayEnabled -ne $false ){     ## The OutlookPayEnabled parameter enables or disables Payments in Outlook in the Office 365 organization.
        write-host -foregroundcolor $errormessagecolor "   Outlook Pay is enabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Outlook Pay is disabled"
    }
    if ($result.PublicComputersDetectionEnabled -ne $true ){     ## The PublicComputersDetectionEnabled parameter specifies whether Outlook on the web will detect when a user signs from a public or private computer or network, and then enforces the attachment handling settings from public networks.
        write-host -foregroundcolor $errormessagecolor "   Public Computer detection is disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Public Computer detection is enabled"
    }
    if ($result.ReadTrackingEnabled -ne $false ){     ## The ReadTrackingEnabled parameter specifies whether the tracking for read status for messages in an organization is enabled.
        write-host -foregroundcolor $errormessagecolor "   Tracking for Read status is enabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Tracking for Read status is disabled"
    }
    if ($result.SmtpActionableMessagesEnabled -ne $true ){     ## The SmtpActionableMessagesEnabled parameter specifies whether to enable or disable action buttons in email messages in Outlook on the web.
        write-host -foregroundcolor $errormessagecolor "   Action buttons for Outlook on the Web are disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Action buttons for Outlook on the Web are enabled"
    }
    if ($result.UnblockUnsafeSenderPromptEnabled -ne $true ){     ## The UnblockUnsafeSenderPromptEnabled parameter specifies whether to enable or disable the prompt to unblock unsafe senders in Outlook on the web.
        write-host -foregroundcolor $errormessagecolor "   Prompt for unsafe sender is disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Prompt for unsafe sender is enabled"
    }
    if ($result.WebPushNotificationsDisabled -ne $false ){     ## The WebPushNotificationsDisabled parameter specifies whether to enable or disable Web Push Notifications in Outlook on the Web. This feature provides web push notifications which appear on a user's desktop while the user is not using Outlook on the Web. This brings awareness of incoming messages while they are working elsewhere on their computer.
        write-host -foregroundcolor $errormessagecolor "   Web push notifications are disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Web push notifications are enabled"
    }
    if ($result.WebSuggestedRepliesDisabled -ne $false ){     ## The WebSuggestedRepliesDisabled parameter specifies whether to enable or disable Suggested Replies in Outlook on the web. This feature provides suggested replies to emails so users can easily and quickly respond to messages.
        write-host -foregroundcolor $errormessagecolor "   Suggested replies for Outlook on the web are disabled"
        }
    else {
        write-host -foregroundcolor $processmessagecolor "   Suggested replies for Outlook on the Web are enabled"
    }
    write-host
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------