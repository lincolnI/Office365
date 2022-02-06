## Description
## Script designed to ask whioch PowerShell Scipt you would like to run
## Create a PowerShell shortcut to this script i.e. C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoExit C:\PowerSHell\Scripts\ScriptSelector.ps1
## Can create a Tools menu to the above shortcut for quick run. https://mywindowshub.com/add-quick-launch-toolbar-windows-10/


#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$ScriptsLocation = "D:\OneDrive Data\Reliance Technology\Resources - Documents\Scripts\Office 365"
$Script = @(Get-ChildItem $ScriptsLocation | Out-GridView -Title 'Choose a file' -PassThru)
$RunScript = ".\$Script"   ## local file with credentials if required
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Run Select Script ################
#----------------------------------------------------------------
Clear-Host

write-host -foregroundcolor green "Select Script"

Set-Location $ScriptsLocation
Invoke-Expression $RunScript
#----------------------------------------------------------------