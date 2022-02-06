<#
    .Link
    https://docs.microsoft.com/en-us/powershell/module/azuread/new-azureadgroup?view=azureadps-2.0

    .Description
    Goal of the script is to create a M365 Assigned Group: "External Forwarding Allowed"
    Membership initially is webmaster@<domain> and hostmaster@<domain>
    Create an Outbound Spam Policy. "External Forwarding Enabled"
    All default except External Forwarding is ON.

    .Notes
    Names of Group/Alias and Policy editable below.
    Group members to be added into the array.
    Standard is to check for:
        Webmaster and Hostmaster
    And add any that are found.

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
$processmessagecolor = "green"
$errormessagecolor = "red"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Group
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# $GroupName = Read-Host -Prompt "Group to apply this policy to: (Ensure name is unique for Tenant)"
# $GroupAlias = Read-Host -Prompt "Group Email Address (Don't Include Domain e.g. ExternalForwardingAllowed)"
$GroupName = "External Forwarding Allowed"
$GroupAlias = "ExternalForwardingAllowed"
$GroupMembers = @('hostmaster','webmaster')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Policy
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$policyname                                 = "External Forwarding Enabled"
$autoforwardingmode                         = "On"                          ## The AutoForwardingMode specifies how the policy controls automatic email forwarding to outbound recipients                 
$bccsuspiciousoutboundadditionalrecipients  = $null                         ## The BccSuspiciousOutboundAdditionalRecipients parameter specifies the recipients to add to the Bcc field of outgoing spam messages. Valid input for this parameter is an email address. Separate multiple email addresses with commas.
$bccsuspiciousoutboundmail                  = $false                        ## The BccSuspiciousOutboundMail parameter enables or disables adding recipients to the Bcc field of outgoing spam messages.
$notifyoutboundspam                         = $false                        ## The NotifyOutboundSpam parameter enables or disables sending notification messages to administrators when an outgoing message is determined to be spam. 
$NotifyOutboundSpamRecipients               = $null                         ## The NotifyOutboundSpamRecipients parameter specifies the administrators to notify when an outgoing message is determined to be spam.
$RecipientLimitExternalPerHour              = 0                             ## The RecipientLimitExternalPerHour parameter specifies the maximum number of external recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
$RecipientLimitInternalPerHour              = 0                             ## The RecipientLimitInternalPerHour parameter specifies the maximum number of internal recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
$RecipientLimitPerDay                       = 0                             ## The RecipientLimitInternalPerHour parameter specifies the maximum number of recipients that a user can send to within a day. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
$ActionWhenThresholdReached                 = "BlockUserForToday"           ## The ActionWhenThresholdReach parameter specifies the action to take when any of the limits specified in the policy are reached. Valid values are:  Alert: No action, alert only. BlockUser: Prevent the user from sending email messages. BlockUserForToday: Prevent the user from sending email messages until the following day. This is the default value.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Rule
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$rulename                                   = $policyname
$HostedOutboundSpamFilterPolicy             = $policyname;       ## this needs to match the above policy name
$Exceptiffrom                               = $null;                    
$Exceptiffrommemberof                       = $null;
$Exceptifsenderdomainis                     = $null;
$From                                       = $null;
# $FromMemberof                               = $null               ## This will not be created yet - Property is entered from the group email added next.
$Priority                                   = 0;                                                     ## A lower integer value indicates a higher priority, the value 0 is the highest priority, and rules can't have the same priority value.
$SenderDomainIs                             = $null;
$Enabled                                    = $true

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Create Group
# Iterate through members list
# Add any found members into the group
New-UnifiedGroup -DisplayName "$GroupName" -Alias "$GroupAlias"

foreach ($member in $GroupMembers)
{
    Try {
        Get-User -Identity "$member" -wa Stop -ea Stop
        Add-UnifiedGroupLinks -Identity "$GroupName" -LinkType Members -Links "$member"
    } Catch {
        Write-Host "$($_.Exception.Message)"
    }
}

$GroupEmailAddress = Get-UnifiedGroup -Identity "$GroupName"
$GroupEmailAddress = $GroupEmailAddress.PrimarySmtpAddress


# Add-UnifiedGroupLinks -Identity "$GroupName" -LinkType Members -Links "hostmaster","webmaster"

