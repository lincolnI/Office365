<#
    .Description
    Script designed report on mailbox logins from Office 365 Audit logs

    .Source

    .Prerequisites = 1
    1. Connected to Exchange Online

    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
#>


#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$ProcessMessageColor = "green"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MailboxLogins-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Hours = 720                                 ## number of hours to check across
$EndDate = Get-Date                         ## Ending date for audit log search MM/DD/YYYY
$StartDate = $enddate.AddHours(-$hours)     ## Starting date for audit log search MM/DD/YYYY
$SesID="0"                                  ## change this if you want to re-reun the script multiple times in a single session
$Results = @()                              ## where the ultimate results end up
$StrCurrentTimeZone = (Get-WmiObject win32_timezone).StandardName           ## determine current local timezone
$TZ = [System.TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)    ## for Timezone calculations
$AuditOutput = 1                            ## Set variable value to trigger loop below (can be anything)
$ConvertedOutput=""

<# Valid record types = 
AzureActiveDirectory, AzureActiveDirectoryAccountLogon,AzureActiveDirectoryStsLogon, ComplianceDLPExchange
ComplianceDLPSharePoint, CRM, DataCenterSecurityCmdlet, Discovery, ExchangeAdmin, ExchangeAggregatedOperation
ExchangeItem, ExchangeItemGroup, MicrosoftTeams, MicrosoftTeamsAddOns, MicrosoftTeamsSettingsOperation, OneDrive
PowerBIAudit, SecurityComplianceCenterEOPCmdlet, SharePoint, SharePointFileOperation, SharePointSharingOperation
SkypeForBusinessCmdlets, SkypeForBusinessPSTNUsage, SkypeForBusinessUsersBlocked, Sway, ThreatIntelligence, Yammer
#>
$RecordType = "ExchangeItem"

## Office 365 Management Activity API schema
## Valid record types = https://docs.microsoft.com/en-us/office365/securitycompliance/search-the-audit-log-in-security-and-compliance?redirectSourcePath=%252farticle%252f0d4d0f35-390b-4518-800e-0c7ec95e946c#audited-activities
## Operation types = "<value1>","<value2>","<value3>"
$Operation="mailboxlogin" ## use this line to report all mailbox logins

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

# Loop will run until $AuditOutput returns null which equals that no more event objects exists from the specified date
while ($AuditOutput) {
    # Search the defined date(s), SessionId + SessionCommand in combination with the loop will return and append 100 object per iteration until all objects are returned (minimum limit is 50k objects)
    write-host -foregroundcolor $processmessagecolor "Searching Audit logs. Please wait"
    $AuditOutput = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -recordtype $recordtype -operations $operation -SessionId $sesid -SessionCommand ReturnLargeSet
    # Select and expand the nested object (AuditData) as it holds relevant reporting data. Convert output format from default JSON to enable export to csv
    $ConvertedOutput = $AuditOutput | Select-Object -ExpandProperty AuditData | ConvertFrom-Json
    # Export results exluding type information. Append rather than overwrite if the file exist in destination folder
    foreach ($Entry in $convertedoutput)
    {  
        $return = "" | select-object Creationtime,Localtime,UserId,Operation,clientipaddress
        $data = $Entry | Select-Object Creationtime,userid,operation,clientipaddress
        $return.Creationtime = $data.CreationTime
        $return.localtime = [System.TimeZoneInfo]::ConvertTimeFromUtc($data.Creationtime, $TZ)
        $return.clientipaddress = $data.ClientIPaddress
        $return.UserId = $data.UserId
        #Obtain the UserAgent string from inside the
        $return.Operation = $data.Operation
        #Returns the data to outside of the loop
        $Results += $return
    }
}
$results | Out-GridView                                 ## Output results to screen
write-host -foregroundcolor $processmessagecolor "Writing CSV file to",$ResultsFile
$results | export-csv -path $ResultsFile -NoTypeInformation    ## Export array results to CSV file


Write-Host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host
Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------