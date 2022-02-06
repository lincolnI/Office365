<#
    .Link

    .Description
    Export Calendars and Sub Calendars for all users
 
    .Notes
    Prerequisites = 1
        1. Ensure connection to Exchange Online has already been completed
    
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
$UserName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "UserCalendars-" + $UserName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$Reportfile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}


$mailboxes = Get-Mailbox -ResultSize Unlimited

foreach ($mailbox in $mailboxes)
{
Get-MailboxFolderStatistics $mailbox.alias -FolderScope calendar | select Identity, Name, folderpath, foldertype | Export-Csv $Reportfile -append
}

write-host -foregroundcolor $OutputColor "`nFile $outputfile Created"
Invoke-Item $ReportPath
Invoke-Item $Reportfile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------