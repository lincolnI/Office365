<# 
    .Description
    Script designed to export both the summary and detail of an email message trace
    
    .Source
    https://github.com/directorcia/patron/blob/master/o365-msgtrace-csv.ps1
    
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
$LocalHost = $env:COMPUTERNAME
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MessageTrace-" + $ClientName)
$ReportName1 = ( "$Date" + "-" + "MessageTrace-Detailed-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFileSummary = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file
$ResultsFileDetail = Join-Path -Path $ReportPath -ChildPath "$ReportName1.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variable
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Hours = 48     ## Number of prior hours to check 

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

$DateEnd = get-date                         ## get current time
$DateStart = $dateEnd.AddHours(-$hours)     ## get current time less last $hours
$Results = Get-MessageTrace -StartDate $dateStart -EndDate $dateEnd | Select-Object Received, SenderAddress, RecipientAddress, Subject, Status, ToIP, FromIP, Size, MessageID, MessageTraceID
write-host -foregroundcolor $processmessagecolor "Start - Writing summary trace information to",$ResultsFileSummary
$Results | Export-Csv -path $ResultsFileSummary -NoTypeInformation
write-host -foregroundcolor $processmessagecolor "Finish - Writing summary trace information to",$ResultsFileSummary
write-host -foregroundcolor $processmessagecolor "Start - Writing detailed trace information to",$ResultsFileDetail
$Results | get-messagetracedetail | Export-Csv -path $ResultsFileDetail -NoTypeInformation
write-host -foregroundcolor $processmessagecolor "Finish - Writing detailed trace information to",$ResultsFileDetail
write-host -foregroundcolor $processmessagecolor "Output summary results to screen"
$Results | out-gridview

write-host -foregroundcolor $ProcessMessageColor "`nFile $ResultsFileSummary & $ResultsFileDetail Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------