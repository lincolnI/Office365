Get-ADUser -Filter {(enabled -eq $false)} | Set-adUser -Add @{msExchHideFromAddressLists="TRUE"}