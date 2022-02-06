param(                         ## if no parameter used then login without MFA and use interactive mode
    [switch]$nodebug = $false, ## if -nodebug parameter don't prompt for input 
    [switch]$txt = $false      ## if -txt parameter used then record transcript
)

<#
    .Link
    Documentation - 
    Source - https://github.com/directorcia/patron/blob/master/o365-activity-alerts-get.ps1 

    .Description
    Designed to show the Activity Alerts in the Security and Compliance Center

 
    .Notes
    Prerequisites = 1
        1. Connect to Office 365 Security and Compliance Center

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

$pass = "(.)"
$fail = "(X)"


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

If ($txt) { start-transcript "..\o365-activity-alerts $(get-date -f yyyyMMddHHmmss).txt" }

Write-Host -ForegroundColor $systemmessagecolor "Script started`n"

$checkpolicy = Get-activityalert                ## get existing policies

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

foreach ($policy in $checkpolicy) {
    write-host -foregroundcolor gray -BackgroundColor Black "Protection alert =", $policy.name
    write-host -ForegroundColor $processmessagecolor "    Operation = "$policy.Operation
    Write-host -foregroundcolor $processmessagecolor "    Notify user = "$policy.NotifyUser
    Write-host -foregroundcolor $processmessagecolor "    Severity = "$policy.Severity
    Write-host -foregroundcolor $processmessagecolor "    Category = "$policy.Category
    Write-host -foregroundcolor $processmessagecolor "    Comment = "$policy.description
    Write-host -foregroundcolor $processmessagecolor "    Mode = "$policy.mode
    If ($policy.disabled) {
        ## if policy is enabled
        Write-host -foregroundcolor $errormessagecolor "    Disabled = "$policy.disabled,$fail
    }
    else {
        Write-host -foregroundcolor $processmessagecolor "    Disabled = "$policy.disabled
    }    
    Write-host -foregroundcolor $processmessagecolor "    Created by = "$policy.createdby
    Write-host -foregroundcolor $processmessagecolor "    Created = "$policy.whencreated
    Write-host -foregroundcolor $processmessagecolor "    Modified by = "$policy.lastmodifiedby
    Write-host -foregroundcolor $processmessagecolor "    Modified = "$policy.whenchanged
    Write-Host
    If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"

If ($txt) { stop-transcript }

#----------------------------------------------------------------