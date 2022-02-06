<#
    .Link
	Info: https://o365reports.com/2020/01/03/shared-mailbox-permission-report-to-csv/
	Script: https://gallery.technet.microsoft.com/Export-Shared-Mailbox-a3e98676

	.Description
	This PowerShell script exports Shared Mailbox permissions like Full Access, Send As and Send On Behalf permissions to CSV. 
	Along with these permissions, the exported report contains Display Name, User Principal Name, Primary SMTP Address, Email Aliases, and Delegated Users.


    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
        Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
        Set-Executionpolicy remotesigned
        Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force

    Disconnect PowerShell Sessions:
    - Get-PSSession | Remove-PSSession

#>

param( 
[switch]$FullAccess, 
[switch]$SendAs, 
[switch]$SendOnBehalf,
[string]$MBNamesFile, 
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
$OutputColor = "Green"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "ShareMailboxPerm-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ExportCSV = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Accept input paramenters 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Result=""  
$Results=@() 
$SharedMBCount=0 
$RolesAssigned="" 


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Accept input paramenters/Functions
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Print_Output 
{  
 #Print Output 
 if($Print -eq 1) 
 { 
  $Result = @{'Display Name'=$_.Displayname;'User PrinciPal Name'=$upn;'Primary SMTP Address'=$PrimarySMTPAddress;'Access Type'=$AccessType;'User With Access'=$userwithAccess;'Email Aliases'=$EmailAlias}  
  $Results = New-Object PSObject -Property $Result  
  $Results |select-object 'Display Name','User PrinciPal Name','Primary SMTP Address','Access Type','User With Access','Email Aliases' | Export-Csv -Path $ExportCSV -Notype -Append  
 } 
} 
 
#Getting Mailbox permission 
function Get_MBPermission 
{ 
 $upn=$_.UserPrincipalName
 $DisplayName=$_.Displayname 
 $MBType=$_.RecipientTypeDetails 
 $PrimarySMTPAddress=$_.PrimarySMTPAddress
 $EmailAddresses=$_.EmailAddresses
 $EmailAlias=""
 foreach($EmailAddress in $EmailAddresses)
 {
  if($EmailAddress -clike "smtp:*")
  {
   if($EmailAlias -ne "")
   {
    $EmailAlias=$EmailAlias+","
   }
   $EmailAlias=$EmailAlias+($EmailAddress -Split ":" | Select-Object -Last 1 )
  }
 }
 $Print=0 
 Write-Progress -Activity "`n     Processed mailbox count: $SharedMBCount "`n"  Currently Processing: $DisplayName" 

 #Getting delegated Fullaccess permission for mailbox 
 if(($FilterPresent -ne $true) -or ($FullAccess.IsPresent)) 
 { 
  $FullAccessPermissions=(Get-MailboxPermission -Identity $upn | where { ($_.AccessRights -contains "FullAccess") -and ($_.IsInherited -eq $false) -and -not ($_.User -match "NT AUTHORITY" -or $_.User -match "S-1-5-21") }).User 
  if([string]$FullAccessPermissions -ne "") 
  { 
   $Print=1 
   $UserWithAccess="" 
   $AccessType="FullAccess" 
   foreach($FullAccessPermission in $FullAccessPermissions) 
   { 
    if($UserWithAccess -ne "")
    {
     $UserWithAccess=$UserWithAccess+","
    }
    $UserWithAccess=$UserWithAccess+$FullAccessPermission 
   } 
   Print_Output 
  } 
 } 
 
 #Getting delegated SendAs permission for mailbox 
 if(($FilterPresent -ne $true) -or ($SendAs.IsPresent)) 
 { 
  $SendAsPermissions=(Get-RecipientPermission -Identity $upn | where{ -not (($_.Trustee -match "NT AUTHORITY") -or ($_.Trustee -match "S-1-5-21"))}).Trustee 
  if([string]$SendAsPermissions -ne "") 
  { 
   $Print=1 
   $UserWithAccess="" 
   $AccessType="SendAs" 
   foreach($SendAsPermission in $SendAsPermissions) 
   { 
    if($UserWithAccess -ne "")
    {
     $UserWithAccess=$UserWithAccess+","
    }
    $UserWithAccess=$UserWithAccess+$SendAsPermission 
   } 
   Print_Output 
  } 
 } 
 
 #Getting delegated SendOnBehalf permission for mailbox 
 if(($FilterPresent -ne $true) -or ($SendOnBehalf.IsPresent)) 
 { 
  $SendOnBehalfPermissions=$_.GrantSendOnBehalfTo 
  if([string]$SendOnBehalfPermissions -ne "") 
  { 
   $Print=1 
   $UserWithAccess="" 
   $AccessType="SendOnBehalf" 
   foreach($SendOnBehalfPermissionDN in $SendOnBehalfPermissions) 
   { 
    if($UserWithAccess -ne "")
    {
     $UserWithAccess=$UserWithAccess+","
    }
    #$SendOnBehalfPermission=(Get-Mailbox -Identity $SendOnBehalfPermissionDN).UserPrincipalName
    $UserWithAccess=$UserWithAccess+$SendOnBehalfPermissionDN 
   } 
   Print_Output 
  } 
 } 
} 


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host
Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
	New-Item -ItemType Directory -Path $ReportPath
	write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
  }

#Check for AccessType filter 
if(($FullAccess.IsPresent) -or ($SendAs.IsPresent) -or ($SendOnBehalf.IsPresent))
{
 $FilterPresent=$true
} 

#Check for input file 
if ($MBNamesFile -ne "")  
{  
 #We have an input file, read it into memory  
 $MBs=@() 
 $MBs=Import-Csv -Header "DisplayName" $MBNamesFile 
 foreach($item in $MBs) 
 { 
  Get-Mailbox -Identity $item.displayname | Foreach{ 
  if($_.RecipientTypeDetails -ne 'SharedMailbox')
  {
	Write-Host $_.UserPrincipalName is not a shared mailbox -ForegroundColor Red
	continue
  }
  $SharedMBCount++ 
  Get_MBPermission 
  } 
 } 
} 
#Getting all User mailbox 
else 
{ 
 Get-mailbox -RecipientTypeDetails Shared -ResultSize Unlimited | foreach{ 
  $SharedMBCount++ 
  Get_MBPermission} 
} 


Write-Host -foregroundcolor $OutputColor "`nFile $ExportCSV Created"
Invoke-Item $ReportPath
Invoke-Item $ExportCSV

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------