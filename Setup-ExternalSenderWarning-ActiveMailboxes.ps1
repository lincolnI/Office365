<#
    .Link
    https://gcits.com/knowledge-base/warn-users-external-email-arrives-display-name-someone-organisation/

    .Description
    Warn users when an email arrives from a sender with the same display name as someone in your organisation
    
    .SYNOPSIS
    How to use a PowerShell script to warn users when an external sender’s display name matches someone in your company
    This guide will demonstrate how to use PowerShell to create a transport rule to warn users when a new email was sent from a sender 
    with the same display name as another user in your organisation.

    For each of our managed customers, we apply a transport rule using PowerShell and Office 365 delegated administration. 
    If a matching display name is detected, a warning message is prepended to the email:Warning On External Email With Matching Display Name
    
    "This message was sent from outside the company by someone with a display name matching a user in your organisation. Please do not click links or open attachments unless you recognise the source of this email and know the content is safe."
    
    We’ve set this up as an Azure Function, and have included instructions below for you to do this yourself, as well as some standalone scripts that you can run when required.

    Some things to keep in mind
    > These rules are best suited to smaller organisations due to size limits on Exchange Transport Rules (8KB per rule). 
    Under 300 mailboxes should work OK, depending on the average length of their display names. If you’d like to run this rule on a larger organisation, 
    you will need to specify a smaller string array for the $displayNames value. 
    This could be achieved by filtering the Get-Mailbox cmdlet by a specific attribute to return users of a certain type (eg. finance team), 
    or by defining your own string array with a list of display names. Feel free to get in touch with me for more info on configuring this.
    
    > These scripts do not support MFA. To run them with MFA enabled accounts, you can whitelist your current static IP, or the IPs of your Azure Functions
 
    .Notes
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ruleName = "External Senders with matching Display Names"
$ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#910A19;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#FDF2F4;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message was sent from outside the company by someone with a display name matching a user in your organisation. Please do not click links or open attachments unless you recognise the source of this email and know the content is safe. <o:p></o:p></span></p></div></td></tr></table>"

$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
$displayNames = (Get-AzureADUser -All $True | Where {$_.UserType -eq 'Member' -and $_.AssignedLicenses -ne $null}).DisplayName

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Connect-AzureAD

Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


if (!$rule) {
    Write-Host "Rule not found, creating rule" -ForegroundColor $ProcessMessageColor
    New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
        -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
}
else {
    Write-Host "Rule found, updating rule" -ForegroundColor $ProcessMessageColor
    Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
        -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
}


Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------