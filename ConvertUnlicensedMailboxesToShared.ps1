Write-Host -foregroundcolor Green "Gathering Unlicensed Users with User Mailboxes.."
$a = Get-Mailbox -Resultsize Unlimited | where {($_.recipienttypedetails -eq "UserMailbox") -and ($_.skuassigned -ne "True")}

Write-Host -foregroundcolor Green "`Calculation Complete there are" $a.Count " mailboxes to convert."
foreach ($User in $a)
{
    $name = $User.Alias
    Try {
    Set-Mailbox -identity $name -type "Shared" -EA Stop
    Write-Host -foregroundcolor Yellow "` $name has been converted to a Shared Mailbox" }

    Catch { 
    Write-Host -foregroundcolor Red "`Error converting $name"
    "     " 
    $error
    }
}

