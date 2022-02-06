<#
    .Link

    .Description
    Set SP Recpmmended settings
 
    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
        Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
        Set-Executionpolicy remotesigned
        Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force

    Disconnect PowerShell Sessions:
    - Get-PSSession | Remove-PSSession

#>

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Connect 365
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Set-Location $ScriptRepo

$ConnectSPO = Read-Host "`nWould you like to Connect to SharePoint Online (Y\N)?"

If ($ConnectSPO -eq "Y") {
   
    ## Remove existing sessions
    Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

    Write-host -ForegroundColor $SystemMessageColor "`nStart - Connecting to MS Online"
    
    ## Start MSOnline session
    write-host -foregroundcolor $processmessagecolor "`nStart - MS login"
    Import-Module MSOnline
    Import-Module MsolService
    Connect-MsolService
    write-host -foregroundcolor $processmessagecolor "Finish - MS login`n`n"   

    ## Connect to SharePoint Online Service

    Write-host -ForegroundColor $SystemMessageColor "`nStart - Connecting to SharePoint Online"
       
    Write-host -foregroundcolor $processmessagecolor "`nStart - SharePoint Online login"
    Import-Module microsoft.online.sharepoint.powershell -disablenamechecking
    
    $InitialDomain = Get-MsolDomain | Where-Object {$_.IsInitial -eq $true}
    $tenanturl = "https://$($InitialDomain.Name.Split(".")[0])-admin.sharepoint.com"
    connect-sposervice -url $tenanturl
    write-host -foregroundcolor $processmessagecolor "Finish - SharePoint Online login`n`n"  
}

Else {
Write-host -ForegroundColor $processmessagecolor "Continuing with current SharePoint Online Session"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$FiveTB = 5242880

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

#----------------------------------------------------------------
################# SharePoint ################
#----------------------------------------------------------------

#----------------------------------------------------------------
#### OneDrive 5TB ####
## this will set new users ODFB = 5TB when provisioned
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Setting OneDrive Limit to 5TB"
set-spotenant -OneDriveStorageQuota $FiveTB
write-host -foregroundcolor $SystemMessageColor "`nFinish - Setting OneDrive Limit to 5TB"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Prevent download of infected files from SharePoint Online ####
write-host -foregroundcolor $SystemMessageColor "`n`nStart - Preventing download of infected files from SharePoint Online"
set-spotenant -disallowinfectedfiledownload $true
write-host -foregroundcolor $SystemMessageColor "`nFinish - Preventing download of infected files from SharePoint Online"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Prevent Prevent External users from resharing ####
Write-host -ForegroundColor $SystemMessageColor "`n`nStart - Prevent Extenernal users from resharing"
set-spotenant -PreventExternalUsersFromResharing $true
Write-host -ForegroundColor $SystemMessageColor "`nFinish - Prevent External users from resharing"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### enable # and % in Sharepoint Online and OneDrive for Business ####
Write-host -ForegroundColor $SystemMessageColor "`n`nStart - Enable SharePoint/ODFB special characters"
Set-spotenant -SpecialCharactersStateInFileFolderNames allowed
Write-host -ForegroundColor $SystemMessageColor "`nFinish - Enable SharePoint/ODFB special characters"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Exclude Files Types ####
Write-host -ForegroundColor $SystemMessageColor "`n`nStart - Exclude MYOB Files"
Set-SPOTenantSyncClientRestriction  -ExcludedFileExtensions "myox;myo;pst;ost"
Write-host -ForegroundColor $SystemMessageColor "`nFinish - Exclude MYOB Files"
#----------------------------------------------------------------

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------