<#CIAOPS

Script provided as is. Use at own risk. No guarantees or warranty provided.

Description - Configures an additional Exchange Online Spam policy. This policy can be disabled or deleted if needed in the GUI
Documentation - https://github.com/directorcia/patron/wiki/Create-additional-Exchange-Online-spam-filtering-policy
Source - https://github.com/directorcia/patron/blob/master/o365-mx-spam-set.ps1

Prerequisites = 2
1. Ensure connected to Exchange Online V2 - Use the script https://github.com/directorcia/Office365/blob/master/o365-connect-exov2.ps1
2. Ensure MSonline module loaded and updated

#>

## Variables


Clear-Host
Start-transcript "..\o365-mx-extfwd-set.txt" | Out-Null                                   ## Log file created in parent directory that is overwritten on each run
Write-Host -ForegroundColor $systemmessagecolor "Script started`n"

<#  ----- [Start] Exchange Online V2 PowerShell module check -----   #>
if (get-module -listavailable -name ExchangeOnlineManagement) {                         ## Has the Exchange Online PowerShell V2 module been loaded?
    write-host -ForegroundColor $processmessagecolor "Exchange Online PowerShell V2 found"
}
else {
    write-host -ForegroundColor yellow $errormessagecolor "[001] - Exchange Online PowerShell V2 module not installed. Please install and re-run script - ",$_.Exception.Message
    Stop-Transcript                 ## Terminate transcription
    exit 1                          ## Terminate script
}
<#  ----- [End] Exchange Online V2 PowerShell module check -----   #>

<#  ----- [Start] MSOnline PowerShell module check -----   #>
if (get-module -listavailable -name msonline) {    ## Has the MSOnline module been loaded?
    write-host -ForegroundColor $processmessagecolor "MS Online PowerShell module found"
}
else {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[002] - MS Online PowerShell module not installed. Please install and re-run script - ", $_.Exception.Message
    Stop-Transcript                 ## Terminate transcription
    exit 2                          ## Terminate script
}
<#  ----- [End] MSOnline PowerShell module check -----   #>

<#  ----- [Start] Connect to Mirosoft Online check -----   #>
try {
    Connect-MsolService             ## Connect to Microsoft Online    
}
catch {
    Write-Host -ForegroundColor $errormessagecolor "[003] - Unable to connect to Microsoft Online - ", $_.Exception.Message
    stop-transcript                 ## Terminate transcript
    exit 3                          ## Terminate script
}
<#  ----- [End] Connect to Mirosoft Online check -----   #>

<#  ----- [Start] Get Global Administrators -----   #
$role = Get-MsolRole -RoleName "Company Administrator"
$admins = Get-MsolRoleMember -RoleObjectId $role.ObjectId
$notifyusers = $admins.emailaddress                         ## Users who will notified for alerts.
<#  ----- [End] Get Global Administrators -----   #>

<#  ----- [Start] Get tenant domains -----   #
write-host -foregroundcolor $processmessagecolor "Start - Get all domains in tenant "
$domains = Get-Msoldomain
$recipientdomain = Foreach ($domain in $domains){
    $domain.name
}
write-host -foregroundcolor $processmessagecolor "Finish - Get all domains in tenant "
<#  ----- [End] Get tenant domains -----   #>

