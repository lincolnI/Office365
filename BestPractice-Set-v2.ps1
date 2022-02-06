param(                          ## if no parameter then use intercative mode i.e prompt and no debug
    [switch]$json = $false,     ## if -json paramter used then don't use interactive mode i.e. not prompted for answers
    [switch]$debug = $false,    ## if -debug parameter output script execution to text log file
    [switch]$noprompt = $false  ## if -noprompt parameter used don't prompt user for input
)

<#
    .Link
    https://github.com/directorcia/patron
    https://github.com/directorcia/patron/wiki/Office-365-Best-Practices-V2-script-details

    .Description
    Apply best practices to tenant. Load each service module individually and then perform tasks

    .EXAMPLE
    .\BestPractice-Set-V1.ps1 -mfa (parameter used then login using MFA)
    .\BestPractice-Set-V1.ps1 -json (paramter used then don't use interactive mode i.e. not prompted for answers)
 
    .Notes
    Prerequisites = 1
        1. All required Patron scripts MUST be in the same directory as this script, so make sure you are in that directory before running this
        2. Ensure free scripts are in a directory defined by $publicrepo below

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
$script_debug=$false                            ## pause after each stage and wait for key press. Set to $false to disable
$bpoptions = @()                                ## where all the options selected for best practices here end up
$parameterfile = ".\bp.json"                    ## Output JSON file of choices
$emailloglimit = 180                            ## Retention period in days for mailbox audit logs
$ScriptRepo = ".\CIAOPS\"                   ## Location on disk of free scripts repository
$publicrepo = ".\"                   ## Location on disk of free scripts repository

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# #Log File Info
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$sLogName = ( "$Date" + "-" + "BestPracetice-Set-V2-" + $ClientName)
$sLogPath = "C:\RelianceIT\ScriptLogs"   ## Local Path where report will be saved
$sLogFile = Join-Path -Path $sLogPath -ChildPath "$sLogName.txt"      ## Location of export file

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Functions ################
#----------------------------------------------------------------
function fileexists() {
    param (
            $file,
            $code
    )
        if (-not (test-path -path ($file))) {
            write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[",$code,"] ",$file,"- not found - Please ensure exists first`n"
            Stop-Transcript | Out-Null      ## Terminate transcription
            exit                            ## Terminate script
        }
        else {
            write-host -ForegroundColor $processmessagecolor $file,"found`n"
        }
    }

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
# Adjust Script from Here: https://github.com/directorcia/patron/blob/master/o365-bp-set.ps1
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<# Test for prerequisites #>
<#
if (-not (test-path -path (".\o365-check.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[001] - Best practice prerequisites script does not exist in current directory- Please ensure exists first`n"
    if ($debug) {
        Stop-Transcript | Out-Null      ## Terminate transcription
    }
    exit 1                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "Best practice prerequisites script found in current directory"
}

write-host -foregroundcolor $processmessagecolor "Start - Best practice prerequisites check"
.\o365-check.ps1 -wait            ## Connect to BP check script and wait till complete
if ($LASTEXITCODE -ne 0) {       ## Did the BP check script return an error?
    stop-transcript | Out-Null
    Exit
} 
write-host -foregroundcolor $processmessagecolor "Finish - Best practice prerequisites`n"
#>

<#  Test for parameter file #>
if ($json){                                 ## has an input parameter JSON file been specified?
    if (test-path $parameterfile){          ## if yes, see if parameter file exists in current directory
        $options=get-content -raw -path $parameterfile | ConvertFrom-Json       ## Import JSON file to $options variable array
    }
    else {                                  ## if parameter file doesn't exist in current directory
        write-host -ForegroundColor $warningmessagecolor $parameterfile + "not found"
        $execute = read-host "Do wish to continue using interactive mode? (Y/N)"
        if ($execute -eq 'Y' -or $execute -eq 'y') {
            $json = $false
        } else { 
            throw $parameterfile+" does not exist. Script terminated"   ## terminate script
        }
    }
}

## Remove existing sessions
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

write-host -foregroundcolor $processmessagecolor "Start - Exchange Online login"
& ($publicrepo+"o365-connect-exo.ps1") -noupdate -wait            ## Connect to Exchange Online V2 and wait till complete
if ($LASTEXITCODE -ne 0) {       ## Did the Exchange connection script return an error?
    write-host -ForegroundColor yellow -BackgroundColor $errormessagecolor "`n[",$LASTEXITCODE,"] - Error connecting to Exchange Online. Script terminated"
    write-host -ForegroundColor $errormessagecolor $error[0]        ## Display last error text
    Stop-Transcript | Out-Null
    Exit
} 
write-host -foregroundcolor $processmessagecolor "Finish - Exchange Online login`n"

<#  Tenant Auditing    #>
if ($json){                                                     ## If input file specified
    if ($options."Unified audit log" -eq "Set"){                ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Enable tenant auditing? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {                    ## Enable option selected
    write-host -foregroundcolor $processmessagecolor "Start - Enabling auditing"
    $result = get-adminauditlogconfig                           ## Get current settings
    if ($result.UnifiedAuditLogIngestionEnabled -eq $false){
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true      ## User and admin activities are recorded in the Office 365 audit log, and you can search the Office 365 audit log
    }
    $bpoptions = $bpoptions + @{"Unified Audit Log" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Enabling auditing`n" 
} else {
    $bpoptions = $bpoptions + @{"Unified Audit Log" = "Default"}
}

<# Test for o365-mx-spam-set.ps1 script #>
if (-not (test-path -path (".\o365-mx-spam-set.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[003] - o365-mx-spam-set.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 3                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-spam-set.ps1 script found in current directory`n"
}

<#  SPAM policies  #>
if ($json){
    if ($options."Spam policies" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Create additional spam policies? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Spam policy creation"
    .\o365-mx-spam-set.ps1           ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Spam Policies" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Spam policy creation`n" 
} else {
    $bpoptions = $bpoptions + @{"Spam Policies" = "Default"}
}

<# Test for o365-mx-malware-set.ps1 script #>
if (-not (test-path -path (".\o365-mx-malware-set.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[004] - o365-mx-malware-set.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 4                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-malware-set.ps1 script found in current directory`n"
}

<#  Malware Policies   #>
if ($json){
    if ($options."Malware policies" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Create malware policies? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Malware policy creation"
    .\o365-mx-malware-set.ps1        ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Malware Policies" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Malware policy creation`n" 
} else {
    $bpoptions = $bpoptions + @{"Malware Policies" = "Default"}
}

<# Test for o365-mx-connectpolicy-set.ps1 script #>
if (-not (test-path -path (".\o365-mx-connectpolicy-set.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[005] - o365-mx-connectpolicy-set.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 5                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-connectpolicy-set.ps1 script found in current directory`n"
}

<#  Connection FIltering Policies   #>
if ($json){
    if ($options."Connection Filtering" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Update Connection Filtering policies? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Update Connection Filtering"
    .\o365-mx-connectpolicy-set.ps1        ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Connection Filtering" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Update Connection Filtering`n" 
} else {
    $bpoptions = $bpoptions + @{"Connection Filtering" = "Default"}
}

<#  Set auditing on all mailboxes    #>
if ($json){
    if ($options."Mailbox auditing" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Enable mailbox auditing? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Enable mailbox auditing"
    .\o365-mx-alert-set.ps1         ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Mailbox auditing" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Enable mailbox auditing`n" 
} else {
    $bpoptions = $bpoptions + @{"Mailbox auditing" = "Default"}
}
<#  Extend mailbox audit log retention period    #>
if ($json){
    if ($options."Extend mailbox audit logs" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Extend mailbox audit log retention period? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Extend mailbox audit log retention period"
    .\o365-mx-auditage-set.ps1 -nodebug         ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Extend mailbox audit logs" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Extend mailbox audit log retention period`n" 
} else {
    $bpoptions = $bpoptions + @{"Extend mailbox audit logs" = "Default"}
}
<#  Extend mailbox deleted items retention period    #>
if ($json){
    if ($options."Extend mailbox deleted items" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Extend mailbox deleted items retention period? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Extend mailbox deleted items retention period"
    ## Extend audit log beyond the default 30 days 
    .\o365-mx-retention-set.ps1 -nodebug         ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Extend mailbox deleted items" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Extend mailbox deleted items retention period`n" 
} else {
    $bpoptions = $bpoptions + @{"Extend mailbox deleted items" = "Default"}
}
<#  Enable Archive on all mailboxes    #>
if ($json){
    if ($options."Mailbox archive" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Add an archive mailbox for all mailboxes? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Add archive mailbox"
    .\o365-mx-archive-set.ps1                ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Mailbox archive" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Add archive mailbox`n" 
} else {
    $bpoptions = $bpoptions + @{"Mailbox archive" = "Default"}
}
<#  Set Remote Domain options    #>
if ($json){
    if ($options."Remote domain defaults" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Set default remote domain options? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Set default remote domain options"
    .\o365-mx-remotedomain.ps1          ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Remote domain defaults" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Set default remote domain options`n" 
} else {
    $bpoptions = $bpoptions + @{"Remote domain defaults" = "Default"}
}
<#  Disable all mailbox forwards    #>
if ($json){
    if ($options."Disable mailbox forwards" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Disable all mailbox forwards? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Disable all mailbox forwards"
    .\o365-mx-fwd-disable.ps1           ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Disable mailbox forwards" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Disable all mailbox forwards`n" 
} else {
    $bpoptions = $bpoptions + @{"Disable mailbox forwards" = "Default"}
}
<#  Disable POP and IMAP    #>
if ($json){
    if ($options."Disable POP and IMAP" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Disable POP and IMAP? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Disable POP and IMAP"
    .\o365-mx-popimap-disable.ps1 -nodebug       ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Disable POP and IMAP" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Disable POP and IMAP`n" 
} else {
    $bpoptions = $bpoptions + @{"Disable POP and IMAP" = "Default"}
}

<#  Disable EWS    #>
<# Test for o365-mx-ews-set.ps1 script #>
if (-not (test-path -path (".\o365-mx-ews-set.ps1"))) {
    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[006] - o365-mx-ews-set.ps1 script not found in current directory - Please ensure exists first`n"
    Stop-Transcript | Out-Null      ## Terminate transcription
    exit 6                          ## Terminate script
}
else {
    write-host -ForegroundColor $processmessagecolor "o365-mx-ews-set.ps1 script found in current directory`n"
}
if ($json){
    if ($options."Disable EWS" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Disable Exchange Web Services? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Disable EWS"
    .\o365-mx-ews-set.ps1 -nodebug       ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Disable EWS" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Disable EWS`n" 
} else {
    $bpoptions = $bpoptions + @{"Disable EWS" = "Default"}
}

<#  Set Exchange Organizational best practices    #>
if ($json){
    if ($options."Exchange org config" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Set Exchange Organizational best practices? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Set Exchange Organizational best practices"
    .\o365-mx-org-set.ps1             ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Exchange org config" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Set Exchange Organizational best practices`n" 
} else {
    $bpoptions = $bpoptions + @{"Exchange org config" = "Default"}
}

<#  Enable Safe List on default Exchange Online Connection Filter Policy    #>
if ($json) {
    if ($options."Safe List" -eq "Set") {
        $execute = "Y"
    }
    else {
        $execute = "N"
    }
}
else {
    $execute = Read-Host -Prompt "Set Safe List on default Exchange Online Connection Filter Policy? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Set Safe List on default Exchange Online Connection Filter Policy"
    set-hostedconnectionfilterpolicy "default" -enablesafelist $true            ## Enable Safe Lists option in default Exchange Online Connection Filter Policy
    $bpoptions = $bpoptions + @{"Safe List" = "Set" }
    write-host -foregroundcolor $processmessagecolor "Finish - Set Safe List on default Exchnage Online Connection Filter Policy`n" 
}
else {
    $bpoptions = $bpoptions + @{"Safe List" = "Default" }
}

<#  Enable Legal Hold on user mailboxes    #>
if ($json){
    if ($options."Legal hold" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Enable Legal Hold for all mailboxes? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Enable Legal Hold for all users"
    .\o365-mx-legal-set.ps1 -nodebug             ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"Legal Hold" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Enable Legal Hold for all users`n" 
} else {
    $bpoptions = $bpoptions + @{"Legal Hold" = "Default"}
}

<#  Enable Modern Authentication for Exchange Online    #>
if ($json){
    if ($options."Modern Auth Exchange" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Enable Modern Authentication for Exchange Online? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Enable Modern Authentication for Exchange Online"
    Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
    $bpoptions = $bpoptions + @{"Modern Auth Exchange" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Enable Modern Authentication for Exchange Online`n" 
} else {
    $bpoptions = $bpoptions + @{"Modern Auth Exchange" = "Default"}
}
<#  Disable Basic Authentication for Exchange Online    #>
<#  Be EXTREMELEY careful when you disable basic authentication as it can break many things that still rely on it #>
<#  This can break third party backup programs, COnnectwise integration, etc    #>
<#  ## https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online #>
<#  Can also affect iOS mail if you have add ins blocked. See - https://blog.ciaops.com/2018/11/05/policy-that-prevents-you-from-granting-ios-accounts-the-permissions/ #>
<#  User Remove-AuthenticationPolicy -identity "Block Basic Auth"  if you want to re-enable basic authentication #>
if ($json){
    if ($options."Basic Auth Exchange off" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Disable Basic Authentication for Exchange Online? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Disable Basic Authentication for Exchange Online"
    <#      Check for existing rules of same name       #>
    Write-host -ForegroundColor $processmessagecolor "Check for existing policy"
    $blockpolicy = Get-authenticationpolicy
    if ($blockpolicy.name -contains "Block Basic Auth"){            ## Does an existing spam policy of same name already exist?
        write-host -ForegroundColor $errormessagecolor ("Block Basic Auth already exists - No changes made")
    } else {                                                ## If not create a policy
        New-AuthenticationPolicy -Name "Block Basic Auth"                       ## Create a new authentication policy within the organisation
        Set-OrganizationConfig -DefaultAuthenticationPolicy "Block Basic Auth"  ## Make this new authentication policy the default for all users in the organisation
    }
    $bpoptions = $bpoptions + @{"Basic Auth Exchange off" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Disable Basic Authentication for Exchange Online`n" 
} else {
    $bpoptions = $bpoptions + @{"Basic Auth Exchange off" = "Default"}
}
<#  Configure Office 365 Advanced Threat Protection(ATP)    #>
if ($json){
    if ($options."Configure Office 365 ATP" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Configure Office 365 Advanced Threat Protection (ATP)? (Y/N)"
}

<#      Defender for Office 365         #>
<# Test for Defender for Office 365     #>
try {
    $dforo365 = get-atppolicyforo365 | Out-Null
}
catch {
    Write-Host -ForegroundColor $warningmessagecolor "[Warning] - Defender for Office 365 does not appear to be available for this tenant `n"
    $dforo365 = $false          # Confirm Defender for Office 365 is NOT part of tenant
}
if ($dforo365) {            # check whether defender for Office 365 is part of tenant
    <# Test for o365-atp-set.ps1 script #>
    if (-not (test-path -path (".\o365-atp-set.ps1"))) {
        write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "[006] - o365-atp-set.ps1 script not found in current directory - Please ensure exists first`n"
        Stop-Transcript | Out-Null      ## Terminate transcription
        exit 6                          ## Terminate script
    }
    else {
        write-host -ForegroundColor $processmessagecolor "o365-atp-set.ps1 script found in current directory`n"
    }

    if ($execute -eq 'Y' -or $execute -eq 'y') {
        write-host -foregroundcolor $processmessagecolor "Start - Configure Office 365 ATP"
        .\o365-atp-set.ps1                      ## Run external script that is in the current directory
        $bpoptions = $bpoptions + @{"Configure Office 365 ATP" = "Set"}
        write-host -foregroundcolor $processmessagecolor "Finish - Configure Office 365 ATP`n" 
    } else {
        $bpoptions = $bpoptions + @{"Configure Office 365 ATP" = "Default"}
    }
}

## End Exchange online session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

Write-host -ForegroundColor $processmessagecolor "Finish - Exchange Online"
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Write-host -ForegroundColor $processmessagecolor "Start - Office 365 Centralized Deployment"

<#  Add standard Outlook addins - Report Message, Message Header Analyzer, Findtime    #>
if ($json){
    if ($options."Standard Outlook addins" -eq "Set"){
        $execute = "Y"
    } else {
        $execute = "N"
    }
} else {
    $execute=Read-Host -Prompt "Add standard Outlook addins for all users? (Y/N)"
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Add standard Outlook addins all users"
    & ($publicrepo+"o365-addin-deploy.ps1") -noupdate                  ## Run external script that is in the free scripts directory 
    $bpoptions = $bpoptions + @{"Standard Outlook addins" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Add standard Outlook addins for all users`n" 
} else {
    $bpoptions = $bpoptions + @{"Standard Outlook addins" = "Default"}
}

## End Centralized deployment session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment

Write-host -ForegroundColor $processmessagecolor "Start - Security and Compliance"

write-host -foregroundcolor $processmessagecolor "Start - MFA login"
& ($publicrepo+"o365-connect-sac.ps1") -noupdate             ## Connect to Security and Compliance with MFA
write-host -foregroundcolor $processmessagecolor "Finish - MFA login`n"                             

## Check for audit log retention policy
.\o365-auditlog-retent.ps1                                      

<#  Activity Alerts #>
if ($json){                                                     ## If input file specified
    if ($options."Activity Alerts" -eq "Set"){                  ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Create standard Activity Alerts? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Activity Alerts"
    .\o365-alerts-activity-set.ps1 -nodebug                  ## Run external script that is in the current directory and don't prompt for input
    $bpoptions = $bpoptions + @{"Activity Alerts" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Activity Alerts`n" 
} else {
    $bpoptions = $bpoptions + @{"Activity Alerts" = "Default"}
}
<#  Protection Alerts   #>
if ($json){                                                     ## If input file specified
    if ($options."Protection Alerts" -eq "Set"){            ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Create standard Protection Alerts? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Protection Alerts"
    .\o365-alerts-protect-set.ps1 -nodebug                   ## Run external script that is in the current directory and don't prompt for input
    $bpoptions = $bpoptions + @{"Protection Alerts" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Protection Alerts`n" 
} else {
    $bpoptions = $bpoptions + @{"Protection Alerts" = "Default"}
}
<#  Data Loss Prevention   #>
if ($json){                                                     ## If input file specified
    if ($options."DLP Policies" -eq "Set"){                 ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Create standard DLP Policies? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - DLP Policies"
    .\o365-dlp-set.ps1                          ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"DLP Policies" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - DLP Policies`n" 
} else {
    $bpoptions = $bpoptions + @{"DLP Policies" = "Default"}
}
## End SAC online session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
Write-host -ForegroundColor $processmessagecolor "Finish - Security and Compliance"
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Write-host -ForegroundColor $processmessagecolor "Start - SharePoint Online"

write-host -foregroundcolor $processmessagecolor "Start - MFA login"
& ($publicrepo+"o365-connect-spo.ps1") -noupdate             ## Connect to Sharepoint Online
write-host -foregroundcolor $processmessagecolor "Finish - MFA login`n"                             

<#  Configure SharePoint Organizational best practices    #>
if ($json){                                                     ## If input file specified
    if ($options."SharePoint org config" -eq "Set"){    ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Configure SharePoint Organizational best practices? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - SharePoint Organizational configuration"
    .\o365-spo-orgconfig.ps1                ## Run external script that is in the current directory
    $bpoptions = $bpoptions + @{"SharePoint org config" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - SharePoint Organizational configuration`n" 
} else {
    $bpoptions = $bpoptions + @{"SharePoint org config" = "Default"}
}
<#  Set SharePoint and OneDrive idle timeout   #>
if ($json){                                                     ## If input file specified
    if ($options."Sharepoint idle timeout" -eq "Set"){      ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Set SharePoint and OneDrive idle timeout? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Set SharePoint and OneDrive idle timeout"
    Set-SPOBrowserIdleSignOut -Enabled:$true -WarnAfter (New-TimeSpan -Seconds 2700) -SignOutAfter (New-TimeSpan -Seconds 3600)
    $bpoptions = $bpoptions + @{"Sharepoint idle timeout" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Set SharePoint and OneDrive idle timeout`n" 
} else {
    $bpoptions = $bpoptions + @{"SharePoint idle timeout" = "Default"}
}

## End SharePoint online session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
Write-host -ForegroundColor $processmessagecolor "Finish - SharePoint Online"
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Write-host -ForegroundColor $processmessagecolor "Start - MS Online"

write-host -foregroundcolor $processmessagecolor "Start - MFA login"
& ($publicrepo+"o365-connect.ps1") -noupdate              ## Connect to Microsoft Online
write-host -foregroundcolor $processmessagecolor "Finish - MFA login`n"                             

<#  Block user mailbox add ins   #>
<#  Beware of these issues on iOS - https://blog.ciaops.com/2018/11/05/policy-that-prevents-you-from-granting-ios-accounts-the-permissions/ #>
if ($json){                                                     ## If input file specified
    if ($options."Block add ins" -eq "Set"){                ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Block user mailbox add ins? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Block add ins"
    set-MsolCompanysettings -UsersPermissionToUserConsentToAppEnabled $false            ## disable ability to add apps
    $bpoptions = $bpoptions + @{"Block add ins" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Block add ins`n" 
} else {
    $bpoptions = $bpoptions + @{"Block add ins" = "Default"}
}

## End MS Online session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
Write-host -ForegroundColor $processmessagecolor "Finish - MS Online"
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

Write-host -ForegroundColor $processmessagecolor "Start - Azure Information Protection"

write-host -foregroundcolor $processmessagecolor "Start - MFA login"
& ($publicrepo+"o365-connect-aip.ps1") -noupdate             ## Connect to Azure AD Rights Management
write-host -foregroundcolor $processmessagecolor "Finish - MFA login`n"                             

#  Enable Azure AD Rights Management   #>
if ($json){                                                     ## If input file specified
    if ($options."Enable rights management" -eq "Set"){                ## Check option setting
        $execute = "Y"                                          ## If option enabled
    } else {
        $execute = "N"                                          ## If option disabled
    }
} else {
    $execute=Read-Host -Prompt "Enable Azure AD Rights management? (Y/N)"  ## If input file not specified go interactive
}

if ($execute -eq 'Y' -or $execute -eq 'y') {
    write-host -foregroundcolor $processmessagecolor "Start - Enable rights management"
    $rm_enabled=get-aadrm
    if ($rm_enabled -ne "Set"){
        Enable-Aadrm
    }
    $bpoptions = $bpoptions + @{"Enable rights management" = "Set"}
    write-host -foregroundcolor $processmessagecolor "Finish - Enable rights Management`n" 
} else {
    $bpoptions = $bpoptions + @{"Enable rights management" = "Default"}
}
## End Azure AD Rights Management session
Get-PSSession | Remove-PSSession            ## Remove all sessions from environment
Write-host -ForegroundColor $processmessagecolor "Finish - Azure Rights Management"
If ($script_debug) {Read-Host -Prompt "[DEBUG] -- Press Enter to continue"}

## Save selection to JSON file
if (-not $json) {                                                     ## If interactive mode
    $execute=Read-Host -Prompt "Save options in JSON file? (Y/N)"  
    if ($execute -eq 'Y' -or $execute -eq 'y') {
        write-host -foregroundcolor $processmessagecolor "Start - Save JSON paramter file"
        if (-not (test-path $parameterfile)){                                     ## See if parameter file exists in current directory
            $bpoptions | ConvertTo-Json | add-content -path $parameterfile        ## If paramter files doesn't exist, create it
            write-host -ForegroundColor $processmessagecolor $parameterfile + " - Created"
        }
        else {                                                                      ## If parameter file does exist in current directory
            write-host -ForegroundColor $warningmessagecolor $paramterfile + " - Already exists"
            $execute = read-host "Do wish to overwrite? (Y/N)"
            if ($execute -eq 'Y' -or $execute -eq 'y') {
                clear-content -path $parameterfile                                  ## Delete existing file
                $bpoptions | ConvertTo-Json | add-content -path $parameterfile      ## Create file
            } else { 
                write-host -ForegroundColor $warningmessagecolor $parameterfile+" - Exists. No data saved"
            }
        }
        write-host -foregroundcolor $processmessagecolor "Finish - Save JSON paramter file`n" 
    }
}

write-host -foregroundcolor $systemmessagecolor "Script Complete`n"
if ($debug) {  
    Stop-Transcript | Out-Null
}

Set-Location ..

write-host -foregroundcolor $systemmessagecolor "`n`nScript Complete`n"

#----------------------------------------------------------------

Stop-Transcript
Write-Host -foregroundcolor $SystemMessageColor "`nFile $sLogFile Created"