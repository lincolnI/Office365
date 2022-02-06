<# 
    .Description
    Export Office 365 Users MFA Status to CSV using PowerShell

    This PowerShell script exports Office 365 users' MFA status along with many useful attributes like Display Name, User Principal Name, MFA Status, Activation Status, Default MFA Method, All MFA Methods, MFA Phone, MFA Email, License Status, IsAdmin, Admin Roles, SignIn Status.

    The Script will return MFA enabled and enforced users by default. If you want to list MFA disabled users, you need to use -DisabledOnly param. Also you can filter the result based on Status, Admin users, Licensed users, Sign-in allowed/denied users.

    The exported report will look similar to below screenshot.

    MFA enabled users report (for Enabled/Enforced users): 


    MFA disabled users Report: 

    For detailed execution steps, available filters,  please refer the blog: 
    https://o365reports.com/2019/05/09/export-office-365-users-mfa-status-csv/
    

    Script Highlights: 
        The result can be filtered based on MFA status.i.e., you can filter MFA enabled users/enforced users/disabled users alone .
        Result can be filtered based on Admin users.
        You can filter result to display Licensed users alone.
        You can filter result based on SignIn Status (SignIn allowed/denied).
        Exports result to CSVfile. 
        The script produces different output files based on MFA status.For MFA enabled and enforced users, ‘MFA Enabled User Report’ will be generated. For MFA disabled users, ‘MFA Disabled User Report’ will be generated. 
        MFA enabled user report has the following attributes: Display Name, User Principal Name, MFA Status, Activation Status, Default MFA Method, All MFA Methods, MFA Phone, MFA Email, License Status, IsAdmin, Admin Roles, SignIn Status. 
        MFA disabled user report has the following attributes: Display Name, User Principal Name, Department, MFA Status, License Status, Is Admin, Admin Roles, SignIn Status. 
        The script can be executed with MFA enabled account. 
        You can use this script to get users' MFA status set by Conditional Access.
        The script is scheduler friendly. i.e., credentials can be passed as parameter instead of saving inside the script. 
    If you need more enhancements to the script then please drop us a comment.
    
    .Link
    https://gallery.technet.microsoft.com/office365/Export-Office-365-Users-81747c73
    
    .Prerequisites = 1
    1. Ensure connection to Exchange Online has already been completed

    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
    Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force

