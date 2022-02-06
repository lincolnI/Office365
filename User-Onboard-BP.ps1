<#
    .Link

    .Description
    Intended to run from Azure Shell
    Once session created:
    ./clouddrive/user-onboard-bp.ps1

    Decision:
    Get email as prompt and apply to only this user
    (Faster)
    OR
    Run against the whole org to apply to any users who do not have it set
    (Slower but useful if someone forgets)


    Set all mailboxes to English (Australia) and Sydney EST timezone
 
    .Notes
    If you have running scripts that don't have a certificate, run this command once to disable that level of security
        Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
        Set-Executionpolicy remotesigned
        Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force

    Disconnect PowerShell Sessions:
    - Get-PSSession | Remove-PSSession

#>

#----------------------------------------------------------------
################# Variables & Connect Exchange Online ################
#----------------------------------------------------------------

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Locations
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$bpoptions = @()
$ScriptRepo = ".\"                   ## Location on disk of free scripts repository
$publicrepo = ".\"                   ## Location on disk of free scripts repository



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Connect 365
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Set-Location $PSScriptRoot              # FQFSP of Running script
Connect-ExchangeOnline
<#$ConnectEXO = Read-Host "`nWould you like to Connect to Exchange Online (Y\N)?"

If ($ConnectEXO -eq "Y") {
   
    ## Remove existing sessions
    Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

    Write-host -ForegroundColor $SystemMessageColor "`nStart - Connecting to Exchange Online"
    
    ## Start Exchange Online session
    write-host -foregroundcolor $processmessagecolor "`nStart - Exchange login"
    Import-Module ExchangeOnline
    Connect-ExchangeOnline
    write-host -foregroundcolor $processmessagecolor "Finish - Exchange login`n`n"   

            <#
                Write-host -ForegroundColor $processmessagecolor "Start - Exchange Online"

                if ($mfa -eq $false) {
                    write-host -foregroundcolor $processmessagecolor "Start - Non MFA login"
                    &($publicrepo+"o365-connect-exo.ps1")                  ## Connect to Exchange Online with no MFA
                    write-host -foregroundcolor $processmessagecolor "Finish - Non MFA login`n"                                                                                                                       
                }                                                                                                                           
                else {
                    write-host -foregroundcolor $processmessagecolor "Start - MFA login"
                    &($publicrepo+"o365-connect-mfa-exo.ps1")                  ## Connect to Exchange Online with MFA
                    write-host -foregroundcolor $processmessagecolor "Finish - MFA login`n"                             
                }
            # >
}

Else {
Write-host -ForegroundColor $processmessagecolor "Continuing with current Exchange Online Session"
}#>

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Mailboxes = Get-Mailbox -ResultSize Unlimited
$LitigationUsers = ($Mailboxes | Where-Object {$_.LitigationHoldEnabled -eq $false}).UserPrincipalName
$bpoptions = @()  

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

#----------------------------------------------------------------
################# Office 365 Best Practice ################
#----------------------------------------------------------------
#### Enable legal hold mailboxes for all users ####
##get-mailbox | set-mailbox -litigationholdenabled $true

write-host -foregroundcolor $SystemMessageColor "`n`nStart - Enabling Legal Hold on All Mailboxes"
Foreach ($User in $LitigationUsers){
    Set-Mailbox -identity $User -LitigationHoldEnabled:$true
 }
write-host -foregroundcolor $SystemMessageColor "`nFinish - Enabling Legal Hold on All Mailboxes"
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Enable tenant auditing? 
write-host -foregroundcolor $processmessagecolor "`n`nStart - Enabling auditing"
$result = get-adminauditlogconfig                           ## Get current settings
if ($result.UnifiedAuditLogIngestionEnabled -eq $false){
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true      ## User and admin activities are recorded in the Office 365 audit log, and you can search the Office 365 audit log
}
$bpoptions = $bpoptions + @{"Unified Audit Log" = "Set"}
write-host -foregroundcolor $processmessagecolor "Finish - Enabling auditing`n" 
#----------------------------------------------------------------

#Pause Script, as next part will clear screen.
# Pause

#### Either need to upload all of these scripts as well so they can be called
#### OR include their full contents into this.
#----------------------------------------------------------------
#### Enable mailbox auditing? 
write-host -foregroundcolor $processmessagecolor "Start - Enable mailbox auditing"
.\o365-mx-alert-set.ps1         ## Run external script that is in the current directory
$bpoptions = $bpoptions + @{"Mailbox auditing" = "Set"}
write-host -foregroundcolor $processmessagecolor "Finish - Enable mailbox auditing`n" 

#----------------------------------------------------------------


#----------------------------------------------------------------
#### Extend mailbox audit log retention period?"
write-host -foregroundcolor $processmessagecolor "Start - Extend mailbox audit log retention period"
.\o365-mx-auditage-set.ps1 -nodebug         ## Run external script that is in the current directory
$bpoptions = $bpoptions + @{"Extend mailbox audit logs" = "Set"}
write-host -foregroundcolor $processmessagecolor "Finish - Extend mailbox audit log retention period`n" 
#----------------------------------------------------------------

#----------------------------------------------------------------
#### Extend mailbox deleted items retention period?
write-host -foregroundcolor $processmessagecolor "Start - Extend mailbox deleted items retention period"
## Extend audit log beyond the default 30 days 
.\o365-mx-retention-set.ps1 -nodebug         ## Run external script that is in the current directory
$bpoptions = $bpoptions + @{"Extend mailbox deleted items" = "Set"}
write-host -foregroundcolor $processmessagecolor "Finish - Extend mailbox deleted items retention period`n" 
#----------------------------------------------------------------

# Set-Location ..

#----------------------------------------------------------------
Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------