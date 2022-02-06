<#
=============================================================================================
Name:           Export Office 365 user last logon time report
Description:    This script exports Office 365 users' last logon time CSV
Version:        3.0
website:        o365reports.com
Script by:      O365Reports Team
For detailed Script execution: https://o365reports.com/2019/03/07/export-office-365-users-last-logon-time-csv/
Modified:       Lincoln Isenbert 18/03/2021
Reason:         Ease of use with RT Powershell launcher
============================================================================================
#>
#Check for MSOnline module 
$Module=Get-Module -Name MSOnline -ListAvailable  
if($Module.count -eq 0) 
    { 
        Write-Host MSOnline module is not available  -ForegroundColor yellow  
        $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No 
    if($Confirm -match "[yY]") 
    { 
        Install-Module MSOnline 
        Import-Module MSOnline
    } 
    else 
    { 
        Write-Host MSOnline module is required to connect AzureAD.Please install module using Install-Module MSOnline cmdlet. 
        Exit
    }
} 

#Get friendly name of license plan from external file
$FriendlyNameHash=Get-Content -Raw -Path .\LicenseFriendlyName.txt -ErrorAction SilentlyContinue | ConvertFrom-StringData


#Set output file

$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "LicencedUsers-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ExportCSV = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file
#$ExportCSV=".\M365-LicensedUsers-Report_$((Get-Date -format yy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"

#Check for EXO v2 module inatallation
$Module = Get-Module ExchangeOnlineManagement -ListAvailable
if($Module.count -eq 0) 
{ 
    Write-Host Exchange Online PowerShell V2 module is not available  -ForegroundColor yellow  
    $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No 
    if($Confirm -match "[yY]") 
    { 
        Write-host "Installing Exchange Online PowerShell module"
        Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
    } 
    else 
    { 
        Write-Host EXO V2 module is required to connect Exchange Online.Please install module using Install-Module ExchangeOnlineManagement cmdlet. 
        Exit
    }
} 
 
$Result=""
$Output=@()
$MBUserCount=0
$OutputCount=0

Get-Mailbox -ResultSize Unlimited | Where{$_.DisplayName -notlike "Discovery Search Mailbox"} | ForEach-Object{
    $upn=$_.UserPrincipalName
    $LastLogonTime=(Get-MailboxStatistics -Identity $upn).lastlogontime
    $DisplayName=$_.DisplayName
    $MBType=$_.RecipientTypeDetails
    $Print=1
    $MBUserCount++
    Write-Progress -Activity "`n     Processed mailbox count: $MBUserCount "`n"  Currently Processing: $DisplayName"

    #Retrieve lastlogon time and then calculate Inactive days
    if($LastLogonTime -eq $null)
    {
        $LastLogonTime ="Never Logged In"
    }

    #Get licenses assigned to mailboxes
    $User=(Get-MsolUser -UserPrincipalName $upn)
    $Licenses=$User.Licenses.AccountSkuId
    $AssignedLicense=""
    $Count=0
    #Convert license plan to friendly name
    foreach($License in $Licenses)
    {
        $LicenseItem= $License -Split ":" | Select-Object -Last 1
        $Count++
        if ($LicenseItem -notlike "*TEAMS*")
        {
            $EasyName=$FriendlyNameHash[$LicenseItem]
            if(!($EasyName))
                {$NamePrint=$LicenseItem}
            else
                {$NamePrint=$EasyName}
            $AssignedLicense=$AssignedLicense+$NamePrint
            if($count -lt $licenses.count)
            {
                $AssignedLicense=$AssignedLicense+"+"
            }
        }
        if($Count -eq ($licenses).count) 
        {
            if ($AssignedLicense -match '\+$')
            {
                $AssignedLicense = $AssignedLicense.Substring(0,($AssignedLicense.Length-1))
            }
        }
    }
    if($Licenses.count -eq 0 -or $AssignedLicense.Equals(""))
    {
        $Print=0
    }

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

    #Export result to CSV file
    if($Print -eq 1)
    {
        $OutputCount++
        $Result=@{'DisplayName'=$DisplayName;'AssignedLicenses'=$AssignedLicense;'UserPrincipalName'=$upn;'LastLogonTime'=$LastLogonTime}
        $Output= New-Object PSObject -Property $Result
        $Output | Select-Object DisplayName,AssignedLicenses,UserPrincipalName,LastLogonTime | Export-Csv -Path $ExportCSV -Notype -Append
    }
}

#Open output file after execution
Write-Host `nScript executed successfully
if((Test-Path -Path $ExportCSV) -eq "True")
{
    Write-Host "Detailed report available in: $ExportCSV"
    Write-Host Exported report has $OutputCount mailboxes
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
# Clean up session
# Get-PSSession | Remove-PSSession