
#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#Ask for User you are disabling
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'User'
$msg   = 'Enter Email of User to Disable:'
$user = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
#----------------------------------------------------------------

#----------------------------------------------------------------
################# Convert to a Shared Mailbox ################
#----------------------------------------------------------------
Get-Mailbox -identity $user | set-mailbox -type "Shared"
Set-Mailbox -Identity $user -HiddenFromAddressListsEnabled $true
write-host -foregroundcolor green "$User has been converted to a Shared Account and hidden from the GAL"
#----------------------------------------------------------------

#----------------------------------------------------------------
################# Remove Licence From User Account ################
#----------------------------------------------------------------
$userLicense = Get-MsolUser -UserPrincipalName $user
Set-MsolUserLicense -UserPrincipalName $user -RemoveLicenses $userLicense.Licenses.AccountSkuId
write-host -foregroundcolor green "$User has had their licence removed"
#----------------------------------------------------------------