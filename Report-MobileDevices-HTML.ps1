#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "cyan"
$OutputColor = "green"
$ErrorColor = "Red"

##$FileName = Read-Host -Prompt 'Date and Client for this report [i.e. 2018-01-01-Aurelia]' ## Prompt For file Name
$ClientName = Read-Host -Prompt 'What Tenent is this for'
  <#
  $Day = (Get-Date).Day
  $Month = (Get-Date).Month
  $Year = (Get-Date).Year
  $ReportName = ( "$Year" + "-" + "$Month" + "-" + "$Day" + "-" + "MobileDevices-" + $ClientName)
  #>
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MobileDevices-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.htm" ## File Name and Path that will be saved

$results = @()
$mailboxUsers = get-mailbox -resultsize unlimited
$mobileDevice = @()

#----------------------------------------------------------------

#----------------------------------------------------------------
################# HTML ################
#----------------------------------------------------------------
$HeaderColourAdv = @"
<style>
h1, h5, th { text-align: center; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Check all users and export if they have connected with a Mobile phone ################
#----------------------------------------------------------------

Clear-Host

Write-Host -foregroundcolor $systemmessagecolor "`nScript started`n"

foreach($user in $mailboxUsers)
{
$UPN = $user.UserPrincipalName
$displayName = $user.DisplayName

$mobileDevices = Get-MobileDevice -Mailbox $UPN
   
  foreach($mobileDevice in $mobileDevices)
  {
      Write-Output "Getting info about a device for $displayName"
      $properties = @{
      Name = $user.name
      UPN = $UPN
      DisplayName = $displayName
      FriendlyName = $mobileDevice.FriendlyName
      ClientType = $mobileDevice.ClientType
      ClientVersion = $mobileDevice.ClientVersion
      DeviceId = $mobileDevice.DeviceId
      DeviceMobileOperator = $mobileDevice.DeviceMobileOperator
      DeviceModel = $mobileDevice.DeviceModel
      DeviceOS = $mobileDevice.DeviceOS
      DeviceTelephoneNumber = $mobileDevice.DeviceTelephoneNumber
      DeviceType = $mobileDevice.DeviceType
      FirstSyncTime = $mobileDevice.FirstSyncTime
      UserDisplayName = $mobileDevice.UserDisplayName
      }
      $results += New-Object psobject -Property $properties
  }
}

If(!(test-path $ReportPath))
{
  New-Item -ItemType Directory -Path $ReportPath
  write-host -foregroundcolor $OutputColor "`nFolder Created: $ReportPath"
}

$results | Select-Object Name,UPN,FriendlyName,DisplayName,ClientType,ClientVersion,DeviceId,DeviceMobileOperator,DeviceModel,DeviceOS,DeviceTelephoneNumber,DeviceType,FirstSyncTime,UserDisplayName | ConvertTo-Html -Head $HeaderColourAdv | Out-File -FilePath $ResultsFile

Write-Host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $systemmessagecolor "`nScript complete`n"
#----------------------------------------------------------------