<# 
    .Description
    Here’s a script to find and report MFA-enabled accounts. The output is a CSV file. If your account is affected by the outage, you’ll need to sign into Office 365 with a breakglass account that can run PowerShell.
    
    .Link
    https://office365itpros.com/2018/11/21/reporting-mfa-enabled-accounts/
    https://docs.microsoft.com/en-us/azure/active-directory/authentication/howto-mfa-reporting
    
    .Prerequisites = 1
    1. Ensure connection to Exchange Online has already been completed

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
$ProcessMessageColor = "Green"
$ErrorMessageColor = "Red"
$WarnMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MFA-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Report = @()
$i = 0
$Accounts = (Get-MsolUser -All | ? {$_.StrongAuthenticationMethods -ne $Null} | Sort DisplayName)

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

ForEach ($Account in $Accounts) {
   Write-Host -foregroundcolor $ProcessMessageColor "Processing" $Account.DisplayName
   $i++
   $Methods = $Account | Select -ExpandProperty StrongAuthenticationMethods
   $MFA = $Account | Select -ExpandProperty StrongAuthenticationUserDetails
   $State = $Account | Select -ExpandProperty StrongAuthenticationRequirements
   $Methods | ForEach { If ($_.IsDefault -eq $True) {$Method = $_.MethodType}}
   If ($State.State -ne $Null) {$MFAStatus = $State.State}
      Else {$MFAStatus = "Disabled"}
   $ReportLine = [PSCustomObject][Ordered]@{
       User      = $Account.DisplayName
       UPN       = $Account.UserPrincipalName
       MFAMethod = $Method
       MFAPhone  = $MFA.PhoneNumber
       MFAEmail  = $MFA.Email
       #MFAStatus = $MFAStatus  
        }
   $Report += $ReportLine      }
Write-Host -foregroundcolor $ProcessMessageColor $i "accounts are MFA-enabled"
 
$Report | Export-CSV -NoTypeInformation $ResultsFile

write-host -foregroundcolor $ProcessMessageColor "`nFile $ResultsFileSummary & $ResultsFileDetail Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------