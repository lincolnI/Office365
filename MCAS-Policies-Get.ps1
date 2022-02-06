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
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MCAS Policies-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.txt"      ## Location of export file


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

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}

Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

$endpoint = "policies"                  ## List policies

$response = Invoke-RestMethod `
    -uri "$mcasuri/api/v1/$endpoint/" `
    -headers @{authorization = "Token $mcastoken" } `
    -method GET `

## $response.data
$fields = $response.data

## display results on screen
$fields | sort name | format-table -autosize Name, Enablealerts, Enabled, Alertemailrecipients 
Write-host "Total policies = ", $fields.count

## write results to text file in parent

$fields | sort name | format-table -autosize Name, Enablealerts, Enabled, Alertemailrecipients | out-file $ResultsFile
"Total policies = ",$fields.count | out-file -append $ResultsFile

#$fields | select-object Name, Enablealerts, Enabled, Alertemailrecipients | Export-Csv path $ResultsFile -NoTypeInformation 
#"Total policies = ",$fields.count | Export-Csv -append $ResultsFile
#Export-Csv -notypeinformation -Path $resultsfile

write-host -foregroundcolor $SystemMessageColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------