<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Dismiss-Microsoft-Cloud-App-Security-Alerts
    Source - https://github.com/directorcia/patron/blob/master/mcas-alerts-bulkdismiss.ps1

    .Description
    Bulk dismiss Microsoft Cloud App Security Alerts

    .INPUTS
    Expected inputs are:
        1. MCAS API URI - via encrypted file ..\mcas-uri.xml
        2. MCAS Token - via encrypted file ..\mcas-token.xml
 
    .Notes
    Pre-requisites
        1. Create MCAS token - https://blog.ciaops.com/2019/10/08/connecting-to-cloud-app-security-api/
        2. Save MCAS token details via script - https://github.com/directorcia/patron/blob/master/mcas-creds-save.ps1

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
# Import Credetials
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Application (client) ID, tenant ID and secret
$ClientName = Read-Host -Prompt "`nWhat Tenent is this for (Must already have saved using MCAS-CredSave.ps1)" ## Prompt For file Name
$CredPath = "C:\RelianceIT\PowerShell\MCAS\"   ## Local Path where credentials are saved using MCAS-CredSave.ps1
$MCASUriPath = Join-Path -Path $credpath -ChildPath "$ClientName-MCASUri.xml" ## File Name and Path that will be saved
$MCASTokenPath = Join-Path -Path $credpath -ChildPath "$ClientName-MCASToken.xml" ## File Name and Path that will be saved

write-host -foregroundcolor $processmessagecolor "`nRetrieve credentials`n"

$MCASUriCreds = import-clixml -path $MCASUriPath 
$MCASTokenCreds = import-clixml -path $MCASTokenPath

write-host -foregroundcolor $processmessagecolor "Decrypt credentials`n"

$MCASUri = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mcasuricreds.password))
$MCASToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mcastokencreds.password))

#----------------------------------------------------------------

#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

$endpoint = "alerts/dismiss_bulk"        ## Dismiss alerts

$body = @{                          ## alert filters
    limit         = 1000            # Number of alerts returned through the request
    sortdirection = "asc"           # "asc" or "dsc"
    sortfield     = date            # Fields used to sort alerts. Possible values are: date - The date when the alert was created, severity - Alert severity
    skip          = 0               # Skips this number of records
}

write-host -foregroundcolor $processmessagecolor "Dimissing Alerts`n"

$response = Invoke-RestMethod `
    -uri "$mcasuri/api/v1/$endpoint/" `
    -headers @{authorization = "Token $mcastoken" } `
    -method POST `
    -body ($body | convertto-json -depth 2) `
    -verbose

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------