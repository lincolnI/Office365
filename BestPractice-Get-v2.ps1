param(                         ## if no parameter used then login without MFA and use interactive mode
    [switch]$nodebug = $false  ## if -nodebug parameter don't prompt for input 
)

<#
    .Link
    https://github.com/directorcia/patron/blob/master/o365-bp-get.ps1
    https://github.com/directorcia/patron/wiki/Office-365-Best-Practices-Get-V2-script

    .Description
    For use on tenant to compare the current settngs to best practices
    This script ONLY reads the environment, it doesn't make any changes

    .EXAMPLE
    .\BestPractice-Get-V1.ps1 -mfa (parameter used then login using MFA)
    .\BestPractice-Get-V1.ps1 -json (paramter used then don't use interactive mode i.e. not prompted for answers)
 
    .Notes
    
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
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$O365atpenable = $true                          ## is Office 365 Advanced Threat Protection included with the tennat
#$publicrepo = "..\Office365\"                   ## Location on disk of free scripts repository
$pass = "(.)"
$fail = "(X)"
$ScriptRepo = ".\CIAOPS\"                   ## Location on disk of free scripts repository
$publicrepo = ".\"                   ## Location on disk of free scripts repository

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #Log File Info
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$sLogName = ( "$Date" + "-" + "BestPracetice-Get-V2-" + $ClientName)
$sLogPath = "C:\RelianceIT\ScriptLogs"   ## Local Path where report will be saved
$sLogFile = Join-Path -Path $sLogPath -ChildPath "$sLogName.txt"      ## Location of export file

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start Logging ################
#----------------------------------------------------------------
If (!(test-path $sLogPath)) {
    New-Item -ItemType Directory -Path $sLogPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $sLogPath"
}


Start-Transcript -Path $sLogFile 
#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------

Clear-Host

write-host -foregroundcolor $systemmessagecolor "Start Script`n"

Set-Location $ScriptRepo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Adjust Script from Here: https://github.com/directorcia/patron/blob/master/o365-bp-get.ps1
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

start-transcript "..\o365-bp-get $(get-date -f yyyyMMddHHmmss).txt" | Out-Null          ## Log file output will be in parent directory
Write-Host -ForegroundColor $systemmessagecolor "`nScript started`n"

<# Test for prerequisites #>
<#
if (-not (test-path -path (".\o365-check.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[001] - Best practice prerequisites script does not exist in current directory- Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 1                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "Best practice prerequisites script found in current directory"
}

write-host -foregroundcolor $processmessagecolor "Start - Best practice prerequisites check"
.\o365-check.ps1 -wait                                   ## Connect to BP check script and wait till complete
if (-not [string]::isnullorempty($LASTEXITCODE)) {       ## Did the BP check script return an error?
    stop-transcript | Out-Null                           ## Stop transcript
    Exit                                                 ## Exit script
} 
write-host -foregroundcolor $processmessagecolor "Finish - Best practice prerequisites check`n"
#>
<# Remove any existing sessions #>
Get-PSSession | Remove-PSSession 

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Auditing / Logging`n"

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

<# Test for Exchange Online Connection script #>
if (-not (test-path -path ($publicrepo+"o365-connect-exov2.ps1"))) {        ## If the Exchange Online connection script doesn't exist
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[002] - Connect to Exchange Online script not found in", $publicrepo, "- Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 2                          ## Terminate script
}
else {                                                                      ## If the Exchange Online connection script does exist
    write-host -ForegroundColor $processmessagecolor "Connect to Exchange Online script found in", $publicrepo, "`n"
}

write-host -foregroundcolor $processmessagecolor "Start - Exchange Online login"
&($publicrepo+"o365-connect-exov2.ps1") -wait            ## Connect to Exchange Online V2 and wait till complete
if (-not [string]::isnullorempty($LASTEXITCODE)) {       ## Did the Exchange connection scrip return an error?
    write-host -ForegroundColor yellow -BackgroundColor $errormessagecolor "`n[",$LASTEXITCODE,"] - Error connecting to Exchange Online. Script terminated"
    write-host -ForegroundColor $errormessagecolor $error[0]        ## Display last error text
    stop-transcript | Out-Null                                      ## Stop transcript
    Exit                                                            ## Terminate script
} 
write-host -foregroundcolor $processmessagecolor "Finish - Exchange Online login`n"

If ($nodebug -eq $false) {Read-Host -Prompt "Press Enter to continue"}

Clear-Host

<#  Tenant Logs/Auditing    #>

<#  Audit log search    #> 
$auditlog_status = Get-AdminAuditLogConfig
if ($auditlog_status.UnifiedAuditLogIngestionEnabled -eq $false) {          ## If the Unified Audit log is disabled
    $messagecolour = "red"
    $suffix = $fail
}
else {
    $messagecolour = "green"
    $suffix = $pass
}
Write-host -ForegroundColor $messagecolour "Audit Log Search is enabled =", $auditlog_status.unifiedauditlogingestionenabled,$suffix
Write-Host
If ($nodebug -eq $false) {Read-Host -Prompt "Press Enter to continue"}

<#  Start - Exchange Online #>
Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Exchange Online"

<#  Mailbox auditing    #> 
<# Test for o365-mx-alert-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-alert-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[003] - o365-mx-alert-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 3                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-alert-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Mailbox auditing settings"
.\o365-mx-alert-get.ps1 -nodebug                                      ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Mailbox auditing settings`n" 

Write-host -foregroundcolor cyan -BackgroundColor blue "Finish - Auditing / Logging`n"
If ($nodebug -eq $false) {Read-Host -Prompt "Press Enter to continue"}

<#  Mailbox general settings    #>
<# Test for o365-mx-audit-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-audit-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[004] - o365-mx-audit-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 4                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-audit-get.ps1 script found in current directory`n"
}

write-host -foregroundcolor $processmessagecolor "Start - Get Mailbox general settings"
.\o365-mx-audit-get.ps1 -nodebug         ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Mailbox general settings`n" 

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

<#  User mailbox general settings    #>
<# Test for o365-mx-usr-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-usr-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[005] - o365-mx-usr-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 5                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-usr-get.ps1 script found in current directory`n"
}

