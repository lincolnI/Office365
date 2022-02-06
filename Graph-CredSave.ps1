<#
    .Link
    https://github.com/directorcia/patron/blob/master/graph-creds-save.ps1
    https://github.com/directorcia/patron/wiki/Save-tenant-OAuth-credentials

    .Description
    Accept tenant OAuth information and store it securely for later re-use

 
    .Notes
    Expected inputs are:
        1. ClientID
        2. TenantID
        3. ClientSecret
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml?view=powershell-6
    The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API. 
    The encryption ensures that only your user account on only that computer can decrypt the contents of the credential object. 
    The exported CLIXML file can't be used on a different computer or by a different user.


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
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for' ## Prompt For file Name
$credpath = "C:\RelianceIT\PowerShell\Graph\"   ## Local Path where credentials will be saved
$ClientIDPath = Join-Path -Path $credpath -ChildPath "$ClientName-ClientID.xml" ## File Name and Path that will be saved
$TenantIDPath = Join-Path -Path $credpath -ChildPath "$ClientName-TenantID.xml" ## File Name and Path that will be saved
$ClientSecPath = Join-Path -Path $credpath -ChildPath "$ClientName-ClientSec.xml" ## File Name and Path that will be saved

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Save creds to local file ################
#----------------------------------------------------------------

<# 

write-host -foregroundcolor green "File $XMLPath Created"

$Input = Read-Host 'Would you like to run another script (Y/N)'
    If ($Input -eq 'y')
    {
        Clear-Host
        C:\RelianceIT\Scripts\ScriptSelector.ps1
    }

#>

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $credpath)) {
    New-Item -ItemType Directory -Path $credpath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $credpath`n"
}

write-host -foregroundcolor $processmessagecolor "Prompt for credentials and write to file`n"

get-credential -credential ClientID | Export-CliXml  -Path $ClientIDPath      ## Any existing file will be overwritten
get-credential -credential TenantID | Export-CliXml  -Path $TenantIDPath      ## Any existing file will be overwritten
get-credential -credential ClientSecret | Export-CliXml  -Path $ClientSecPath ## Any existing file will be overwritten

write-host -foregroundcolor $processmessagecolor "`nRetrieve credentials`n"

$ClientIDCreds = import-clixml -path $ClientIDPath
$TenantIDCreds = import-clixml -path $TenantIDPath
$ClientSecretCreds = import-clixml -path $ClientSecPath

write-host -foregroundcolor $processmessagecolor "Decrypt credentials`n"

$ClientID = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientIdcreds.password))
$TenantID = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($tenantIdcreds.password))
$ClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientsecretcreds.password))

write-host -foregroundcolor $systemmessagecolor "*** Please verify correct credentials have been saved ***`n"

write-host -foregroundcolor $processmessagecolor "ClientID =",$clientid
write-host -foregroundcolor $processmessagecolor "TenantID =", $tenantid
write-host -foregroundcolor $processmessagecolor "ClientSecret =", $clientsecret

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------