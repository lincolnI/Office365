<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Get-Tenant-Alerts
    Source - https://github.com/directorcia/patron/blob/master/graph-alerts-get.ps1

    .Description
    Report and export all current tenant alerts


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
$OutputColor = "Green"
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Application (client) ID, tenant ID and secret
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$clientidcreds = import-clixml -path ..\clientid.xml
$tenantidcreds = import-clixml -path ..\tenantid.xml
$clientsecretcreds = import-clixml -path ..\clientsec.xml

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "TenantAlerts-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}

write-host -foregroundcolor $processmessagecolor "Decrypt credentials`n"

$clientid = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientIdcreds.password))
$tenantid = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($tenantIdcreds.password))
$clientsecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientsecretcreds.password))

## If you have running scripts that don't have a certificate, run this command once to disable that level of security
## set-executionpolicy -executionpolicy bypass -scope currentuser -force

## Script from - https://www.lee-ford.co.uk/getting-started-with-microsoft-graph-with-powershell/

Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

# Azure AD OAuth Application Token for Graph API
# Get OAuth token for a AAD Application (returned as $token)

# Construct URI
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $clientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}

write-host -foregroundcolor $processmessagecolor "Get OAuth 2.0 Token"
# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

# Graph API call in PowerShell using obtained OAuth token (see other gists for more details)

# Specify the URI to call and method
$uri = "https://graph.microsoft.com/v1.0/security/alerts?`$top=999&`$orderby=eventdatetime%20desc"
$method = "GET"

write-host -foregroundcolor $processmessagecolor "Run Graph API Query"
# Run Graph API query 
$query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop 

## $query.Content

write-host -foregroundcolor $processmessagecolor "Parse results"
$ConvertedOutput = $query.content | ConvertFrom-Json
$ResultSummary = @()                 ## Results array

write-host -foregroundcolor $processmessagecolor "Display results`n"
foreach ($control in $convertedoutput.value) {
    $ResultSummary += [pscustomobject]@{        ## Build array item
        Title       = $control.title
        Time        = $control.eventdatetime
        Source      = $control.vendorinformation.provider
        Description = $control.description
    }  
}

$ResultSummary | Format-Table

## write results to CSV file in parent
$resultSummary | export-csv $ResultsFile -NoTypeInformation -Append  

write-host -foregroundcolor $SystemMessageColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------