write-host -foregroundcolor $processmessagecolor "Start - Get User Mailbox general settings"
.\o365-mx-usr-get.ps1              ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Mailbox general settings`n" 

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

<#  User junk mail settings    #>
<# Test for o365-mx-junk-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-junk-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[006] - o365-mx-junk-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 6                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-junk-get.ps1 script found in current directory`n"
}

write-host -foregroundcolor $processmessagecolor "Start - Get junk mail settings"
.\o365-mx-junk-get.ps1              ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get junk mail settings`n" 

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

<#  Exchange organisation    #>
<# Test for o365-mx-org-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-org-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[007] - o365-mx-org-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 7                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-org-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Exchange organisation general settings"
.\o365-mx-org-get.ps1           ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Exchange organisations general settings`n" 

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<#  Display tenant external domain forwarding    #>
<# Test for o365-mx-rmdom-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-rmdom-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[008] - o365-mx-rmdom-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 8                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-rmdom-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Exchange Remote Domain settings"
.\o365-mx-rmdom-get.ps1           ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Exchange Remote Domain settings`n" 

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<#  SPAM Policies    #>
<# Test for o365-mx-spam-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-spam-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[009] - o365-mx-spam-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 9                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-spam-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Mailbox spam settings`n"
.\o365-mx-spam-get.ps1           ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Mailbox spam settings`n" 
write-host

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

<#  Malware Policies    #>
<# Test for o365-mx-malware-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-malware-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[010] - o365-mx-malware-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 10                         ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-malware-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Mailbox malware settings`n"
.\o365-mx-malware-get.ps1           ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Mailbox malware settings`n" 
write-host

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

<#  Connection Filter Policies    #>
<# Test for o365-mx-connectpolicy-get.ps1 script #>
if (-not (test-path -path (".\o365-mx-connectpolicy-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[011] - o365-mx-connectpolicy-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 11                         ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-connectpolicy-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Exchange Connection Filter Policy settings`n"
.\o365-mx-connectpolicy-get.ps1 -nodebug           ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Exchange Connection Filter Policy settings`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<#  Office 365 ATP    #>
<# Test for o365-atp-get.ps1 script #>
if (-not (test-path -path (".\o365-atp-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[012] - o365-atp-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 12                         ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-atp-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Office 365 ATP settings`n"
.\o365-atp-get.ps1                    ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get office 365 ATP settings`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Display Transport rules that forward email to external domain #>
Write-host -ForegroundColor $messagecolour "Transport Rules that forward email to external domain"
Get-TransportRule | Where-Object { $_.RedirectMessageTo -ne $null } | ft Name, RedirectMessageTo
Write-Host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Display Transport rules that whitelist specific domains #>
Write-host -ForegroundColor $messagecolour "Transport Rules that whitelist specific external domain"
Get-TransportRule | Where-Object { ($_.setscl -eq -1 -and $_.SenderDomainIs -ne $null) } | ft Name, SenderDomainIs
Write-Host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Display Journaling rules as they can be used to forward emails #>
Write-host -ForegroundColor $messagecolour "Journaling Rules - Start"
Get-JournalRule
Write-host -ForegroundColor $messagecolour "Journaling Rules - End"
Write-Host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

## Get DKIM status
Write-host -ForegroundColor $systemmessagecolor "Start - DKIM Status`n"
$dkim_status=get-dkimsigningconfig
foreach ($domain in $dkim_status){
    if ($domain.Enabled -ne $true) {
        $messagecolour = "red"
        $suffix=$fail
    }
    else {
        $messagecolour = "green"
        $suffix=$pass
    }
    Write-host -ForegroundColor $messagecolour "DKIM =", $domain.enabled,$domain.domain,$suffix
}
write-host 
Write-host -ForegroundColor $systemmessagecolor "Finish - DKIM Status`n"

