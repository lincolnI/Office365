<#
    .Link
    https://github.com/directorcia/Office365/blob/master/o365-exo-sharedblock.ps1
    https://blog.ciaops.com/2019/05/13/script-to-disable-direct-shared-mailbox-logins/

    .Description
    Script to repoort and potentially disable interactive logins to shared mailboxes


    .Notes
    Prerequisites = 2
        1. Connected to Exchange Online
        2. Connect to Azure AD

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
$ErrorMessageColor = "Red"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Secure = $false         ## $true = shared mailbox login will be automatically disabled, $false = report only

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

    write-host -ForegroundColor $processmessagecolor "Getting shared mailboxes"
    $Mailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited
    write-host -ForegroundColor $processmessagecolor "Start checking shared mailboxes"
    write-host
    foreach ($mailbox in $mailboxes) {
        $accountdetails=get-azureaduser -objectid $mailbox.userprincipalname        ## Get the Azure AD account connected to shared mailbox
        If ($accountdetails.accountenabled){                                        ## if that login is enabled
            Write-host -foregroundcolor $errormessagecolor $mailbox.displayname,"["$mailbox.userprincipalname"] - Direct Login ="$accountdetails.accountenabled
            If ($secure) {                                                          ## if the secure variable is true disable login to shared mailbox
                Set-AzureADUser -ObjectID $mailbox.userprincipalname -AccountEnabled $false     ## disable shared mailbox account
                $accountdetails=get-azureaduser -objectid $mailbox.userprincipalname            ## Get the Azure AD account connected to shared mailbox again
                write-host -ForegroundColor $processmessagecolor "*** SECURED"$mailbox.displayname,"["$mailbox.userprincipalname"] - Direct Login ="$accountdetails.accountenabled
            }
        } else {
            Write-host -foregroundcolor $processmessagecolor $mailbox.displayname,"["$mailbox.userprincipalname"] - Direct Login ="$accountdetails.accountenabled
        }
    }
    write-host -ForegroundColor $processmessagecolor "`nFinish checking mailboxes"
    write-host

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------