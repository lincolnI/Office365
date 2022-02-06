## Description
## Script designed to deploy popular Outlook addins centrally

## Source - https://github.com/directorcia/Office365/blob/master/o365-addin-deploy.ps1

## Reference - https://docs.microsoft.com/en-us/office365/enterprise/use-the-centralized-deployment-powershell-cmdlets-to-manage-add-ins

## Prerequisites = 1
## 1. Ensure connected to the Office 365 Central Deployment Service

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"

#Addins
$ReportMessage = '6046742c-3aee-485e-a4ac-92ab7199db2e'
$MessageHeaderAnalyser = '62916641-fc48-44ae-a2a3-163811f1c945'
$FindTime = '9758a0e2-7861-440f-b467-1823144e5b65'
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


## Deploy addins from Office store
## You will receive an error if the addin is already installed in tenant
## Change the locale to suit your region
New-OrganizationAddIn -AssetId 'WA104381180' -Locale 'en-AU' -ContentMarket 'en-AU' ## Report Message
New-OrganizationAddIn -AssetId 'WA104005406' -Locale 'en-AU' -ContentMarket 'en-AU' ## Message Header Analyzer
New-OrganizationAddIn -AssetId 'WA104379803' -Locale 'en-AU' -ContentMarket 'en-AU' ## FindTime

## Enable in tenant
Set-OrganizationAddIn -ProductId $ReportMessage -Enabled $true ## Report Message
Set-OrganizationAddIn -ProductId $MessageHeaderAnalyser -Enabled $true ## Message Header Analyser
Set-OrganizationAddIn -ProductId $FindTime -Enabled $true ## FindTime

## Assign addins to all users
Set-OrganizationAddInAssignments -ProductId $ReportMessage -AssignToEveryone $true ## Report Message
Set-OrganizationAddInAssignments -ProductId $MessageHeaderAnalyser -AssignToEveryone $true ## Message Header Analyzer
Set-OrganizationAddInAssignments -ProductId $FindTime -AssignToEveryone $true ## FindTime

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------