<#
    .Link
    Source - https://github.com/directorcia/Office365/blob/master/c.ps1

    .EXAMPLE
    Run from GIT:
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Script = Invoke-RestMethod https://api.github.com/repos/CalebReliance/InternalScripts/contents/Setup-System.ps1?access_token=1cf973fc3d5580cbadc39f44e9515c1e02cda65f -Headers @{”Accept”= “application/vnd.github.v3.raw”}
    Invoke-Expression $Script

    .Description
    Ask users what services they would like to connect to.

 
    .Notes
    Prerequisites = 1
        1. All required Patron scripts MUST be in the same directory as this script, so make sure you are in that directory before running this

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
$OutputColor = "Green"
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$version = "2.00"
$ScriptRepo = ".\CIAOPS\"                   ## Location on disk of free scripts repository


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

write-host -foregroundcolor $SystemMessageColor "Script Started"

Set-Location $ScriptRepo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Starts here
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    write-host -foregroundcolor $systemmessagecolor "Script started. Version = $version`n"
    write-host "--- Script to connect to cloud services ---`n"

    $scripts = @()
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-tms.ps1";
        Service = "Teams";
        Module = "MicrosoftTeams"    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-spo.ps1";
        Service = "SharePoint"; 
        Module = "Microsoft.Online.SharePoint.PowerShell"   
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-sac.ps1";
        Service = "Security and Compliance";
        Module = "MSOnline"    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-s4b.ps1";
        Service = "Skype for Business/CSTeams";
        Module = "skypeonlineconnector"
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-exov2.ps1";
        Service = "Exchange Online";
        Module ="ExchangeOnlineManagement"    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-ctldply.ps1";
        Service = "Central Add-in deployment";
        Module = "";    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-aadrm.ps1";
        Service = "Azure AD Rights Management";
        Module = "AADRM"    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa-aad.ps1";
        Service = "Azure AD";
        Module = "AzureAD"    
    }
    $scripts += [PSCustomObject]@{
        Name = "o365-connect-mfa.ps1";
        Service = "MS Online";  
        Module = "MSOnline"  
    }
    $scripts += [PSCustomObject]@{
        Name = "Az-connect.ps1";
        Service = "Azure";  
        Module = "Az.Accounts"  
    }

    try {
        $results = $scripts | select-object service | Sort-Object Service | Out-GridView -PassThru -title "Select services to connect to (Multiple selections permitted) "
    }
    catch {
        write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "`n[001] - Error getting options`n"
        Stop-Transcript | Out-Null      ## Terminate transcription
        exit 1                          ## Terminate script
    }

    foreach ($result in $results) {
        foreach ($script in $scripts) {
            if ($result.service -eq $script.service) {
                $run=".\"+$script.Name
                if (-not [string]::isnullorempty($script.module)) {             ## If a PowerShell module is required to be installed?
                    if (get-module -listavailable -name $script.module) {       ## Has the Online PowerShell module been loaded?
                        write-host -ForegroundColor $processmessagecolor $script.module,"module found"
                    }
                    else {
                        write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "`n[002] - Online PowerShell module",$script.module,"not installed. Please install and re-run script`n"
                        Stop-Transcript | Out-Null      ## Terminate transcription
                        exit 2                          ## Terminate script
                    }
                }
                <# Test for script in current location #>
                if (-not (test-path -path $run)) {
                    write-host -ForegroundColor yellow -backgroundcolor $errormessagecolor "`n[003] -",$script.name,"script not found in current directory - Please ensure exists first`n"
                    Stop-Transcript | Out-Null      ## Terminate transcription
                    exit 3                          ## Terminate script
                }
                else {
                    write-host -ForegroundColor $processmessagecolor $script.name,"script found in current directory`n"
                }
                &$run           ## Run script
            }
        }
    }

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set-Location ..

write-host -foregroundcolor $systemmessagecolor "`nScript finished`n"

#----------------------------------------------------------------