<#  ----- [Start] Get existing Outbound Spam policies -----   #>
Write-host -ForegroundColor $processmessagecolor "Start - Configure Outbound Spam filtering"
try {
    $spampolicy = get-hostedoutboundspamfilterpolicy | Out-Null
}
catch {
    Write-Host write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[005] - Unable to connect to Exchange online",$_.Exception.Message
    stop-transcript                 ## Terminate transcript
    exit 5                          ## Terminate script
}
<#  ----- [End] Get existing Outbound Spam policies -----   #>
Write-host -ForegroundColor $processmessagecolor "Check for Outbound Spam policy match"
if ($spampolicy.name -match $policyname){            ## Does an existing Outbound Spam policy of same name already exist?
    write-host -ForegroundColor $errormessagecolor ("`n[",$spampolicy.name,"] already exists - No changes made`n")
} else {                                                ## If not create a policy
    Write-host -ForegroundColor $processmessagecolor "Start - Create Outbound Spam filter policy"
    $policyparams = @{
        'Name' = $policyname;
        'autoforwardingmode' = $autoforwardingmode;                                                     ## The AutoForwardingMode specifies how the policy controls automatic email forwarding to outbound recipients                 
        'bccsuspiciousoutboundadditionalrecipients' =  $bccsuspiciousoutboundadditionalrecipients;      ## The BccSuspiciousOutboundAdditionalRecipients parameter specifies the recipients to add to the Bcc field of outgoing spam messages. Valid input for this parameter is an email address. Separate multiple email addresses with commas.
        'bccsuspiciousoutboundmail' = $bccsuspiciousoutboundmail;                                       ## The BccSuspiciousOutboundMail parameter enables or disables adding recipients to the Bcc field of outgoing spam messages.
        'notifyoutboundspam' = $notifyoutboundspam;                                                     ## The NotifyOutboundSpam parameter enables or disables sending notification messages to administrators when an outgoing message is determined to be spam. 
        'NotifyOutboundSpamRecipients' = $NotifyOutboundSpamRecipients                                  ## The NotifyOutboundSpamRecipients parameter specifies the administrators to notify when an outgoing message is determined to be spam.
        'RecipientLimitExternalPerHour' = $RecipientLimitExternalPerHour;                               ## The RecipientLimitExternalPerHour parameter specifies the maximum number of external recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
        'RecipientLimitInternalPerHour' = $RecipientLimitInternalPerHour;                               ## The RecipientLimitInternalPerHour parameter specifies the maximum number of internal recipients that a user can send to within an hour. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
        'RecipientLimitPerDay' = $RecipientLimitPerDay;                                                 ## The RecipientLimitInternalPerHour parameter specifies the maximum number of recipients that a user can send to within a day. A valid value is 0 to 10000. The default value is 0, which means the service defaults are used.
        'ActionWhenThresholdReached' = $ActionWhenThresholdReached                                      ## The ActionWhenThresholdReach parameter specifies the action to take when any of the limits specified in the policy are reached. Valid values are:  Alert: No action, alert only. BlockUser: Prevent the user from sending email messages. BlockUserForToday: Prevent the user from sending email messages until the following day. This is the default value.
    }
    $policyparams.AutoForwardingMode = $autoforwardingmode      ## Issue with value not being set previously, so setting now????
    New-hostedoutboundspamfilterpolicy @policyparams | Out-Null
}

<#  ----- [Start] Get existing Outbound Spam rules -----   #>
Write-host -ForegroundColor $processmessagecolor "Check for existing Outbound Spam rule match"
try {
    $spamrule = Get-HostedOutBoundSpamFilterrule | Out-Null
}
catch {
    Write-Host write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[007] - Unable to connect to Exchange online",$_.Exception.Message
    stop-transcript                 ## Terminate transcript
    exit 7                          ## Terminate script
}
<#  ----- [End] Get existing Outbound spam rules -----   #>

if ($spamrule.name -match $rulename){            ## Does an existing spam rule of same name already exist?
    write-host -ForegroundColor $errormessagecolor ("`n[",$spamrule.name,"] already exists - No changes made`n")
} else {   
    $ruleparams = @{
        'name' = $rulename;
        'HostedOutboundSpamFilterPolicy' = $HostedOutboundSpamFilterPolicy;       ## this needs to match the above policy name
        'Exceptiffrom' = $Exceptiffrom;                    
        'Exceptiffrommemberof' = $Exceptiffrommemberof;
        'Exceptifsenderdomainis' = $Exceptifsenderdomainis;
        'From' = $From;
        'FromMemberof' = $GroupEmailAddress;
        'Priority' = $Priority;                               ## A lower integer value indicates a higher priority, the value 0 is the highest priority, and rules can't have the same priority value.
        'SenderDomainIs' = $SenderDomainIs;
        'Enabled' = $Enabled
    }
    New-hostedoutboundspamfilterrule @ruleparams | Out-Null
    Write-host -ForegroundColor $processmessagecolor "Finish - Create OutBound Spam filter rule"
}
Write-host -ForegroundColor $processmessagecolor "Finish - Configure Outbound Spam filtering`n"

Write-Host -ForegroundColor $systemmessagecolor "Script Finished`n"
Stop-Transcript | Out-Null

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------