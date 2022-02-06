<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Get-existing-spam-policies-and-comparing-to-best-practices
    Source - https://github.com/directorcia/patron/blob/master/o365-mx-spam-get.ps1

    .Description
    Gets existing spam policies and checks these against best practices

 
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

<#      Get existing Inbound policies       #>
Write-host -ForegroundColor $systemmessagecolor "Check for existing Inbound policies`n"
$spampolicy = Get-HostedContentFilterPolicy
write-host -foregroundcolor $processmessagecolor "Total number of Inbound policies = ", $spampolicy.Count

Foreach ($policy in $spampolicy) {
    Write-Host "Inbound Policy Name = ", $policy.name
        if ($policy.bulkspamaction -ne "movetojmf"){            ## The BulkSpamAction parameter specifies the action to take on messages that are classified as bulk email (also known as gray mail)
        write-host -foregroundcolor $errormessagecolor "   Bulk spam Action not set to movetojmf"
    }
    else { 
            write-host -foregroundcolor $processmessagecolor "   Bulk spam Action set to movetojmf"
    }
    if ($policy.bulkthreshold -ne "7"){                         ## The BulkThreshold parameter specifies the Bulk Complaint Level (BCL) threshold setting. Valid values are from 1 - 9, where 1 marks most bulk email as spam, and 9 allows the most bulk email to be delivered. The default value is 7
        write-host -foregroundcolor $errormessagecolor "   Bulk threshold not set to 7"
    }
    else { 
        write-host -foregroundcolor $processmessagecolor "   Bulk theshold set to 7"
    }
    if ($policy.Highconfidencespamaction -ne "movetojmf"){      ## The HighConfidenceSpamAction parameter specifies the action to take on messages that are classified as high confidence spam (not spam, bulk email, or phishing).
        write-host -foregroundcolor $errormessagecolor "   High confidence spam action not set to movetojmf"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   High confidence spam action set to movetojmf"
    }
    if ($policy.Inlinesafetytipsenabled -ne $true){             ## The InlineSafetyTipsEnabled parameter specifies whether to enable or disable safety tips that are shown to recipients in messages.
        write-host -foregroundcolor $errormessagecolor "   Inline safety tips not enabled"
    } 
    else{
        write-host -foregroundcolor $processmessagecolor "   Inline safety tips enabled"
    }
    if ($policy.Markasspambulkmail -ne "on"){                   ## The MarkAsSpamBulkMail parameter classifies the message as spam when the message is identified as a bulk email message (also known as gray mail).
        write-host -foregroundcolor $processmessagecolor "   Mark as spam bulk email is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam bulk email is on"
    }
    if ($policy.Enablelanguageblocklist -ne $true){                 ## The EnableLanguageBlockList parameter enables or disables blocking email messages that are written in specific languages, regardless of the message contents. When you enable the language block list, you may specify one or more languages by using the LanguageBlockList parameter.
        write-host -foregroundcolor $errormessagecolor "   Enable language block list is not enabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Enable language block list is enabled"
    }
    if ([string]::IsNullOrEmpty($policy.Languageblocklist)){        ## The LanguageBlockList parameter specifies the languages to block when messages are blocked based on their language. Valid input for this parameter is a supported ISO 639-1 lowercase two-letter language code. You can specify multiple values separated by commas.
        write-host -foregroundcolor $errormessagecolor "   Language block list is empty"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Language block list is not empty"
    }
    if ($policy.Enableregionblocklist -ne $true){                   ## The EnableRegionBlockList parameter enables or disables blocking email messages that are sent from specific countries or regions, regardless of the message contents. When you enable the region block list, you may specify one or more regions by using the RegionBlockList parameter.
        write-host -foregroundcolor $errormessagecolor "   Enable region block list is not enabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Enable region block list is enabled"
    }
    if ([string]::IsNullOrEmpty($policy.regionblocklist)){          ## The RegionBlockList parameter specifies the region to block when messages are blocked based on their source region. Valid input for this parameter is a supported ISO 3166-1 uppercase two-letter country code. You can specify multiple values separated by commas. This parameter is only used when the EnableRegionBlockList parameter is set to $true.
        write-host -foregroundcolor $errormessagecolor "   Region block list is empty"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Region block list is not empty"
    }
    if ($policy.Increasescorewithimagelinks -ne "off" ){         ## The IncreaseScoreWithImageLinks parameter increases the spam score of messages that contain image links to remote websites.
        write-host -foregroundcolor $errormessagecolor "   Increase score with image links is not off"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Increase score with image links is off"
    }
    if ($policy.Increasescorewithnumericips -ne "on" ){         ## The IncreaseScoreWithNumericIps parameter increases the spam score of messages that contain links to IP addresses.
        write-host -foregroundcolor $errormessagecolor "   Increase score with numeric IPs is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Increase score with numeric IPs is on"
    }
    if ($policy.Increasescorewithredirecttootherport -ne "on" ){    ## The IncreaseScoreWithRedirectToOtherPort parameter increases the spam score of messages that contain links that redirect to other TCP ports.
        write-host -foregroundcolor $errormessagecolor "   Increase score with direct to other port is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Increase score with direct to other port is on"
    }
    if ($policy.Increasescorewithbizorinfourls -ne "on" ){      ## The IncreaseScoreWithBizOrInfoUrls parameter increases the spam score of messages that contain links to .biz or .info domains.
        write-host -foregroundcolor $errormessagecolor "   Increase score with .biz or .info in URLs is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Increase score with .biz or .info in URLs is on"
    }
    if ($policy.Markasspamemptymessages -ne "on" ){             ## The MarkAsSpamEmptyMessages parameter classifies the message as spam when the message is empty.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam empty messages as spam is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam empty messages as spam is on"
    }
    if ($policy.Markasspamjavascriptinhtml -ne "on" ){              ## The MarkAsSpamJavaScriptInHtml parameter classifies the message as spam when the message contains JavaScript or VBScript.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam javascript in HTML is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam javascript in HTML is on"
    }
    if ($policy.Markasspamframesinhtml -ne "on" ){              ## The MarkAsSpamFramesInHtml parameter classifies the message as spam when the message contains HTML <frame> or <iframe> tags.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam frames in HTML is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam frames in HTML is on"
    }
    if ($policy.Markasspamobjecttagsinhtml -ne "on" ){              ## The MarkAsSpamObjectTagsInHtml parameter classifies the message as spam when the message contains HTML <object> tags.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam object tags in HTML is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam object tags in HTML is on"
    }
    if ($policy.Markasspamembedtagsinhtml -ne "on" ){               ## The MarkAsSpamEmbedTagsInHtml parameter classifies the message as spam when the message contains HTML <embed> tags. 
        write-host -foregroundcolor $errormessagecolor "   Mark as spam embedded tags in HTML is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam embedded tags in HTML is on"
    }
    if ($policy.Markasspamformtagsinhtml -ne "on" ){                ## The MarkAsSpamFormTagsInHtml parameter classifies the message as spam when the message contains HTML <form> tags.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam form tags in HTML is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam form tags in HTML is on"
    }
    if ($policy.Markasspamwebbugsinhtml -ne "on" ){                 ## The MarkAsSpamWebBugsInHtml parameter classifies the message as spam when the message contains web bugs.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam web bugs in HTML is not on"
    } else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam web bugs in HTML is on"
    }
    if ($policy.Markasspamsensitivewordlist -ne "on" ){             ## The MarkAsSpamSensitiveWordList parameter classifies the message as spam when the message contains words from the sensitive words list.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam sensitive word list is not on"
    }
    else{
        write-host -foregroundcolor $processmessagecolor "   Mark as spam sensitive word list is on"
    }
    if ($policy.Markasspamspfrecordhardfail -ne "on" ){             ## The MarkAsSpamSpfRecordHardFail parameter classifies the message as spam when Sender Policy Framework (SPF) record checking encounters a hard fail.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam SPF hard fail is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam SPF hard fail is on"
    }
    if ($policy.Markasspamfromaddressauthfail -ne "on" ){           ## The MarkAsSpamFromAddressAuthFail parameter classifies the message as spam when Sender ID filtering encounters a hard fail.
        write-host -foregroundcolor $errormessagecolor "   Mark as spam from address auth fail is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam from address auth fail is on"
    }
    if ($policy.Markasspamndrbackscatter -ne "on" ){                ## The MarkAsSpamNdrBackscatter parameter classifies the message as spam when the message is a non-delivery report (NDR) to a forged sender. 
        write-host -foregroundcolor $errormessagecolor "   Mark as spam back scatter is not on"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Mark as spam back scatter is on"
    }
    if ($policy.Phishspamaction -ne "movetojmf" ){                  ## The PhishSpamAction parameter specifies the action to take on messages that are classified as phishing (messages that use fraudulent links or spoofed domains to get personal information).
        write-host -foregroundcolor $errormessagecolor "   Phish spam action not set to movetojmf"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Phish spam action set to movetojmf"
    }
    if ($policy.Spamaction -ne "movetojmf" ){                       ## The SpamAction parameter specifies the action to take on messages that are classified as spam (not high confidence spam, bulk email, or phishing)).
        write-host -foregroundcolor $errormessagecolor "   Spam action not set to movetojmf"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Spam action set to movetojmf"
    }
    if ($policy.Zapenabled -ne "movetojmf" ){                       ## The ZapEnabled parameter specifies whether to enable zero-hour auto purge (ZAP). ZAP detects unread messages that have already been delivered to the user's Inbox. 
        write-host -foregroundcolor $errormessagecolor "   Zap action not enabled"
    }
    else {
        write-host -foregroundcolor $processmessagecolor "   Zap action enabled"
    }
    Write-Host
}

