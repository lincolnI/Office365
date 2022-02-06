## Description
## Script designed export audit logs into separate CSV files based on workload.

## Source - Patron only

## Prerequisites = 1
## 1. Connected to Exchange Online


#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$startdate = "06/20/2019"     ## Starting date for audit log search MM/DD/YYYY
$enddate = "07/22/2019"      ## Ending date for audit log search MM/DD/YYYY
$sesid="3"                  ## change this if you want to re-reun the script multiple times in a single session
$Results = @()              ## where the ultimate results end up
$strCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName           ## determine current local timezone
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)    ## for Timezone calculations
$AuditOutput = 9            ## Set variable value to trigger loop below (can be anything)
$convertedoutput=""
$logdir = "C:\RelianceIT\Reports\"

#----------------------------------------------------------------

## Valid record types = 
## AzureActiveDirectory, AzureActiveDirectoryAccountLogon,AzureActiveDirectoryStsLogon, ComplianceDLPExchange
## ComplianceDLPSharePoint, CRM, DataCenterSecurityCmdlet, Discovery, ExchangeAdmin, ExchangeAggregatedOperation
## ExchangeItem, ExchangeItemGroup, MicrosoftTeams, MicrosoftTeamsAddOns, MicrosoftTeamsSettingsOperation, OneDrive
## PowerBIAudit, SecurityComplianceCenterEOPCmdlet, SharePoint, SharePointFileOperation, SharePointSharingOperation
## SkypeForBusinessCmdlets, SkypeForBusinessPSTNUsage, SkypeForBusinessUsersBlocked, Sway, ThreatIntelligence, Yammer


## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $logdir)) {
    New-Item -ItemType Directory -Path $logdir
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $logdir"
}


# Loop will run until $AuditOutput returns null which equals that no more event objects exists from the specified date
while ($AuditOutput) {
    # Search the defined date(s), SessionId + SessionCommand in combination with the loop will return and append 100 object per iteration until all objects are returned (minimum limit is 50k objects)
    write-host -foregroundcolor $processmessagecolor "Searching Audit logs. Please wait"
    $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -SessionId $sesid -SessionCommand ReturnLargeSet
    # Select and expand the nested object (AuditData) as it holds relevant reporting data. Convert output format from default JSON to enable export to csv
    try {
        $ConvertedOutput = $AuditOutput | Select-Object -ExpandProperty AuditData | ConvertFrom-Json
    }
    catch {
        write-host -ForegroundColor $errormessagecolor "Conversion from JSON failed"
        $convertedoutput | Out-File -filepath ($logdir+"auditconvertfail.txt") -append -force
    }
    foreach ($Entry in $convertedoutput)
    {  
        write-host $entry.workload
        if($entry.workload -eq "exchange") {
            $entry | export-csv -path ($logdir+"auditexch.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ExchangeAdmin") {
            $entry | export-csv -path ($logdir+"auditexchadmin.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ExchangeItem") {
            $entry | export-csv -path ($logdir+"auditexchitem.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ExchangeItemGroup") {
            $entry | export-csv -path ($logdir+"auditexchitemgrp.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SharePoint") {
            $entry | export-csv -path ($logdir+"auditspo.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SyntheticProbe") {
            $entry | export-csv -path ($logdir+"auditsyncprobe.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SharePointFileOperation") {
            $entry | export-csv -path ($logdir+"auditspofileop.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "OneDrive") {
            $entry | export-csv -path ($logdir+"auditonedrive.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "AzureActiveDirectory") {
            $entry | export-csv -path ($logdir+"auditaad.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "Azure ActiveDirectorylogon") {
            $entry | export-csv -path ($logdir+"auditaadlogon.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "DataCenterSecurityCmdlet") {
            $entry | export-csv -path ($logdir+"auditdcseccmdlet.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ComplianceDLPSharePoint") {
            $entry | export-csv -path ($logdir+"auditcompliancespo.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "Sway") {
            $entry | export-csv -path ($logdir+"auditsway.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ComplianceDLPExchange") {
            $entry | export-csv -path ($logdir+"auditcompldlpexch.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SharePointSharingOperations") {
            $entry | export-csv -path ($logdir+"auditsposharing.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "AzureActiveDirecoryStsLogon") {
            $entry | export-csv -path ($logdir+"auditaadstslogon.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SkypeforBusinessPSTNUsage") {
            $entry | export-csv -path ($logdir+"auditskypepstnusage.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SkypeforBusinessusersBlocked") {
            $entry | export-csv -path ($logdir+"auditskypeblock.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SecurityComplianceCenterEOPCmdlet") {
            $entry | export-csv -path ($logdir+"auditSeccompeopcmdlet.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ExchangeAggregatedOperation") {
            $entry | export-csv -path ($logdir+"auditexchaggop.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "PowerBIAudit") {
            $entry | export-csv -path ($logdir+"auditpowerbi.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "CRM") {
            $entry | export-csv -path ($logdir+"auditcrm.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "Yammer") {
            $entry | export-csv -path ($logdir+"audityammer.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "SkypeforBusinessCmdlets") {
            $entry | export-csv -path ($logdir+"auditskypecmdlets.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "Discovery") {
            $entry | export-csv -path ($logdir+"auditdiscovery.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "MicrosoftTeams") {
            $entry | export-csv -path ($logdir+"auditteams.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "MicrosoftTeamsAddon") {
            $entry | export-csv -path ($logdir+"auditteamsaddon.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "MicrosoftTeamsSettingsOperation") {
            $entry | export-csv -path ($logdir+"auditteamsop.csv") -notypeinformation -append -force
        } elseif ($entry.workload -eq "ThreatIntelligence") {
            $entry | export-csv -path ($logdir+"auditthreatintel.csv") -notypeinformation -append -force
        } else {
            $entry | export-csv -path ($logdir+"auditmisc.csv") -notypeinformation -append -force
        }
    }
}

Invoke-Item $LogDir

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------