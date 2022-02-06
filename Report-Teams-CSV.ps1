param(
[string]$UserName, 
[string]$Password, 
[switch]$MFA,
[int]$Action
) 

<#
    .Link
    https://o365reports.com/2020/05/28/microsoft-teams-reporting-using-powershell/

    .Description
    Recently, Microsoft Teams’ usage has been increasing tremendously. This increased the need of generating reports on Microsoft Teams on daily basis. Most admins and executives want to prepare reports on the number of meetings between users, meeting participants, call times, and more. But Microsoft is yet to provide the cmdlets or API to extract those data from Office 365.

    Secondly, managing Teams membership and permission is the next big task. You can manage Teams through the Microsoft Teams admin center. But, getting reports on Channels in the Teams, Teams members, Teams owners, private channel members through the admin center is a bit difficult task. Because you need to navigate to multiple pages to view a single report, and there is no option to export the result. Here, Microsoft Teams PowerShell module comes into play.

    By using Teams PowerShell cmdlets like Get-Team, Get-TeamChannel, Get-TeamUser, and Get-TeamChannelUser, you can get your organization’s Teams information. But how will you get nicely formatted report? Don’t worry! We have created an All-in-One PowerShell script to export Microsoft Teams reports as CSV files. A single script can generate eight different Teams report. 

    

    Script Highlights: 
    - A single script allows you to generate eight different Teams reports.  
    - The script can be executed with MFA enabled accounts too. 
    - Exports output to CSV. 
    - Automatically installs Microsoft Teams PowerShell module (if not installed already) upon your confirmation. 
    - The script is scheduler friendly. I.e., Credential can be passed as a parameter instead of saving inside the script. 

    .Example
    Method 1: Execute script with non-MFA account    
        ./TeamsReports.ps1
    
    Method 2: Execute script using MFA account  
        ./TeamsReports.ps1 -MFA
    
    Method 3: Execute script by explicitly mentioning credential (Scheduler friendly) and required action  
        ./TeamsReports.ps1 -Action 1 -UserName Admin@Contoso.com -Password XXXX

    .Notes

    Export All Microsoft Teams Information: 
        To get a list of all teams in your organization, run the script and select the required action from the menu or run the below code directly
        ./TeamsReports.ps1 -Action 1

    Get All Microsoft Teams’ Members and Owners Report: 
        This report exports all teams’ membership and ownership to the CSV file. To view members and owners report, run the script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 2

    List All Members and Owners in a Specific Team: 
        To export the list of teams’ members, run the script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 3

    Export All Teams and Owners to CSV: 
        To list teams and owners, run the PowerShell script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 4

    Export Teams Owner Report for a Specific Team: 
        To export all owners from the specific team, run the script and select the required action from the menu or run the below code directly.
        ./TeamsReports.ps1 -Action 5

    List all Channels in the Organization – Tenant wide CSV Report: 
        To export all channels in your organization, run the script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 6

    Export the list of Channels in the Specific Team: 
        To retrieve all channels in the specific teams, run the script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 7

    Microsoft Teams’ Channel Members Report: 
        You can generate this report to get a list of channel members and owners. To export channel membership, run the script and select the required action from the menu or run the below code directly. 
        ./TeamsReports.ps1 -Action 8


    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
    Set-Executionpolicy remotesigned

#>


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
#$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MobileDevices-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$OutputCSV = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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

#Accept input paramenters 

        <#
#Connect to Microsoft Teams
    $Module=Get-Module -Name MicrosoftTeams -ListAvailable 
    if($Module.count -eq 0)
        {
        Write-Host MicrosoftTeams module is not available  -ForegroundColor yellow 
        $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No
        if($Confirm -match "[yY]")
        {
        Install-Module MicrosoftTeams
        }
        else
        {
        Write-Host MicrosoftTeams module is required.Please install module using Install-Module MicrosoftTeams cmdlet.
        Exit
        }
        }
    Write-Host Importing Microsoft Teams module... -ForegroundColor Yellow
    #Autentication using MFA
        if($mfa.IsPresent)
        {
        $Team=Connect-MicrosoftTeams
        }


