<#
    .Link
    Check Office 365 account emails against Have I Been Pwned breaches: https://gcits.com/knowledge-base/check-office-365-accounts-against-have-i-been-pwned-breaches/
    
    .Description
    Script designed to tenant emails to see whether they appear in the haveibeenpwned.com database
    Adapted from the original script by Elliot Munro - https://gcits.com/knowledge-base/check-office-365-accounts-against-have-i-been-pwned-breaches/
 
 
    .Notes
    Prerequisites = 2
        1. Ensure msonline MFA module installed or updated
        2. Ensure you have connected to Exchange Online

    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
    Set-Executionpolicy remotesigned

#>

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "cyan"
$OutputColor = "green"
$ErrorColor = "Red"

#$FileName = Read-Host -Prompt 'What Tenent is this for' ## Prompt For file Name
$ClientName = Read-Host -Prompt 'What Tenent is this for'
	<#
	$Day = (Get-Date).Day
	$Month = (Get-Date).Month
	$Year = (Get-Date).Year
	$ReportName = ( "$Year" + "-" + "$Month" + "-" + "$Day" + "-" + "PWNedEmails-" + $ClientName)
	#>
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "PWNedEmails-" + $ClientName)
$ReportPath = "C:\RelianceIT\reports"   ## Local Path where report will be saved
$resultsfile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv" ## File Name and Path that will be saved
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Checking to see if any emails are found on  https://haveibeenpwned.com/ ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $systemmessagecolor "`nScript started`n"

## Script from Elliot start
#Connect-MsolService
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$headers = @{
    "User-Agent"  = "$((Get-MsolCompanyInformation).DisplayName) Account Check"
    "api-version" = 2 }

$baseUri = "https://haveibeenpwned.com/api"

# To check for admin status
$RoleId = (Get-MsolRole -RoleName "Company Administrator").ObjectId
$Admins = (Get-MsolRoleMember -RoleObjectId $RoleId | Select-object EmailAddress)
$Report = @()
$Breaches=0

Write-Host "Fetching mailboxes to check..."
$Users = (Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited | Select-object UserPrincipalName, EmailAddresses, DisplayName)
Write-Host "Processing" $Users.count "mailboxes..."

ForEach ($user in $users) {
    $Emails = $User.emailaddresses | Where-Object {$_ -match "smtp:" -and $_ -notmatch ".onmicrosoft.com"}
    $IsAdmin = $False
    $MFAUsed = $False
    $emails | ForEach-Object {
        $Email = ($_ -split ":")[1]
        $uriEncodeEmail = [uri]::EscapeDataString($Email)
        $uri = "$baseUri/breachedaccount/$uriEncodeEmail"
        $BreachResult = $null
        Try {
            [array]$breachResult = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction SilentlyContinue
        }
        Catch {
            if($error[0].Exception.response.StatusCode -match "NotFound"){
                Write-Host "No Breach detected for $email"
            }else{
                Write-Host "Cannot retrieve results due to rate limiting or suspect IP. You may need to try a different computer"
            }
        }
        if ($BreachResult) {
            $MSOUser = Get-MsolUser -UserPrincipalName $User.UserPrincipalName
            If ($Admins -Match $User.UserPrincipalName) {$IsAdmin = $True}
            If ($MSOUser.StrongAuthenticationMethods -ne $Null) {$MFAUsed = $True}
            ForEach ($Breach in $BreachResult) {
                 $ReportLine = [PSCustomObject][ordered]@{
                    Email              = $email
                    UserPrincipalName  = $User.UserPrincipalName
                    Name               = $User.DisplayName
                    LastPasswordChange = $MSOUser.LastPasswordChangeTimestamp
                    BreachName         = $breach.Name
                    BreachTitle        = $breach.Title
                    BreachDate         = $breach.BreachDate
                    BreachAdded        = $breach.AddedDate
                    BreachDescription  = $breach.Description
                    BreachDataClasses  = ($breach.dataclasses -join ", ")
                    IsVerified         = $breach.IsVerified
                    IsFabricated       = $breach.IsFabricated
                    IsActive           = $breach.IsActive
                    IsRetired          = $breach.IsRetired
                    IsSpamList         = $breach.IsSpamList
                    IsTenantAdmin      = $IsAdmin
                    MFAUsed            = $MFAUsed
                }

                $Report += $ReportLine
                Write-Host "Breach detected for $email - $($breach.name)" -ForegroundColor Red
                If ($IsAdmin -eq $True) {Write-Host "This is a tenant administrator account" -ForeGroundColor DarkRed}
                $Breaches++
                Write-Host $breach.Description -ForegroundColor Yellow
            }
        }
        Start-sleep -Milliseconds 2000
    }
}

If(!(test-path $ReportPath))
{
  New-Item -ItemType Directory -Path $ReportPath
  write-host -foregroundcolor Cyan "`nFolder Created: $ReportPath"
}

If ($Breaches -gt 0) {
    $Report | Export-CSV $resultsfile -NoTypeInformation
    Write-Host "Total breaches found: " $Breaches " You can find a report in "$resultsfile 
    Invoke-Item $ReportPath}
Else
  { Write-Host "Hurray - no breaches found for your Office 365 mailboxes" }

Write-Host -foregroundcolor $systemmessagecolor "`nScript complete`n"
#----------------------------------------------------------------