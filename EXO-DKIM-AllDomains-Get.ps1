<#
    .Link
    https://docs.microsoft.com/en-gb/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email?view=o365-worldwide
    https://docs.microsoft.com/en-us/powershell/module/exchange/antispam-antimalware/get-dkimsigningconfig?view=exchange-ps
    https://www.verboon.info/2019/01/how-to-enable-dkim-in-office-365/
    https://www.vansurksum.com/2019/11/25/did-you-already-enable-dkim-and-dmarc-for-your-office-365-domains/
    https://my.101domain.com/dashboard.html

    .Description
    Report on all DKIM Keys in a Tenant
 
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
$OutputColor = "Green"
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LocalHost = $env:COMPUTERNAME
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "DKIM-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#$Domains = Get-Mailbox -ResultSize Unlimited | Select-Object EmailAddresses -ExpandProperty EmailAddresses | Where-Object { $_ -like "smtp*"} | ForEach-Object { ($_ -split "@")[1] } | Sort-Object -Unique
$Domains = Get-MsolDomain | Select Name | ForEach-Object { ($_ -split "@{name=")[1] } | ForEach-Object { $_.Trim("}") } | Sort-Object -Unique

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



foreach ($Domain in $Domains) 
{
    
    # Enable new DKIM (using Exchange Online PowerShell).
    New-DkimSigningConfig -DomainName $Domain -Enabled $false -erroraction 'silentlycontinue'
  
    $DKIM = Get-DkimSigningConfig -Identity $Domain | Format-List Selector1CNAME, Selector2CNAME
    write-host -foregroundcolor $InfoColor " DKIM Keys for $Domain "
    $DKIM
    Get-DkimSigningConfig -Identity $Domain | select-object Identity, Selector1CNAME, Selector2CNAME| export-csv $ResultsFile -notypeinformation -append    

}


write-host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------