#Authentication using non-MFA
    else
    {
    #Storing credential in script for scheduling purpose/ Passing credential as parameter
    if(($UserName -ne "") -and ($Password -ne ""))
    {
    $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
    $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword
    $Team=Connect-MicrosoftTeams -Credential $Credential
    }
    else
    {  
    $Team=Connect-MicrosoftTeams
    }
    }
    #>


    $Team=Connect-MicrosoftTeams
#Check for Teams connectivity
    If($Team -ne $null)
    {
    Write-host `nSuccessfully connected to Microsoft Teams -ForegroundColor $ProcessMessageColor
    }
    else
    {
    Write-Host Error occurred while creating Teams session. Please try again -ForegroundColor $ErrorMessageColor
    exit
    }

    [boolean]$Delay=$false
    Do {
    if($Action -eq "")
    {
    if($Delay -eq $true)
    {
    Start-Sleep -Seconds 2
    }
    $Delay=$true
    Write-Host ""
    Write-host `nMicrosoft Teams Reporting -ForegroundColor $InfoColor
    Write-Host  "    1.All Teams in organization" -ForegroundColor $SystemMessageColor
    Write-Host  "    2.All Teams members and owners report" -ForegroundColor $SystemMessageColor
    Write-Host  "    3.Specific Teams' members and Owners report" -ForegroundColor $SystemMessageColor
    Write-Host  "    4.All Teams' owners report" -ForegroundColor $SystemMessageColor
    Write-Host  "    5.Specific Teams' owners report" -ForegroundColor $SystemMessageColor
    Write-Host `nTeams Channel Reporting -ForegroundColor $InfoColor
    Write-Host  "    6.All channels in organization" -ForegroundColor $SystemMessageColor
    Write-Host  "    7.All channels in specific Team" -ForegroundColor $SystemMessageColor
    Write-Host  "    8.Members and Owners Report of Single Channel" -ForegroundColor $SystemMessageColor
    Write-Host  "    0.Exit" -ForegroundColor $SystemMessageColor
    Write-Host `nPrivate Channel Management and Reporting -ForegroundColor $InfoColor
    Write-Host  "    You can download the script from https://blog.admindroid.com/managing-private-channels-in-microsoft-teams/" -ForegroundColor $SystemMessageColor
    Write-Host ""
    $i = Read-Host 'Please choose the action to continue' 
    }
    else
    {
    $i=$Action
    }

 Switch ($i) {
  1 {
     $Result=""  
     $Results=@() 
     $Path="$ReportPath\All Teams Report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
     Write-Host Exporting all Teams report...
     $Count=0
     Get-Team | foreach {
     $TeamName=$_.DisplayName
     Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName"
     $Count++
     $Visibility=$_.Visibility
     $MailNickName=$_.MailNickName
     $Description=$_.Description
     $Archived=$_.Archived
     $GroupId=$_.GroupId
     $ChannelCount=(Get-TeamChannel -GroupId $GroupId).count
     $TeamUser=Get-TeamUser -GroupId $GroupId
     $TeamMemberCount=$TeamUser.Count
     $TeamOwnerCount=($TeamUser | ?{$_.role -eq "Owner"}).count
     $Result=@{'Teams Name'=$TeamName;'Team Type'=$Visibility;'Mail Nick Name'=$MailNickName;'Description'=$Description;'Archived Status'=$Archived;'Channel Count'=$ChannelCount;'Team Members Count'=$TeamMemberCount;'Team Owners Count'=$TeamOwnerCount}
     $Results= New-Object psobject -Property $Result
     $Results | select 'Teams Name','Team Type','Mail Nick Name','Description','Archived Status','Channel Count','Team Members Count','Team Owners Count' | Export-Csv $Path -NoTypeInformation -Append
     }
     Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName" -Completed
     if((Test-Path -Path $Path) -eq "True") 
     {
      Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
     }
    }
  2 {
     $Result=""  
     $Results=@() 
     $Path="$ReportPath\All Teams Members and Owner Report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
     Write-Host Exporting all Teams members and owners report...
     $Count=0
     Get-Team | foreach {
      $TeamName=$_.DisplayName
      Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName"
      $Count++
      $GroupId=$_.GroupId
      Get-TeamUser -GroupId $GroupId | foreach {
       $Name=$_.Name
       $MemberMail=$_.User
       $Role=$_.Role
       $Result=@{'Teams Name'=$TeamName;'Member Name'=$Name;'Member Mail'=$MemberMail;'Role'=$Role}
       $Results= New-Object psobject -Property $Result
       $Results | select 'Teams Name','Member Name','Member Mail','Role' | Export-Csv $Path -NoTypeInformation -Append
      }
     }
     Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName" -Completed
     if((Test-Path -Path $Path) -eq "True") 
     {
      Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
     }
    }

  3 {
     $Result=""  
     $Results=@() 
     $TeamName=Read-Host Enter Teams name to get members report "(Case sensitive)":
     $GroupId=(Get-Team -DisplayName $TeamName).GroupId 
     Write-Host Exporting $TeamName"'s" Members and Owners report...
     $Path="$ReportPath\MembersOf $TeamName Team Report _$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
     Get-TeamUser -GroupId $GroupId | foreach {
      $Name=$_.Name
      $MemberMail=$_.User
      $Role=$_.Role
      $Result=@{'Member Name'=$Name;'Member Mail'=$MemberMail;'Role'=$Role}
      $Results= New-Object psobject -Property $Result
      $Results | select 'Member Name','Member Mail','Role' | Export-Csv $Path -NoTypeInformation -Append
     }
     if((Test-Path -Path $Path) -eq "True") 
     {
      Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
     }
    }

  4 {
     $Result=""  
     $Results=@() 
     $Path="$ReportPath\All Teams Owner Report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
     Write-Host Exporting all Teams owner report...
     $Count=0
     Get-Team | foreach {
      $TeamName=$_.DisplayName
      Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName"
      $Count++
      $GroupId=$_.GroupId
      Get-TeamUser -GroupId $GroupId | ?{$_.role -eq "Owner"} | foreach {
       $Name=$_.Name
       $MemberMail=$_.User
       $Result=@{'Teams Name'=$TeamName;'Owner Name'=$Name;'Owner Mail'=$MemberMail}
       $Results= New-Object psobject -Property $Result
       $Results | select 'Teams Name','Owner Name','Owner Mail' | Export-Csv $Path -NoTypeInformation -Append
      }
     }
     Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName" -Completed
     if((Test-Path -Path $Path) -eq "True") 
     {
      Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
     }
    }

  5 {
     $Result=""  
     $Results=@() 
     $TeamName=Read-Host Enter Teams name to get owners report "(Case sensitive)":
     $GroupId=(Get-Team -DisplayName $TeamName).GroupId 
     Write-Host Exporting $TeamName team"'"s Owners report...
     $Path="$ReportPath\OwnersOf $TeamName team report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
     Get-TeamUser -GroupId $GroupId | ?{$_.role -eq "Owner"} | foreach {
      $Name=$_.Name
      $MemberMail=$_.User
      $Result=@{'Member Name'=$Name;'Member Mail'=$MemberMail}
      $Results= New-Object psobject -Property $Result
      $Results | select 'Member Name','Member Mail' | Export-Csv $Path -NoTypeInformation -Append
     }
     if((Test-Path -Path $Path) -eq "True") 
     {
      Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
     }
    }

  6 {
      $Result=""  
      $Results=@() 
      $Path="$ReportPath\All Channels Report_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
      Write-Host Exporting all Channels report...
      $Count=0
      Get-Team | foreach {
       $TeamName=$_.DisplayName
       Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing Team: $TeamName "
       $Count++
       $GroupId=$_.GroupId
       Get-TeamChannel -GroupId $GroupId | foreach {
        $ChannelName=$_.DisplayName
        Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing Team: $TeamName "`n" Currently Processing Channel: $ChannelName"
        $MembershipType=$_.MembershipType
        $Description=$_.Description
        $ChannelUser=Get-TeamChannelUser -GroupId $GroupId -DisplayName $ChannelName
        $ChannelMemberCount=$ChannelUser.Count
        $ChannelOwnerCount=($ChannelUser | ?{$_.role -eq "Owner"}).count
        $Result=@{'Teams Name'=$TeamName;'Channel Name'=$ChannelName;'Membership Type'=$MembershipType;'Description'=$Description;'Total Members Count'=$ChannelMemberCount;'Owners Count'=$ChannelOwnerCount}
        $Results= New-Object psobject -Property $Result
        $Results | select 'Teams Name','Channel Name','Membership Type','Description','Owners Count','Total Members Count' | Export-Csv $Path -NoTypeInformation -Append
       }
      }
      Write-Progress -Activity "`n     Processed Teams count: $Count "`n"  Currently Processing: $TeamName  `n Currently Processing Channel: $ChannelName"  -Completed
      if((Test-Path -Path $Path) -eq "True") 
      {
       Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
      }
     }  

   7 {
      $TeamName=Read-Host Enter Teams name "(Case Sensitive)"
      Write-Host Exporting Channels report...
      $Count=0
      $GroupId=(Get-Team -DisplayName $TeamName).GroupId
      $Path="$ReportPath\Channels available in $TeamName team $((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
      Get-TeamChannel -GroupId $GroupId | Foreach {
       $ChannelName=$_.DisplayName
       Write-Progress -Activity "`n     Processed channel count: $Count "`n"  Currently Processing Channel: $ChannelName"
       $Count++
       $MembershipType=$_.MembershipType
       $Description=$_.Description
       $ChannelUser=Get-TeamChannelUser -GroupId $GroupId -DisplayName $ChannelName
       $ChannelMemberCount=$ChannelUser.Count
       $ChannelOwnerCount=($ChannelUser | ?{$_.role -eq "Owner"}).count
       $Result=@{'Teams Name'=$TeamName;'Channel Name'=$ChannelName;'Membership Type'=$MembershipType;'Description'=$Description;'Total Members Count'=$ChannelMemberCount;'Owners Count'=$ChannelOwnerCount}
       $Results= New-Object psobject -Property $Result
       $Results | select 'Teams Name','Channel Name','Membership Type','Description','Owners Count','Total Members Count' | Export-Csv $Path -NoTypeInformation -Append
      }
      Write-Progress -Activity "`n     Processed channel count: $Count "`n"  Currently Processing Channel: $ChannelName" -Completed
      if((Test-Path -Path $Path) -eq "True") 
      {
       Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
      }
     }  
    
   8 {
      $Result=""  
      $Results=@() 
      $TeamName=Read-Host Enter Teams name in which Channel resides "(Case sensitive)"
      $ChannelName=Read-Host Enter Channel name
      $GroupId=(Get-Team -DisplayName $TeamName).GroupId 
      Write-Host Exporting $ChannelName"'s" Members and Owners report...
      $Path="$ReportPath\MembersOf $ChannelName channel report $((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
      Get-TeamChannelUser -GroupId $GroupId -DisplayName $ChannelName | foreach {
       $Name=$_.Name
       $UPN=$_.User
       $Role=$_.Role
       $Result=@{'Teams Name'=$TeamName;'Channel Name'=$ChannelName;'Member Mail'=$UPN;'Member Name'=$Name;'Role'=$Role}
       $Results= New-Object psobject -Property $Result
       $Results | select 'Teams Name','Channel Name','Member Name','Member Mail',Role | Export-Csv $Path -NoTypeInformation -Append
      }   
      if((Test-Path -Path $Path) -eq "True") 
      {
       Write-Host `nReport available in $Path -ForegroundColor $ProcessMessageColor
      }
     }

   }
   if($Action -ne "")
   {exit}
}
  While ($i -ne 0)

write-host -foregroundcolor $OutputColor "`nFile $OutputCSV Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------