<#  Shared mailboxes should have interactive login disabled #>
write-host -ForegroundColor $processmessagecolor "Getting shared mailboxes"
$Mailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited
write-host -ForegroundColor $processmessagecolor "Start checking shared mailboxes"
write-host

Connect-AzureAD     ## Connect to Azure AD to get userprincipal names
Clear-Host

If ($nodebug -eq $false) { Read-Host -Prompt "Press Enter to continue" }

foreach ($mailbox in $mailboxes) {
    $accountdetails = get-azureaduser -objectid $mailbox.userprincipalname        ## Get the Azure AD account connected to shared mailbox
    If ($accountdetails.accountenabled) {                                         ## If that login is enabled then it shouldn't be
        Write-host -foregroundcolor $errormessagecolor $mailbox.displayname, "["$mailbox.userprincipalname"] - Direct Login ="$accountdetails.accountenabled, $fail
    }
    else {                                                                        ## Direct login is disabled
        Write-host -foregroundcolor $processmessagecolor $mailbox.displayname, "["$mailbox.userprincipalname"] - Direct Login ="$accountdetails.accountenabled, $pass
    }
}
write-host -ForegroundColor $processmessagecolor "`nFinish checking mailboxes`n"

Write-host -foregroundcolor cyan -BackgroundColor blue "Finish - Exchange Online`n"

## Remove existing sessions
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

<#  Finish - Exchange Online    #>

<# Start - Skype for Business Online #>

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Skype for Business Online"

