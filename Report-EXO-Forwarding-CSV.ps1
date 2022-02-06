<#
    .Link
    https://gcits.com/knowledge-base/find-inbox-rules-forward-mail-externally-office-365-powershell/

    .Description
    Find all Inbox Rules that forward mail externally from Office 365 using PowerShell
 
    .Notes
    Prerequisites = 1
        1. Ensure connection to Exchange Online has already been completed
    
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Tenant = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "OutlookForwardRules-" + $Tenant)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$Reportfile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Connect 365
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ConnectEXO = Read-Host "`nWould you like to Connect to Exchange Online (Y\N)?"

If ($ConnectEXO -eq "Y") {
   
    ## Remove existing sessions
    Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

    Write-host -ForegroundColor $SystemMessageColor "`nStart - Connecting to Exchange Online"
    
    ## Start Exchange Online session
    write-host -foregroundcolor $processmessagecolor "`nStart - Exchange login"
    Import-Module ExchangeOnline
    Connect-ExchangeOnline
    write-host -foregroundcolor $processmessagecolor "Finish - Exchange login`n`n"   
}

Else {
Write-host -ForegroundColor $processmessagecolor "Continuing with current Exchange Online Session"
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Domains = Get-AcceptedDomain
$MailBoxes = Get-Mailbox -ResultSize Unlimited
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#----------------------------------------------------------------



#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}



foreach ($mailbox in $mailboxes) {
 
    $forwardingRules = $null
    Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)" -foregroundColor $ProcessMessageColor
    $rules = get-inboxrule -Mailbox $mailbox.primarysmtpaddress
     
    $forwardingRules = $rules | Where-Object {$_.forwardto -or $_.forwardasattachmentto}
 
    foreach ($rule in $forwardingRules) {
        $recipients = @()
        $recipients = $rule.ForwardTo | Where-Object {$_ -match "SMTP"}
        $recipients += $rule.ForwardAsAttachmentTo | Where-Object {$_ -match "SMTP"}
     
        $externalRecipients = @()
 
        foreach ($recipient in $recipients) {
            $email = ($recipient -split "SMTP:")[1].Trim("]")
            $domain = ($email -split "@")[1]
 
            if ($domains.DomainName -notcontains $domain) {
                $externalRecipients += $email
            }    
        }
 
        if ($externalRecipients) {
            $extRecString = $externalRecipients -join ", "
            Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor $InfoColor
 
            $ruleHash = $null
            $ruleHash = [ordered]@{
                PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                DisplayName        = $mailbox.DisplayName
                RuleId             = $rule.Identity
                RuleName           = $rule.Name
                RuleDescription    = $rule.Description
                ExternalRecipients = $extRecString
            }
            $ruleObject = New-Object PSObject -Property $ruleHash
            $ruleObject | Export-Csv $Reportfile -NoTypeInformation -Append
        }
    }
}


write-host -foregroundcolor $OutputColor "`nFile $Reportfile Created"
Invoke-Item $ReportPath
Invoke-Item $Reportfile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------