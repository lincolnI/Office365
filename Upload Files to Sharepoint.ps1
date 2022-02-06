New-Item -ItemType Directory -Force -Path C:\RelianceIT\Temp *>$null
Remove-Item C:\RelianceIT\Temp\Users.csv *>$null
Remove-Item C:\RelianceIT\Temp\Users1.csv *>$null

Clear-Host

if (!(Get-Module -ListAvailable -Name SharePointPnPPowerShellOnline)){
	Write-Host "Installing SharePointPnPPowerShellOnline Module" -ForegroundColor Green
    Install-Module SharePointPnPPowerShellOnline -Force
} 

if (!(Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)){
	Write-Host "Installing Microsoft.Online.SharePoint.PowerShell Module" -ForegroundColor Green
	Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
	#Install-Module -Name SharePoint-Online -Force
} 

if (!(Get-Module -ListAvailable -Name AzureAD)){
	Write-Host "Installing AzureAD Module" -ForegroundColor Green
    install-module AzureAD -Force
} 

Clear-Host


Write-Host "Gathering Variables" -ForegroundColor Green
if (!($SetupO365User)){
		Add-Type -AssemblyName System.Windows.Forms
		Add-Type -AssemblyName System.Drawing

		$form = New-Object System.Windows.Forms.Form
		$form.Text = 'Data Entry Form'
		$form.Size = New-Object System.Drawing.Size(300,200)
		$form.StartPosition = 'CenterScreen'

		$OKButton = New-Object System.Windows.Forms.Button
		$OKButton.Location = New-Object System.Drawing.Point(75,120)
		$OKButton.Size = New-Object System.Drawing.Size(75,23)
		$OKButton.Text = 'OK'
		$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
		$form.AcceptButton = $OKButton
		$form.Controls.Add($OKButton)

		$CancelButton = New-Object System.Windows.Forms.Button
		$CancelButton.Location = New-Object System.Drawing.Point(150,120)
		$CancelButton.Size = New-Object System.Drawing.Size(75,23)
		$CancelButton.Text = 'Cancel'
		$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
		$form.CancelButton = $CancelButton
		$form.Controls.Add($CancelButton)

		$label = New-Object System.Windows.Forms.Label
		$label.Location = New-Object System.Drawing.Point(10,20)
		$label.Size = New-Object System.Drawing.Size(280,20)
		$label.Text = 'Setup Office365 Username:'
		$form.Controls.Add($label)

		$textBox = New-Object System.Windows.Forms.TextBox
		$textBox.Location = New-Object System.Drawing.Point(10,40)
		$textBox.Size = New-Object System.Drawing.Size(260,20)
		$form.Controls.Add($textBox)

		$form.Topmost = $true

		$form.Add_Shown({$textBox.Select()})
		$result = $form.ShowDialog()

		if ($result -eq [System.Windows.Forms.DialogResult]::OK)
		{
			$SetupO365User = $textBox.Text
		}
}

if (!($SharePointAdminURL)){
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = 'Data Entry Form'
	$form.Size = New-Object System.Drawing.Size(300,200)
	$form.StartPosition = 'CenterScreen'

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(75,120)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = 'OK'
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $OKButton
	$form.Controls.Add($OKButton)

	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(150,120)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = 'Cancel'
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $CancelButton
	$form.Controls.Add($CancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,20)
	$label.Size = New-Object System.Drawing.Size(280,40)
	$label.Text = 'Enter the entire admin Sharepoint url (e.g. https://billybloggs-admin.sharepoint.com): '
	$form.Controls.Add($label)

	$textBox = New-Object System.Windows.Forms.TextBox
	$textBox.Location = New-Object System.Drawing.Point(10,70)
	$textBox.Size = New-Object System.Drawing.Size(260,20)
	$form.Controls.Add($textBox)

	$form.Topmost = $true

	$form.Add_Shown({$textBox.Select()})
	$result = $form.ShowDialog()

	if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
		$SharePointAdminURL = $textBox.Text
	}
}


Connect-SPOService -Url $SharePointAdminURL


Write-Host "Admin User: $SetupO365User" -ForegroundColor Green
Write-Host "SharePoint URL: $SharePointAdminURL" -ForegroundColor Green

# Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM  
# Download SharePoint Online Client Components SDK if missing
# https://download.microsoft.com/download/B/3/D/B3DA6839-B852-41B3-A9DF-0AFA926242F2/sharepointclientcomponents_16-6906-1200_x64-en-us.msi
if (!(test-path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"))
{
Throw "Sharepoint Web Extensions not present. Download SharePoint Online Client Components SDK if missing, https://download.microsoft.com/download/B/3/D/B3DA6839-B852-41B3-A9DF-0AFA926242F2/sharepointclientcomponents_16-6906-1200_x64-en-us.msi"
}

if (!(test-path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"))
{
Throw "Sharepoint Web Extensions not present. Download SharePoint Online Client Components SDK if missing, https://download.microsoft.com/download/B/3/D/B3DA6839-B852-41B3-A9DF-0AFA926242F2/sharepointclientcomponents_16-6906-1200_x64-en-us.msi"
}

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -path 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll'
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -path 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll'

Clear-Host

$Creds = Get-Credential

Write-Host "Connecting to PNP Online" -ForegroundColor Green
Connect-PnPOnline -Url $SharePointAdminURL -Credentials $Creds
Write-Host "Connecting to AzureAD" -ForegroundColor Green
Connect-AzureAD -Credential $Creds
Write-Host "Connecting to SPO" -ForegroundColor Green
Connect-SPOService -Url $SharePointAdminURL

Clear-Host

#Get all users Onedrive Directories
Write-Host "Getting a list of all Azure licensed users" -ForegroundColor Green
$Users = Get-AzureADUser -All $True | Where {$_.UserType -eq 'Member' -and $_.AssignedLicenses -ne $null}

#Setup Onedrive for any users that don't have it
#Write-Host "Setting up OneDrive for any users who dont have it" -ForegroundColor Green
#foreach ($user in $Users) 
#{
#	Request-SPOPersonalSite -UserEmails $user.UserPrincipalName
#}

Clear-Host

#Create H Drive Targets
Write-Host "Getting a list of all active users who have Home Drives" -ForegroundColor Green
Get-ADUser -Filter {(enabled -eq $true) -And (HomeDrive -ne "$Null")} -Properties HomeDirectory, HomeDrive, UserPrincipalName | Select UserPrincipalName, HomeDirectory, SharePointURL | Export-Csv "C:\RelianceIT\Temp\Users.csv"


$csv = Import-Csv "C:\RelianceIT\Temp\Users.csv"
foreach ($line in $csv) {
	$PrivateURL = Get-PnPUserProfileProperty -Account $line.UserPrincipalName -ErrorAction SilentlyContinue
	Write-Host "$PrivateURL"
	$line.SharePointURL = $PrivateURL.PersonalUrl
}
$csv | Export-Csv "C:\RelianceIT\Temp\Users1.csv"

Write-Host "Please see C:\RelianceIT\Temp\Users1.csv, this will be the target list for users Home Drives to be Migrated" -ForegroundColor Yellow
Write-Host "Remove any lines that you do not want to be migrated" -ForegroundColor Yellow
Write-Host "If you do not want some users in this list to be migrated remove their line from this list" -ForegroundColor Yellow
Write-Host "Press any key when ready to proceed" -ForegroundColor Yellow
[void][System.Console]::ReadKey($FALSE)


#Start Migration of H Drive
Clear-Host

$csv = Import-Csv "C:\RelianceIT\Temp\Users1.csv"
foreach ($line in $csv) {
	Write-Host $line.UserPrincipalName -ForegroundColor Green
	Write-Host $line.HomeDirectory -ForegroundColor Green
	Write-Host $line.SharePointURL -ForegroundColor Green
	
	#Grant $SetupO365User Admin Access to users SharePoint
	Write-Host "Granting Admin Access"  -ForegroundColor Green
	Set-SPOUser -Site $line.SharePointURL -LoginName $SetupO365User -IsSiteCollectionAdmin $true
	
	#Connect to personal Sharepoint
	Write-Host "Connecting to Personal Sharepoint $line.SharePointURL"  -ForegroundColor Green
	Connect-PnPOnline -Url $line.SharePointURL -Credentials $Creds
	
	#Create Folders
	Write-Host "Creating Root Folders"  -ForegroundColor Green
	$RootFolder = Add-PnPFolder -Name "My Documents" -Folder "Documents"
	Sleep 5
	$SubFolder = Add-PnPFolder -Name "My Documents\HomeFolder" -Folder "Documents"
	
	$Path = $line.HomeDirectory + '\'
	$FolderStructure = @()
	$FolderStructure += Get-ChildItem -Directory -Path "$Path" -Recurse -Force -Name | sort-object

	foreach ($Folder in $FolderStructure) {
		$folderlevel = "My Documents\HomeFolder\" + $Folder
		 -ForegroundColor Green
		$folder = Add-PnPFolder -Name $folderlevel -Folder "Documents"
	}	
	
	#Create Files
	$Path = $line.HomeDirectory + '\'
	$FileStructure = @()
	$FileStructure += Get-ChildItem -File -Path "$Path" -Recurse -Force -Name | sort-object

	foreach ($File in $FileStructure) {
	$filelevel = "Documents\My Documents\HomeFolder\" + $File | split-path
	$fullpath = $line.HomeDirectory + '\' + $File
	$file = Add-PnPFile -Path $fullpath -Folder $filelevel -Values @{Editor=$line.UserPrincipalName}
	}}