<#      Get existing Inbound rules       #>
Write-host -ForegroundColor $systemmessagecolor "Check for existing Inbound rules`n"
$ruleparams = Get-HostedContentFilterrule
        
Foreach ($ruleparam in $ruleparams) {
    Write-Host -ForegroundColor $processmessagecolor "Inbound Rule Name = ", $ruleparam.name
    write-host -ForegroundColor $processmessagecolor "   Rule attached policy =", $ruleparam.hostedcontentfilterpolicy
    write-host -ForegroundColor $processmessagecolor "   Protected domains = ", $ruleparam.recipientdomainis
    if ($ruleparam.state -eq "enabled") {
        write-host -ForegroundColor $processmessagecolor "   Enabled = ", $ruleparam.state        
    } else {
        write-host -ForegroundColor $errormessagecolor "   Enabled = ", $ruleparam.state        
    }
    Write-Host
}
<#      Get existing Outbound rules       #>
Write-host -ForegroundColor $systemmessagecolor "Check for existing Outbound policy`n"
$policyparams = get-hostedoutboundspamfilterpolicy
Write-Host -ForegroundColor $processmessagecolor "Outbound Policy Name = ", $policyparams.identity
if ([string]::IsNullOrEmpty($policyparams.bccsuspiciousoutboundadditionalrecipients)){    ## The BccSuspiciousOutboundAdditionalRecipients parameter specifies the recipients to add to the Bcc field of outgoing spam messages. Valid input for this parameter is an email address. Separate multiple email addresses with commas.
    write-host -foregroundcolor $errormessagecolor "   BCC suspicious outbound additional recipients is empty"
}
else {
    write-host -foregroundcolor $processmessagecolor "   BCC suspicious outbound additional recipients is = ",$policyparams.bccsuspiciousoutboundadditionalrecipients
}
if ($policyparams.bccsuspiciousoutboundmail -ne $true ){         ## The BccSuspiciousOutboundMail parameter enables or disables adding recipients to the Bcc field of outgoing spam messages.              
write-host -foregroundcolor $errormessagecolor "   BCC suspicious outbound email not enabled"
}
else {
write-host -foregroundcolor $processmessagecolor "   BCC suspicious outbound email enabled"
}
if ($policyparams.notifyoutboundspam -ne $true ){       ## The NotifyOutboundSpam parameter enables or disables sending notification messages to administrators when an outgoing message is determined to be spam.                 
write-host -foregroundcolor $errormessagecolor "   Notify outbound spam not enabled"
}
else {
write-host -foregroundcolor $processmessagecolor "   Notify outbound spam enabled"
}
if ([string]::IsNullOrEmpty($policyparams.NotifyOutboundSpamRecipients)){    ## The NotifyOutboundSpamRecipients parameter specifies the administrators to notify when an outgoing message is determined to be spam.
    write-host -foregroundcolor $errormessagecolor "   Notify outbound spam recipients is empty"
}
else {
    write-host -foregroundcolor $processmessagecolor "   Notify outbound spam recipients is = ",$policyparams.NotifyOutboundSpamRecipients
}
Write-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------