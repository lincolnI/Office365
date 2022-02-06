<# 
https://www.lukasberan.com/2016/03/bulk-change-office-365-licenses/

Need to run: MsolAccountSku
to get the current licence SKU

#>

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


$oldLicense = "reseller-account:SPE_E3"
$newLicense = "reseller-account:SPE_E5"


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


$users = Get-MsolUser -MaxResults 5000 | Where-Object { $_.isLicensed -eq "TRUE" }
 
foreach ($user in $users){
    $upn = $user.UserPrincipalName
    foreach ($license in $user.Licenses) {
        if ($license.AccountSkuId -eq $oldLicense) {
            $disabledPlans = @()
            Write-Host("User $upn will go from $oldLicense to $newLicense and will have no options disabled.")
            Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $newLicense -RemoveLicenses $oldLicense
        }
    }
}


Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------



<#

.Notes 
Removing licence only:

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


$oldLicense = "joblinkplus:EOP_ENTERPRISE_PREMIUM_FACULTY"


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


$users = Get-MsolUser -MaxResults 5000 | Where-Object { $_.isLicensed -eq "TRUE" }
 
foreach ($user in $users){
    $upn = $user.UserPrincipalName
    foreach ($license in $user.Licenses) {
        if ($license.AccountSkuId -eq $oldLicense) {
            $disabledPlans = @()
            Write-Host("$oldLicense is being removed from $upn.")
            Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $oldLicense
        }
    }
}


Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------

$upn = "hannah.parry@joblinkplus.com.au"
$oldLicense = "joblinkplus:EOP_ENTERPRISE_PREMIUM_FACULTY"
Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $oldLicense

#>