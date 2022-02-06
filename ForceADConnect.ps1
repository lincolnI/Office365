#https://blogs.technet.microsoft.com/nawar/2016/02/25/forcing-synchronization-with-azure-ad-connect-1-1-aad-connect-1-1/
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned


#----------------------------------------------------------------
################# Function to choose sync option ################
#----------------------------------------------------------------
function ADSyncMenu
{
    param
    (
        [string]$ADSyncMenuTitle = 'ADSync'
    )

    Clear-Host
    Write-Host '================' $ADSyncMenuTitle '================'
    Write-Host '1: Start Standard Sync (Delta)'
    Write-Host '2: Force FULL Sync (Initial)'
    Write-Host 'q: Quit'

    $Input = Read-Host 'Please select an option'
    If ($Input -eq '1')
    {
        DeltaSyncMenu
    }
    ElseIf ($Input -eq '2')
    {
        FullSyncMenu
    }
    ElseIf ($Input -eq 'q')
    {
        Exit
    }
    Else
    {
        Write-Host 'Invalid selection'
        ADSyncMenu
    }
}

#----------------------------------------------------------------
################# Function to run Delta Sync ################
#----------------------------------------------------------------
function DeltaSyncMenu
{
    Clear-Host
    write-host -foregroundcolor green "Standard Sync in Process"
    Start-ADSyncSyncCycle -PolicyType Delta
    $Input = Read-Host 'Would you like to run the sync again (Y\N)?'
    If ($Input -eq 'y')
    {
        DeltaSyncMenu
    }
    ElseIf ($Input -eq 'n')
    {
        ADSyncMenu
    }
    Else
    {
        Write-Host 'Invalid selection'
        DeltaSyncMenu
    }
}

#----------------------------------------------------------------
################# Function to run Full sync ################
#----------------------------------------------------------------
function FullSyncMenu
{
    Clear-Host
    write-host -foregroundcolor green "Full Sync in Process"
    Start-ADSyncSyncCycle -PolicyType Initial
    $Input = Read-Host 'Would you like to run the sync again (Y\N)?'
    If ($Input -eq 'y')
    {
        FullSyncMenu
    }
    ElseIf ($Input -eq 'n')
    {
        ADSyncMenu
    }
    Else
    {
        Write-Host 'Invalid selection'
        FullSyncMenu
    }
}

#----------------------------------------------------------------
################# Start of program ################
#----------------------------------------------------------------
Clear-Host
Import-Module ADSync
ADSyncMenu