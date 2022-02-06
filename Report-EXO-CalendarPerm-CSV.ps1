<#
    .Link
    http://o365info.com/folder-permission-powershell-commands/

    .Description
    Export Calendar permissions for a user
  
    .Notes
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
$UserName = Read-Host -Prompt "Enter the username/email of the mailbox"
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "CalPerm-" + $UserName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MailboxCheck = Get-MailboxFolderPermission ("$UserName" + ":\calendar")

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


write-host -foregroundcolor $InfoColor " Calendar Permissions for $UserName "
$MailboxCheck

$MailboxCheck | export-csv $ResultsFile -notypeinformation -append  


write-host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------