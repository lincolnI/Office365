<#
    .Link
    https://softcomet.freshdesk.com/support/solutions/articles/6000223639-manage-forward-mail-by-using-powershell

    .Description
    Display information about Specific Mailbox Forwarding settings
 
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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Tenant = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "AllExchangeForwardRules-" + $Tenant)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ReportFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Connect 365
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ConnectEXO = Read-Host "`nWould you like to Connect to Exchange Online (Y\N)?"

If ($ConnectEXO -eq "Y") {
   
    ## Remove existing sessions
    Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

    Write-host -ForegroundColor $SystemMessageColor "`nStart - Connecting to Exchange Online"
    
    ## Start Exchange Online session
    write-host -foregroundcolor $processmessagecolor "`nStart - Exchange login"
    #Import-Module ExchangeOnline
    Connect-ExchangeOnline
    write-host -foregroundcolor $processmessagecolor "Finish - Exchange login`n`n"   
}

Else {
Write-host -ForegroundColor $processmessagecolor "Continuing with current Exchange Online Session"
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Domains = Get-AcceptedDomain
$MailBoxes = Get-Mailbox -ResultSize Unlimited
#Find all Recipients (Display list) with ADMIN Forwarding or USER Forwarding
$ForwardingAll = Get-Mailbox -ResultSize Unlimited | Where {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward 
$found=$false
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#----------------------------------------------------------------



#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

$MailBoxes | Where {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward | Export-Csv $Reportfile -NoTypeInformation

write-host -foregroundcolor $OutputColor "`nFile $Reportfile Created"
Invoke-Item $ReportPath
Invoke-Item $Reportfile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------


<#
#counter 
$i = 0 
 
#Array for saving Report Data 
$Forwardings=@() 
 
#Loop through each mailbox to fetch the Inbox Rules 
foreach ($Mailbox in $Mailboxes) 
{ 
    $MailboxRules = Get-Mailbox -Mailbox $Mailbox.UserPrincipalName |  Select Name, ForwardingAddress, ForwardingsmtpAddress, DeliverToMailboxAndForward 
    if ($MailboxRules) { 
        $i++ 
        Write-host -ForegroundColor $SystemMessageColor "$i`: Processing:" $Mailbox.UserPrincipalName "-" $Mailbox.PrimarySmtpAddress 
        foreach ($Forwarding in $MailboxRules) { 
            Write-host "`tRule Name: " -ForegroundColor $ErrorMessageColor -NoNewline 
            Write-host $Forwarding.Name  
            if ($Forwarding.ForwardingAddress -eq $null -and $Forwarding.ForwardingsmtpAddress -eq $null) { 
                write-host -ForegroundColor $OutputColor "`t`tNot Forward nor Redirect" 
            } 
            else { 
                if ($Forwarding.ForwardingAddress -ne $null -or $Forwarding.ForwardingsmtpAddress -ne $null) { 
                    foreach ($entry in $Forwarding.ForwardingAddress -or $Forwarding.ForwardingsmtpAddress) { 
                        write-host -ForegroundColor $InfoColor "`t`tForward To:" $Forwarding.ForwardingAddress) 
                        $TmpRule = New-Object -TypeName PSObject 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Mailbox -Value $Forwarding.DisplayName
                        $TmpRule| Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $Mailbox.PrimarySmtpAddress 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Name -Value $Forwarding.name 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name ForwardingAddress -Value $Forwarding.ForwardingAddress
                        $TmpRule| Add-Member -MemberType NoteProperty -Name ForwardingSmtpAddress -Value $Forwarding.ForwardingSmtpAddress
                        $TmpRule| Add-Member -MemberType NoteProperty -Name DeliverToMailboxAndForward -Value $Forwarding.DeliverToMailboxAndForward 
                        $Forwardings += $TmpRule 
                    } 
                } 
                Else {}
                # if ($Rule.RedirectTo -ne $null) { 
                #    foreach ($entry in $Rule.RedirectTo) { 
                #        write-host -ForegroundColor $InfoColor "`t`tRedirect To:" $($entry  | % {$($_.split("[")[0]).Replace('"',"")}) 
                #        $TmpRule = New-Object -TypeName PSObject 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name Mailbox -Value $Rule.MailboxOwnerID 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $Mailbox.PrimarySmtpAddress 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name RuleName -Value $Rule.name 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name ForwardTo -Value n/a 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name RedirectTo -Value $($entry  | % {$($_.split("[")[0]).Replace('"',"")}) 
                #        $TmpRule| Add-Member -MemberType NoteProperty -Name Description -Value $Rule.Description.ToString().replace("`n"," ").replace("`r"," ").replace("`t","") 
                #        $Rules += $TmpRule 
                #    } 
                #
                }#
            } 
        } 
    } 
    
} 

 
 
Write-Host -foregroundcolor $OutputColor "`nExporting Rules to: $Reportfile`n" 
$Rules | Export-Csv $Reportfile -NoTypeInformation 
#>