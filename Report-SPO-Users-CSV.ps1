<#
    .Link
    https://github.com/directorcia/patron/blob/master/o365-spo-user-csv.ps1

    .Description
    Script designed to log into the show all SharePoint Online users across all site collections and export to CSV file

    .Notes
    Prerequisites = 1
        1. Ensure SharePoint online PowerShell module installed or updated

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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LocalHost = $env:COMPUTERNAME
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "AllSPOUsers-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

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


## ensure that SharePoint Online modeule has been installed and loaded

Write-host -ForegroundColor $processmessagecolor "Getting all Sharepoint sites in tenant"
$SiteCollections  = Get-SPOSite -Limit All

foreach ($site in $SiteCollections) ## Loop through all Site Collections in tenant
{
    Write-host -ForegroundColor $processmessagecolor "Checking site:",$site.url

    Get-SPOuser -Site $site.Url | select-object @{Name = "Url" ; Expression = { $site.url }},displayname,loginname,issiteadmin,groups,usertype | Export-Csv -Path $ResultsFile -NoTypeInformation -append
}


write-host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------