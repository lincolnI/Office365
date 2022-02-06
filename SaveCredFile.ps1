## Description
## Script designed save login credentials to a local XML file for later re-use

## Prerequisites = 0

Clear-Host

write-host -foregroundcolor green "Script started"

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$FileName = Read-Host -Prompt 'What Tenent is this for' ## Prompt For file Name
$credpath = "C:\RelianceIT\PowerShell\"   ## Local Path where credentials will be saved
$XMLPath = Join-Path -Path $credpath -ChildPath "$FileName.xml" ## File Name and Path that will be saved
$psd
#----------------------------------------------------------------

## HARD CODE FILE NAME ##
### $credpath = "C:\RelianceIT\PowerShell\tenant.xml"   ## local file with credentials

#----------------------------------------------------------------
################# Save creds to local file ################
#----------------------------------------------------------------
Get-Credential | Export-CliXml -Path $XMLPath

write-host -foregroundcolor green "File $XMLPath Created"

$Input = Read-Host 'Would you like to run another script (Y/N)'
    If ($Input -eq 'y')
    {
        Clear-Host
        C:\RelianceIT\Scripts\ScriptSelector.ps1
    }
#----------------------------------------------------------------