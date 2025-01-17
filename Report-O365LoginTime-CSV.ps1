<#
    .Link
    https://o365reports.com/2019/03/07/export-office-365-users-last-logon-time-csv/
    https://gallery.technet.microsoft.com/office/Export-Office-365-Users-ae3463f2

    .Description
    This user-friendly PowerShell script exports Office 365 users' login history report to CSV file. Logon history includes both successful and failed login attempts. This script supports MFA, Scheduling and more advanced filtering options too.

 
    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
    Set-Executionpolicy remotesigned

#>

Param
(
    [Parameter(Mandatory = $false)]
    [int]$InactiveDays,
    [switch]$UserMailboxOnly,
    [switch]$ReturnNeverLoggedInMB,
    [string]$UserName,
    [string]$Password,
    [switch]$MFA

)

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
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "UserLogins-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ExportCSV = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$IntervalTimeInMinutes=1440    #$IntervalTimeInMinutes=Read-Host Enter interval time period '(in minutes)'
$CurrentStart=$StartDate
$CurrentEnd=$CurrentStart.AddMinutes($IntervalTimeInMinutes)


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


#Check for MSOnline module
$Modules=Get-Module -Name MSOnline -ListAvailable
if($Modules.count -eq 0)
{
  Write-Host  Please install MSOnline module using below command: `nInstall-Module MSOnline  -ForegroundColor yellow
  Exit
}

#Connect AzureAD and Exchange Online from PowerShell
Get-PSSession | Remove-PSSession

#Get friendly name of license plan from external file
$FriendlyNameHash=Get-Content -Raw -Path .\LicenseFriendlyName.txt -ErrorAction Stop | ConvertFrom-StringData


#Set output file
#$ExportCSV=".\LastLogonTimeReport_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"

#Authentication using MFA
 if($MFA.IsPresent)
 {
  $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
  If ($MFAExchangeModule -eq $null)
  {
   Write-Host  `nPlease install Exchange Online MFA Module.  -ForegroundColor yellow

   Write-Host You can install module using below blog : `nhttps://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/ `nOR you can install module directly by entering "Y"`n
   $Confirm= Read-Host Are you sure you want to install module directly? [Y] Yes [N] No
   if($Confirm -match "[yY]")
   {
     Write-Host Yes
     Start-Process "iexplore.exe" "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
   }
   else
   {
    Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
    Exit
   }
   $Confirmation= Read-Host Have you installed Exchange Online MFA Module? [Y] Yes [N] No

    if($Confirmation -match "[yY]")
    {
     $MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
     If ($MFAExchangeModule -eq $null)
     {
      Write-Host Exchange Online MFA module is not available -ForegroundColor red
      Exit
     }
    }
    else
    {
     Write-Host Exchange Online PowerShell Module is required
     Start-Process 'https://o365reports.com/2019/04/17/connect-exchange-online-using-mfa/'
     Exit
    }

   }

  #Importing Exchange MFA Module
  . "$MFAExchangeModule"
  Write-Host Enter credential in prompt to connect to Exchange Online
  Connect-EXOPSSession -WarningAction SilentlyContinue
  Write-Host Connected to Exchange Online
  Write-Host `nEnter credential in prompt to connect to MSOnline
  #Importing MSOnline Module
  Connect-MsolService | Out-Null
  Write-Host Connected to MSOnline `n`nReport generation in progress...
 }
 #Authentication using non-MFA
 else
 {
  #Storing credential in script for scheduling purpose/ Passing credential as parameter
  if(($UserName -ne "") -and ($Password -ne ""))
  {
   $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
   $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword
  }
  else
  {
   $Credential=Get-Credential -Credential $null
  }
  Connect-MsolService -Credential $credential
  $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
  Import-PSSession $Session -CommandName Get-Mailbox,Get-MailboxStatistics -FormatTypeName * -AllowClobber | Out-Null
 }

$Result=""
$Output=@()
$MBUserCount=0
$OutputCount=0


