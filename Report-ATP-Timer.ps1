
<#
    .Link
    Source - https://github.com/directorcia/Office365/blob/master/o365-atp-timer.ps1
    original concept and code taken from - https://blog.kloud.com.au/2018/07/19/measure-o365-atp-safe-attachments-latency-using-powershell/

    .Description
    Check and report the time taken by Office 365 ATP to process a message
 
    .Notes
    Prerequisites = 4
        1. Recipient must have ATP license assigned and ATP must be configured for tenant
        2. Connected to Exchange Online
        3. Send two emails to recipient, first WITHOUT attachment, second WITH attachment
        4. Wait until both messages are fully delivered to Inbox


    If you have running scripts that don't have a certificate, run this command once to disable that level of security
        Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
        Set-Executionpolicy remotesigned
        Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force

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
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Hours = Read-Host -Prompt "`nHour window to check for sent messages"
$hourwindow = $Hours    ## hours window to check for sent messages. As messages age you may need to adjust this

#----------------------------------------------------------------



#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------

#Clear-host

write-host -foregroundcolor $systemmessagecolor "`nScript started`n"

$RecipientAddress = read-host -prompt 'Input recipient email address'

$Messages = Get-MessageTrace -RecipientAddress $RecipientAddress -StartDate (Get-Date).AddHours(-$hourwindow) -EndDate (get-date)
$custom_object = @() ## initialise object
foreach($Message in $Messages)
{
    $Message_RecipientAddress = $Message.RecipientAddress
    $Message_Detail = $Message | Get-MessageTraceDetail | Where-Object -FilterScript {$PSItem.'Event' -eq "Advanced Threat Protection"} 
    if($Message_Detail)
    {
        $Message_Detail = $Message_Detail | Select-Object -Property MessageTraceId -Unique
        $Custom_Object += New-Object -TypeName psobject -Property ([ordered]@{'RecipientAddress'=$Message_RecipientAddress;'MessageTraceId'=$Message_Detail.'MessageTraceId'})
    } #End If Message_Detail Variable 
    Remove-Variable -Name MessageDetail,Message_RecipientAddress -ErrorAction SilentlyContinue
} #End For Each Message 

$final_data = @() ## initialise object
foreach($MessageTrace in $Custom_Object)
{
    $Message = $MessageTrace | Get-MessageTraceDetail | sort-object Date
    $Message_TimeDiff = ($Message | select-object -Last 1 | select-object Date).Date - ($Message | select-object -First 1 | select-object Date).Date
    $Final_Data += New-Object -TypeName psobject -Property ([ordered]@{'RecipientAddress'=$MessageTrace.'RecipientAddress';'MessageTraceId'=$MessageTrace.'MessageTraceId';'TotalMinutes'="{0:N3}" -f [decimal]$Message_TimeDiff.'TotalMinutes';'TotalSeconds'="{0:N2}" -f [decimal]$Message_TimeDiff.'TotalSeconds'})
    Remove-Variable -Name Message,Message_TimeDiff -ErrorAction SilentlyContinue
} # End For each Message Trace in the custom object

Write-host
Write-host -foregroundcolor $ProcessMessageColor "Total additional time for ATP scanning (Newest to Oldest) =",$final_data.totalseconds,"seconds"
Write-host

write-host -foregroundcolor $systemmessagecolor "Script Completed`n"

#----------------------------------------------------------------