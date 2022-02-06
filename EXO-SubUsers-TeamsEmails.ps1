<#
    .Link
    Subscribe Users to receive emails sent to the Team email

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
    Import-Module ExchangeOnline
    Connect-ExchangeOnline
    write-host -foregroundcolor $processmessagecolor "Finish - Exchange login`n`n"   

}

Else {
Write-host -ForegroundColor $processmessagecolor "Continuing with current Exchange Online Session"
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Identity = Read-Host "What is the Group / Team name i.e. Teams Demo?"
$ChangePrimarySmtpAddress = Read-Host "`nWould you like to change the primary SMTP (Y\N)?"

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If ($ChangePrimarySmtpAddress -eq "Y") {

    $PrimarySmtpAddress = Read-Host "`nNew Email Address?"

    ## Set email and sub users
    write-host -foregroundcolor $processmessagecolor "`nStart - Setting Email Address, Subscribe Existing users, Auto Subscribe New Users, Enable External Emails"
    Set-UnifiedGroup –Identity $Identity –PrimarySmtpAddress $PrimarySmtpAddress -SubscriptionEnabled:$true -AutoSubscribeNewMembers -RequireSenderAuthenticationEnabled $false
    write-host -foregroundcolor $processmessagecolor "Finish - Script`n`n"   
}

Else {
    write-host -foregroundcolor $processmessagecolor "`nStart - Subscribe Existing users, Auto Subscribe New Users, Enable External Emails"
    Set-UnifiedGroup –Identity $Identity -SubscriptionEnabled:$true -AutoSubscribeNewMembers -RequireSenderAuthenticationEnabled $false
    write-host -foregroundcolor $processmessagecolor "Finish - Script`n`n"
}

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------