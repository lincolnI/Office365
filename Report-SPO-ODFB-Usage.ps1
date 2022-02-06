<#
    .Link
    Source - https://github.com/directorcia/Office365/blob/master/o365-spo-getusage.ps1
    https://blog.ciaops.com/2019/07/31/use-powershell-to-get-site-storage-usage/

    .Description
    Show SharePoint and ODFB site storage usage from largest to smallest

    .Notes
    Prerequisites = 2
        1. Ensure SharePoint online PowerShell module installed or updated
    
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
$systemmessagecolor = "cyan"
$processmessagecolor = "green"
$highlightmessagecolor = "yellow"
$sectionmessagecolor = "white"

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

$sposites=get-sposite -IncludePersonalSite $false -limit all | Sort-Object StorageUsageCurrent -Descending          ## get all non-ODFB sites
Write-host -foregroundcolor $sectionmessagecolor "*** Current SharePoint Site Usage ***`n"
foreach ($sposite in $sposites) {                           ## loop through all of these sites
    $mbsize=$sposite.StorageUsageCurrent                    ## save total size to a variable to be formatted later
    write-host -foregroundcolor $highlightmessagecolor $sposite.title,"=",$mbsize.tostring('N0'),"MB"
    write-host -foregroundcolor $processmessagecolor $sposite.url
    write-host
}

$sposites=get-sposite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/" | Sort-Object StorageUsageCurrent -Descending
Write-host -foregroundcolor $sectionmessagecolor "*** Current ODFB Site Usage ***`n"
foreach ($sposite in $sposites) {
    $mbsize=$sposite.StorageUsageCurrent
    write-host -foregroundcolor $highlightmessagecolor $sposite.title,"=",$mbsize.tostring('N0'),"MB"
    write-host -foregroundcolor $processmessagecolor $sposite.url
    write-host
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------