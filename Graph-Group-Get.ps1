<#
    .Link
    Source - https://github.com/directorcia/patron/blob/master/graph-groups-get.ps1
    Documentation - https://github.com/directorcia/patron/wiki/Get-Office-365-Group-list-via-Graph

    .Description
    Get a list of Office Groups and parameters and display on screen

    .INPUTS
    Expected inputs are:
        1. Application ID - via encrypted file ..\clientid.xml
        2. Tenant ID - via encrypted file ..\tenantid.xml
        3. Client Secret - via encrypted file ..\clientsec.xml
 
    .Notes
    Prerequisites = 2
        1. Azure AD app setup per - https://blog.ciaops.com/2019/04/17/using-interactive-powershell-to-access-the-microsoft-graph/
        2. Saved graph credebntials using - https://github.com/directorcia/patron/blob/master/graph-creds-save.ps1


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
$ClientName = Read-Host -Prompt 'What Tenent is this for (Must already have saved using Graph-CredSave.ps1)' ## Prompt For file Name

$credpath = "C:\RelianceIT\PowerShell\Graph\"   ## Local Path where credentials will be saved
$ClientIDPath = Join-Path -Path $credpath -ChildPath "$ClientName-ClientID.xml" ## File Name and Path that will be saved
$TenantIDPath = Join-Path -Path $credpath -ChildPath "$ClientName-TenantID.xml" ## File Name and Path that will be saved
$ClientSecPath = Join-Path -Path $credpath -ChildPath "$ClientName-ClientSec.xml" ## File Name and Path that will be saved

write-host -foregroundcolor $processmessagecolor "`nRetrieve credentials`n"

$ClientIDCreds = import-clixml -path $ClientIDPath
$TenantIDCreds = import-clixml -path $TenantIDPath
$ClientSecretCreds = import-clixml -path $ClientSecPath

write-host -foregroundcolor $processmessagecolor "Decrypt credentials`n"

$ClientID = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientIdcreds.password))
$TenantID = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($tenantIdcreds.password))
$ClientSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientsecretcreds.password))

#----------------------------------------------------------------

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------

Clear-Host

## start-transcript "..\o365-ssdescpt-get $(get-date -f yyyyMMddHHmmss).txt"

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


## Script from - https://www.lee-ford.co.uk/getting-started-with-microsoft-graph-with-powershell/

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
$uri = "https://graph.microsoft.com/v1.0/groups?`$top=999"      # return max 999 results in one queyr page
$method = "GET"

write-host -foregroundcolor $processmessagecolor "Run Graph API Query"
# Run Graph API query 
$query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token" } -ErrorAction Stop 

write-host -foregroundcolor $processmessagecolor "Parse results"
$ConvertedOutput = $query.content | ConvertFrom-Json
$ResultSummary = @()                 ## Results array

write-host -foregroundcolor $processmessagecolor "Display results`n"
foreach ($control in $convertedoutput.value) {
    $ResultSummary += [pscustomobject]@{        ## Build array item
        Displayname = $control.displayname
        Mail        = $control.mail
        Visibility  = $control.visibility
        Id          = $control.id
    }  
}

$ResultSummary | Format-Table

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------