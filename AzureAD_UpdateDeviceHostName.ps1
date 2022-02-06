# Script to update device hostname in Azure AD

# Prompts for credentials and connects to Azure AD
$credential = Get-Credential
Connect-AzureAD -Credential $credential

# Function for main menu of script
function MainMenu
{
    # Displays list of display names for all devices joined to Azure AD
    Clear-Host
    Get-AzureADDevice | Select-Object DisplayName
    UpdateDeviceHostName
}

# Function to prompt for hostname and update in AzureAD
function UpdateDeviceHostName
{
    # Asks for user input for the old and new hostnames of the device to update
    $olddevicehostname = Read-Host 'Old hostname'
    $newdevicehostname = Read-Host 'New hostname'

    # Sets hostname of device to the new host name provided
    Set-AzureADDevice -ObjectId $olddevicehostname -DisplayName $newdevicehostname

    # Return to main menu
    MainMenu
}

# Start of script
MainMenu