Get-Mailbox -ResultSize Unlimited | Where{$_.DisplayName -notlike "Discovery Search Mailbox"} | ForEach-Object{
 $upn=$_.UserPrincipalName
 $CreationTime=$_.WhenCreated
 $LastLogonTime=(Get-MailboxStatistics -Identity $upn).lastlogontime
 $Office=(Get-MsolUser -user $upn).office
 $DisplayName=$_.DisplayName
 $MBType=$_.RecipientTypeDetails
 $Print=1
 $MBUserCount++
 $RolesAssigned=""
 Write-Progress -Activity "`n     Processed mailbox count: $MBUserCount "`n"  Currently Processing: $DisplayName"

 #Retrieve lastlogon time and then calculate Inactive days
 if($LastLogonTime -eq $null)
 {
   $LastLogonTime ="Never Logged In"
   $InactiveDaysOfUser="-"
 }
 else
 {
   $InactiveDaysOfUser= (New-TimeSpan -Start $LastLogonTime).Days
 }

 #Get licenses assigned to mailboxes
 $User=(Get-MsolUser -UserPrincipalName $upn)
 $Licenses=$User.Licenses.AccountSkuId
 $AssignedLicense=""
 $Count=0

 #Convert license plan to friendly name
 foreach($License in $Licenses)
 {
    $Count++
    $LicenseItem= $License -Split ":" | Select-Object -Last 1
    $EasyName=$FriendlyNameHash[$LicenseItem]
    if(!($EasyName))
    {$NamePrint=$LicenseItem}
    else
    {$NamePrint=$EasyName}
    $AssignedLicense=$AssignedLicense+$NamePrint
    if($count -lt $licenses.count)
    {
      $AssignedLicense=$AssignedLicense+","
    }
 }
 if($Licenses.count -eq 0)
 {
  $AssignedLicense="No License Assigned"
 }

 #Inactive days based filter
 if($InactiveDaysOfUser -ne "-"){
 if(($InactiveDays -ne "") -and ([int]$InactiveDays -gt $InactiveDaysOfUser))
 {
  $Print=0
 }}

 #License assigned based filter
 if(($UserMailboxOnly.IsPresent) -and ($MBType -ne "UserMailbox"))
 {
  $Print=0
 }

 #Never Logged In user
 if(($ReturnNeverLoggedInMB.IsPresent) -and ($LastLogonTime -ne "Never Logged In"))
 {
  $Print=0
 }

 #Get roles assigned to user
 $Roles=(Get-MsolUserRole -UserPrincipalName $upn).Name
 if($Roles.count -eq 0)
 {
  $RolesAssigned="No roles"
 }
 else
 {
  foreach($Role in $Roles)
  {
   $RolesAssigned=$RolesAssigned+$Role
   if($Roles.indexof($role) -lt (($Roles.count)-1))
   {
    $RolesAssigned=$RolesAssigned+","
   }
  }
 }

 #Export result to CSV file
 if($Print -eq 1)
 {
  $OutputCount++
  $Result=@{'UserPrincipalName'=$upn;'DisplayName'=$DisplayName;'LastLogonTime'=$LastLogonTime;'CreationTime'=$CreationTime;'InactiveDays'=$InactiveDaysOfUser;'MailboxType'=$MBType;'AssignedLicenses'=$AssignedLicense;'Roles'=$RolesAssigned;'Office'=$Office}
  $Output= New-Object PSObject -Property $Result
  $Output | Select-Object UserPrincipalName,DisplayName,LastLogonTime,CreationTime,InactiveDays,MailboxType,AssignedLicenses,Roles,Office | Export-Csv -Path $ExportCSV -Notype -Append
 }
}

#Open output file after execution
Write-Host `nScript executed successfully
if((Test-Path -Path $ExportCSV) -eq "True")
{
 Write-Host Result contains $OutputCount mailboxes
 Write-Host "Detailed report available in: $ExportCSV"
 $Prompt = New-Object -ComObject wscript.shell
 $UserInput = $Prompt.popup("Do you want to open output file?",`
 0,"Open Output File",4)
 If ($UserInput -eq 6)
 {
  Invoke-Item "$ExportCSV"
 }
}
Else
{
  Write-Host No mailbox found
}
#Clean up session
#Get-PSSession | Remove-PSSession


write-host -foregroundcolor $OutputColor "`nFile $ExportCSV Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------