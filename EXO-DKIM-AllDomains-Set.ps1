<#
    .Link
    https://docs.microsoft.com/en-gb/microsoft-365/security/office-365-security/use-dkim-to-validate-outbound-email?view=o365-worldwide
    https://docs.microsoft.com/en-us/powershell/module/exchange/antispam-antimalware/get-dkimsigningconfig?view=exchange-ps
    https://www.verboon.info/2019/01/how-to-enable-dkim-in-office-365/
    https://www.vansurksum.com/2019/11/25/did-you-already-enable-dkim-and-dmarc-for-your-office-365-domains/
    https://my.101domain.com/dashboard.html

    .Description
    Enable
 
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


foreach ($Domain in $Domains) 
{
    # Set existing DKIM (using Exchange Online PowerShell).
    
    write-host -foregroundcolor $SystemMessageColor " `nStart - Enabling DKIM $Domain "
    Set-DkimSigningConfig -Identity $Domain -Enabled $true
    write-host -foregroundcolor $ProcessMessageColor " Finiah - DKIM Keys for $Domain`n "
    
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------