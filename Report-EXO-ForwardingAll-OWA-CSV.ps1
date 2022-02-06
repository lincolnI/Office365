<#
    .Link
    https://gallery.technet.microsoft.com/office/List-all-Mailboxes-with-c680b449

    .Description
    This program print and export Mailboxes with Inbox Rules that Forward or Redirect emails to another email addresses 
 
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
$ReportName = ( "$Date" + "-" + "AllForwardRules-" + $Tenant)
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
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

#counter 
$i = 0 
 
#Array for saving Report Data 
$Rules=@() 
 
#Loop through each mailbox to fetch the Inbox Rules 
foreach ($Mailbox in $Mailboxes) { 
    $MailboxRules = Get-InboxRule -Mailbox $Mailbox.UserPrincipalName 
    if ($MailboxRules) { 
        $i++ 
        Write-host -ForegroundColor $SystemMessageColor "$i`: Processing:" $Mailbox.UserPrincipalName "-" $Mailbox.PrimarySmtpAddress 
        foreach ($Rule in $MailboxRules) { 
            Write-host "`tRule Name: " -ForegroundColor $ErrorMessageColor -NoNewline 
            Write-host $Rule.Name  
            if ($Rule.ForwardTo -eq $null -and $Rule.RedirectTo -eq $null) { 
                write-host -ForegroundColor $OutputColor "`t`tNot Forward nor Redirect" 
            } 
            else { 
                if ($Rule.ForwardTo -ne $null) { 
                    foreach ($entry in $Rule.ForwardTo) { 
                        write-host -ForegroundColor $InfoColor "`t`tForward To:" $($entry | % {$($_.split("[")[0]).Replace('"',"")}) 
                        $TmpRule = New-Object -TypeName PSObject 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Mailbox -Value $Rule.MailboxOwnerID 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $Mailbox.PrimarySmtpAddress 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name RuleName -Value $Rule.name 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name ForwardTo -Value $($entry | % {$($_.split("[")[0]).Replace('"',"")}) 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name RedirectTo -Value "n/a" 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Description -Value $Rule.Description.ToString().replace("`n"," ").replace("`r","").replace("`t","") 
                        $Rules += $TmpRule 
                    } 
                } 
                if ($Rule.RedirectTo -ne $null) { 
                    foreach ($entry in $Rule.RedirectTo) { 
                        write-host -ForegroundColor $InfoColor "`t`tRedirect To:" $($entry  | % {$($_.split("[")[0]).Replace('"',"")}) 
                        $TmpRule = New-Object -TypeName PSObject 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Mailbox -Value $Rule.MailboxOwnerID 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name PrimarySmtpAddress -Value $Mailbox.PrimarySmtpAddress 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name RuleName -Value $Rule.name 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name ForwardTo -Value n/a 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name RedirectTo -Value $($entry  | % {$($_.split("[")[0]).Replace('"',"")}) 
                        $TmpRule| Add-Member -MemberType NoteProperty -Name Description -Value $Rule.Description.ToString().replace("`n"," ").replace("`r"," ").replace("`t","") 
                        $Rules += $TmpRule 
                    } 
 
                } 
            } 
        } 
    } 
} 
 
 
Write-Host -foregroundcolor $OutputColor "`nExporting Rules to: $Reportfile`n" 
$Rules | Export-Csv $Reportfile -NoTypeInformation 


write-host -foregroundcolor $OutputColor "`nFile $Reportfile Created"
Invoke-Item $ReportPath
Invoke-Item $Reportfile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------