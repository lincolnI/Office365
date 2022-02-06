# Source: https://gcits.com/knowledge-base/export-a-list-of-mobile-devices-connected-to-office-365/

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
##$csv = "C:\relianceit\2018-08-01-MidwestDevices.csv"

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
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv" ## File Name and Path that will be saved

$results = @()
$mailboxUsers = get-mailbox -resultsize unlimited
$mobileDevice = @()
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Check all users and export if they have connected with a Mobile phone ################
#----------------------------------------------------------------

Clear-Host

write-host -foregroundcolor Cyan "`nScript started"

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
  write-host -foregroundcolor Cyan "`nFolder Created: $ReportPath"
}

$results | Select-Object Name,UPN,FriendlyName,DisplayName,ClientType,ClientVersion,DeviceId,DeviceMobileOperator,DeviceModel,DeviceOS,DeviceTelephoneNumber,DeviceType,FirstSyncTime,UserDisplayName | Export-Csv -notypeinformation -Path $resultsfile

write-host -foregroundcolor green "`nFile $resultsfile Created"
Invoke-Item $ReportPath

write-host -foregroundcolor Cyan "`nScript complete"
#----------------------------------------------------------------