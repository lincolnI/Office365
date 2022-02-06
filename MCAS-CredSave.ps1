<#
    .Link
    Documentation - https://github.com/directorcia/patron/wiki/Save-Microsoft-Cloud-App-Security-API-access-details
    Source - https://github.com/directorcia/patron/blob/master/mcas-creds-save.ps1

    .Description
    Accept tenant Microsoft Cloud App Security information and store it securely for later re-use

 
    .Notes
    Expected inputs are:
        1. MCAS API URI - format = https://tenantname.us.portal.cloudappsecurity.com MUST INCLUDE https:// i.e FULL web address
        2. MCAS Token - format = jhbshjbshuBSHBSyu7622HSBhiBSbh676jkJKbhbShjbhjyib7678JIBhybshjibsbsjkbskb7892789jnjkbn90mniubnkjb2JKBkbkjbk
    
    Pre-requisites
        1. Create MCAS token - https://blog.ciaops.com/2019/10/08/connecting-to-cloud-app-security-api/
    
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
$credpath = "C:\RelianceIT\PowerShell\MCAS\"   ## Local Path where credentials will be saved
$MCASUriPath = Join-Path -Path $credpath -ChildPath "$ClientName-MCASUri.xml" ## File Name and Path that will be saved
$MCASTokenPath = Join-Path -Path $credpath -ChildPath "$ClientName-MCASToken.xml" ## File Name and Path that will be saved

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

write-host -foregroundcolor $systemmessagecolor "Script started`n"
write-host -foregroundcolor $processmessagecolor "Prompt for credentials and write to file`n"

## URI is of format - https://tenantname.us.portal.cloudappsecurity.com MUST INCLUDE https:// i.e FULL web address
get-credential -credential URI | Export-CliXml  -Path $MCASUriPath     ## Any existing file will be overwritten
## Token is of format - jhbshjbshuBSHBSyu7622HSBhiBSbh676jkJKbhbShjbhjyib7678JIBhybshjibsbsjkbskb7892789jnjkbn90mniubnkjb2JKBkbkjbk
get-credential -credential Token | Export-CliXml  -Path $MCASTokenPath      ## Any existing file will be overwritten

write-host -foregroundcolor $processmessagecolor "`nRetrieve credentials`n"

$MCASUriCreds = import-clixml -path $MCASUriPath 
$MCASTokenCreds = import-clixml -path $MCASTokenPath

write-host -foregroundcolor $processmessagecolor "Decrypt credentials`n"

$MCASUri = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mcasuricreds.password))
$MCASToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mcastokencreds.password))

write-host -foregroundcolor $systemmessagecolor "*** Please verify correct credentials have been saved ***`n"

write-host -foregroundcolor $processmessagecolor "MCAS URI =", $MCASUri
write-host -foregroundcolor $processmessagecolor "MCAS Token =", $MCASToken

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------