write-host -foregroundcolor $processmessagecolor "Start - login"
&($publicrepo+"o365-connect-mfa-s4b.ps1")                  ## Connect to Skype for Business Online with MFA
write-host -foregroundcolor $processmessagecolor "Finish -login`n"                             

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<# Test for o365-skype-get.ps1 script #>
if (-not (test-path -path (".\o365-skype-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[007] - o365-skype-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 7                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-skype-get.ps1 script found in current directory`n"
}

write-host -foregroundcolor $processmessagecolor "Start - Get Skype Auth settings"
.\o365-skype-get.ps1                                      ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Skype Auth settings`n" 
If ($nodebug -eq $false) {Read-Host -Prompt "Press Enter to continue"}

## Stream Transcription
$skypeconfig_status = get-CsTeamsMeetingPolicy -identity Global
if ($skypeconfig_status.allowtranscription -ne $true) {
    $messagecolour = "red"
    $suffix=$fail
}
else {
    $messagecolour = "green"
    $suffix=$fail
}
Write-host -ForegroundColor $messagecolour "Stream transcription =", $skypeconfig_status.allowtranscription,$suffix

<#  Finish - Skype for Business Online    #>

Write-host -foregroundcolor cyan -BackgroundColor blue "`nFinish - Skype for Business Online`n"

## Remove existing sessions
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<# Start - SharePoint Online #>

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - SharePoint Online"

write-host -foregroundcolor $processmessagecolor "Start - login"
&($publicrepo+"o365-connect-mfa-spo.ps1")                  ## Connect to SharePoint Online with MFA
write-host -foregroundcolor $processmessagecolor "Finish - login`n"                             

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<# Test for o365-spo-orgconf-get.ps1 script #>
if (-not (test-path -path (".\o365-spo-orgconf-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[101] - o365-spo-orgconf.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 101                        ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-spo-orgconf-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get SharePoint organisation settings`n"
.\o365-spo-orgconf-get.ps1                    ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get SharePoint organisation settings`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

## ShareOnline and OneDrive idle time out
$idle_status = get-SPOBrowserIdleSignOut
if ($idle_status.Enabled -ne $true) {
    $messagecolour = "red"
    $suffix=$fail
}
else {
    $messagecolour = "green"
    $suffix=$pass
}
Write-host -ForegroundColor $messagecolour "SharePoint and OneDrive idle timeout =", $idle_status.enabled,$suffix
Write-Host

<#  Finish - SharePoint Online    #>

Write-host -foregroundcolor cyan -BackgroundColor blue "`nFinish - SharePoint Online`n"

## Remove existing sessions
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<# Start - MS Online #>

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Microsoft Online"

write-host -foregroundcolor $processmessagecolor "Start - login"
&($publicrepo+"o365-connect-mfa.ps1")              ## Connect to to MS Online with MFA
write-host -foregroundcolor $processmessagecolor "Finish - login`n"                             

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Clear-Host

<# Licenses - Check whether all licenses available have been allocated #>

write-host -foregroundcolor $processmessagecolor "Start - License usage check`n"
$license = get-msolaccountsku              ## Display license count
foreach ($licensecount in $license) {      ## Loop through all available licenses
    if ($licensecount.consumedunits -lt $licensecount.activeunits) { 
        $messagecolour = "red"              # If not all licenses are being used
        $suffix=$fail
    }
    else {
        $messagecolour = "green"            # Else all licenses are allocated
        $suffix=$pass
    }
    Write-host -ForegroundColor $messagecolour $licensecount.accountskuid,"("$licensecount.consumedunits,"of",$licensecount.activeunits,"in use)"$suffix
}
Write-Host
write-host -foregroundcolor $processmessagecolor "Finish - License usage check`n"


If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}
Clear-Host

<# Can users add apps to their environment? #>
$companyinf_status = Get-MsolCompanyInformation
if ($companyinf_status.UsersPermissionToUserConsentToAppEnabled -eq $true) {    ## Indicates whether to allow users to consent to apps that require access to their cloud user data, such as directory user profile or Office 365 mail and OneDrive for business. This setting is applied company-wide. 
    $messagecolour = "red"
    $suffix=$fail
}
else {
    $messagecolour = "green"
    $suffix=$pass
}
Write-host -ForegroundColor $messagecolour "Users allowed to add Outlook add-ins =",$companyinf_status.UsersPermissionToUserConsentToAppEnabled,$suffix
Write-Host

<# Is the self service password reset portal enabled? #>
if ($companyinf_status.SelfServePasswordResetEnabled -ne $true) {    ## Indicates whether to allow users to consent to apps that require access to their cloud user data, such as directory user profile or Office 365 mail and OneDrive for business. This setting is applied company-wide. 
    Write-host -ForegroundColor $errormessagecolor "User self service password reset portal  =", $companyinf_status.SelfServePasswordResetEnabled, $fail
}
else {
    Write-host -ForegroundColor $processmessagecolor "User self service password reset portal  =", $companyinf_status.SelfServePasswordResetEnabled, $pass
}
Write-Host

If ($nodebug -eq $false) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}
Clear-Host

## Display password expiry settings
Write-host -ForegroundColor $systemmessagecolor "Start - User password expiry settings`n"
$users = get-msoluser
foreach ($user in $users) {                             ## Cycle through all these users
    if ($user.passwordnevrexpires -eq $true) {          ## Report a user that has a password expiry option
        Write-host -foregroundcolor $errormessagecolor $user.displayname, "Password expiry =", $user.passwordneverexpires,$fail
    }
}
Write-host -ForegroundColor $systemmessagecolor "`nFinish - User password expiry settings`n"

Write-host -foregroundcolor cyan -BackgroundColor blue "Finish - Microsoft Online`n"

## Display Global Admins MFA state
Write-host -ForegroundColor $systemmessagecolor "Start - Global Admins MFA state`n"
$global_role = get-msolrole -rolename "Company Administrator"           # Get Global Admins by role
$global_admins = Get-MsolRoleMember -RoleObjectId $global_role.objectid # Find users with the Global Admin role
foreach ($user in $global_admins) {                                     # Cycle through all these users
    if ($user.StrongAuthenticationRequirements.state -ne $null) {       # is MFA enabled?
        Write-host -foregroundcolor $processmessagecolor $user.displayname,"MFA =", $user.strongauthenticationrequirements.state,"["$user.emailaddress"]",$pass
    }
    else {                                                              # if it is not
        write-host -foregroundcolor $errormessagecolor $user.DisplayName, "MFA = Disabled ["$user.emailaddress"]",$fail
    }
}
Write-host -ForegroundColor $systemmessagecolor "`nFinish - Global Admins MFA State`n"

Write-host -foregroundcolor cyan -BackgroundColor blue "Finish - Microsoft Online`n"

<# Start - Security and Compliance #>

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Security and Compliance"

write-host -foregroundcolor $processmessagecolor "Start - login"
&($publicrepo + "o365-connect-mfa-sac.ps1")              ## Connect to to MS Online with MFA
write-host -foregroundcolor $processmessagecolor "Finish - login`n"                             

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Protection Alerts #>

write-host -foregroundcolor $processmessagecolor "Start - Get Protection Alerts"
.\o365-protect-alerts-get.ps1 -nodebug           ## Run external script that is in the current directory don't prompt for input
write-host -foregroundcolor $processmessagecolor "Finish - Get Protection Alerts`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

<# Activity Alerts #>

write-host -foregroundcolor $processmessagecolor "Start - Get Activity Alerts"
.\o365-activity-alerts-get.ps1 -nodebug           ## Run external script that is in the current directory don't prompt for input
write-host -foregroundcolor $processmessagecolor "Finish - Get Activity Alerts`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }


Write-host -foregroundcolor cyan -BackgroundColor blue "`nFinish - Security and Compliance`n"

## Remove existing sessions
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Start - MS Teams #>

Write-host -foregroundcolor cyan -BackgroundColor blue "Start - Microsoft Teams"

<# Test for Teams connection script #>
if (-not (test-path -path ($publicrepo + "o365-connect-tms.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[402] - Connect to Teams script not found in", $publicrepo, "- Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 402                        ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "Connect to Teams script found in", $publicrepo, "`n"
}

write-host -foregroundcolor $processmessagecolor "Start - login"
&($publicrepo + "o365-connect-mfa-tms.ps1")              ## Connect to to MS Teams with MFA
write-host -foregroundcolor $processmessagecolor "Finish - login`n"                             

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Clear-Host

<# Get Teams #>
<# Test for o365-tms-get.ps1 script #>
if (-not (test-path -path (".\o365-tms-get.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[403] - o365-tms-get.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 403                        ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-tms-get.ps1 script found in current directory`n"
}
write-host -foregroundcolor $processmessagecolor "Start - Get Teams details"
.\o365-tms-get.ps1                         ## Run external script that is in the current directory
write-host -foregroundcolor $processmessagecolor "Finish - Get Teams details`n" 
write-host

If ($nodebug -eq $false) { Read-Host -Prompt "[DEBUG] -- Press Enter to continue" }

Write-host -foregroundcolor cyan -BackgroundColor blue "`nFinish - Microsoft Teams`n"

#----------------------------------------------------------------

Stop-Transcript
Write-Host -foregroundcolor $SystemMessageColor "`nFile $sLogFile Created"