#>

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"
$ErrorMessageColor = "Red"
$WarnMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MFADisabledUserReport-" + $ClientName)
$ReportName2 = ( "$Date" + "-" + "MFAEnabledUserReport-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
#$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#Output file declaration
$ExportCSV = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv" 
$ExportCSVReport = Join-Path -Path $ReportPath -ChildPath "$ReportName2.csv" 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Param
(
    [Parameter(Mandatory = $false)]
    [switch]$DisabledOnly,
    [switch]$EnabledOnly,
    [switch]$EnforcedOnly,
    [switch]$ConditionalAccessOnly,
    [switch]$AdminOnly,
    [switch]$LicensedUserOnly,
    [Nullable[boolean]]$SignInAllowed = $null,
    [string]$UserName,
    [string]$Password
)

#----------------------------------------------------------------



#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}


    #Check for MSOnline module
    $Modules=Get-Module -Name MSOnline -ListAvailable
    if($Modules.count -eq 0)
    {
    Write-Host  Please install MSOnline module using below command: `nInstall-Module MSOnline  -ForegroundColor yellow
    Exit
    }

    #Storing credential in script for scheduling purpose/ Passing credential as parameter
    if(($UserName -ne "") -and ($Password -ne ""))
    {
    $SecuredPassword = ConvertTo-SecureString -AsPlainText $Password -Force
    $Credential  = New-Object System.Management.Automation.PSCredential $UserName,$SecuredPassword
    Connect-MsolService -Credential $credential
    }
    else
    {
    Connect-MsolService | Out-Null
    }
    $Result=""
    $Results=@()
    $UserCount=0
    $PrintedUser=0

    #Loop through each user
    Get-MsolUser -All | foreach{
    $UserCount++
    $DisplayName=$_.DisplayName
    $Upn=$_.UserPrincipalName
    $MFAStatus=$_.StrongAuthenticationRequirements.State
    $MethodTypes=$_.StrongAuthenticationMethods
    $RolesAssigned=""
    Write-Progress -Activity "`n     Processed user count: $UserCount "`n"  Currently Processing: $DisplayName"
    if($_.BlockCredential -eq "True")
    {
    $SignInStatus="False"
    $SignInStat="Denied"
    }
    else
    {
    $SignInStatus="True"
    $SignInStat="Allowed"
    }

    #Filter result based on SignIn status
    if(($SignInAllowed -ne $null) -and ([string]$SignInAllowed -ne [string]$SignInStatus))
    {
    return
    }

    #Filter result based on License status
    if(($LicensedUserOnly.IsPresent) -and ($_.IsLicensed -eq $False))
    {
    return
    }

    if($_.IsLicensed -eq $true)
    {
    $LicenseStat="Licensed"
    }
    else
    {
    $LicenseStat="Unlicensed"
    }

    #Check for user's Admin role
    $Roles=(Get-MsolUserRole -UserPrincipalName $upn).Name
    if($Roles.count -eq 0)
    {
    $RolesAssigned="No roles"
    $IsAdmin="False"
    }
    else
    {
    $IsAdmin="True"
    foreach($Role in $Roles)
    {
    $RolesAssigned=$RolesAssigned+$Role
    if($Roles.indexof($role) -lt (($Roles.count)-1))
    {
        $RolesAssigned=$RolesAssigned+","
    }
    }
    }

    #Filter result based on Admin users
    if(($AdminOnly.IsPresent) -and ([string]$IsAdmin -eq "False"))
    {
    return
    }

    #Check for MFA enabled user
    if(($MethodTypes -ne $Null) -or ($MFAStatus -ne $Null) -and (-Not ($DisabledOnly.IsPresent) ))
    {
    #Check for Conditional Access
    if($MFAStatus -eq $null)
    {
    $MFAStatus='Enabled via Conditional Access'
    }

    #Filter result based on EnforcedOnly filter
    if((([string]$MFAStatus -eq "Enabled") -or ([string]$MFAStatus -eq "Enabled via Conditional Access")) -and ($EnforcedOnly.IsPresent))
    {
    return
    }

    #Filter result based on EnabledOnly filter
    if(([string]$MFAStatus -eq "Enforced") -and ($EnabledOnly.IsPresent))
    {
    return
    }

    #Filter result based on MFA enabled via Other source
    if((($MFAStatus -eq "Enabled") -or ($MFAStatus -eq "Enforced")) -and ($ConditionalAccessOnly.IsPresent))
    {
    return
    }

    $Methods=""
    $MethodTypes=""
    $MethodTypes=$_.StrongAuthenticationMethods.MethodType
    $DefaultMFAMethod=($_.StrongAuthenticationMethods | where{$_.IsDefault -eq "True"}).MethodType
    $MFAPhone=$_.StrongAuthenticationUserDetails.PhoneNumber
    $MFAEmail=$_.StrongAuthenticationUserDetails.Email

    if($MFAPhone -eq $Null)
    { $MFAPhone="-"}
    if($MFAEmail -eq $Null)
    { $MFAEmail="-"}

    if($MethodTypes -ne $Null)
    {
    $ActivationStatus="Yes"
    foreach($MethodType in $MethodTypes)
    {
        if($Methods -ne "")
        {
        $Methods=$Methods+","
        }
        $Methods=$Methods+$MethodType
    }
    }

    else
    {
    $ActivationStatus="No"
    $Methods="-"
    $DefaultMFAMethod="-"
    $MFAPhone="-"
    $MFAEmail="-"
    }

    #Print to output file
    $PrintedUser++
    $Result=@{'DisplayName'=$DisplayName;'UserPrincipalName'=$upn;'MFAStatus'=$MFAStatus;'ActivationStatus'=$ActivationStatus;'DefaultMFAMethod'=$DefaultMFAMethod;'AllMFAMethods'=$Methods;'MFAPhone'=$MFAPhone;'MFAEmail'=$MFAEmail;'LicenseStatus'=$LicenseStat;'IsAdmin'=$IsAdmin;'AdminRoles'=$RolesAssigned;'SignInStatus'=$SigninStat}
    $Results= New-Object PSObject -Property $Result
    $Results | Select-Object DisplayName,UserPrincipalName,MFAStatus,ActivationStatus,DefaultMFAMethod,AllMFAMethods,MFAPhone,MFAEmail,LicenseStatus,IsAdmin,AdminRoles,SignInStatus | Export-Csv -Path $ExportCSVReport -Notype -Append
    }

    #Check for MFA disabled user
    elseif(($DisabledOnly.IsPresent) -and ($MFAStatus -eq $Null) -and ($_.StrongAuthenticationMethods.MethodType -eq $Null))
    {
    $MFAStatus="Disabled"
    $Department=$_.Department
    if($Department -eq $Null)
    { $Department="-"}
    $PrintedUser++
    $Result=@{'DisplayName'=$DisplayName;'UserPrincipalName'=$upn;'Department'=$Department;'MFAStatus'=$MFAStatus;'LicenseStatus'=$LicenseStat;'IsAdmin'=$IsAdmin;'AdminRoles'=$RolesAssigned; 'SignInStatus'=$SigninStat}
    $Results= New-Object PSObject -Property $Result
    $Results | Select-Object DisplayName,UserPrincipalName,Department,MFAStatus,LicenseStatus,IsAdmin,AdminRoles,SignInStatus | Export-Csv -Path $ExportCSV -Notype -Append
    }
    }

    #Open output file after execution
    Write-Host `nScript executed successfully
    if((Test-Path -Path $ExportCSV) -eq "True")
    {
    Write-Host "MFA Disabled user report available in: $ExportCSV"
    $Prompt = New-Object -ComObject wscript.shell
    $UserInput = $Prompt.popup("Do you want to open output file?",`
    0,"Open Output File",4)
    If ($UserInput -eq 6)
    {
    Invoke-Item "$ExportCSV"
    }
    Write-Host Exported report has $PrintedUser users
    }
    elseif((Test-Path -Path $ExportCSVReport) -eq "True")
    {
    Write-Host "MFA Enabled user report available in: $ExportCSVReport"
    $Prompt = New-Object -ComObject wscript.shell
    $UserInput = $Prompt.popup("Do you want to open output file?",`
    0,"Open Output File",4)
    If ($UserInput -eq 6)
    {
    Invoke-Item "$ExportCSVReport"
    }
    Write-Host Exported report has $PrintedUser users
    }
    Else
    {
    Write-Host No user found that matches your criteria.
    }

Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------