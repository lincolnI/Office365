# Source: https://www.thelazyadministrator.com/2018/03/19/get-friendly-license-name-for-all-users-in-office-365-using-powershell/

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessmessageColor = "Green"
$OutputColor = "Green"
$InfoColorv2 = "White"
$InfoColor = "Yellow"
$ErrorColor = "Red"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "LicencedUsers-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 365 SKU List
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Sku = @{
	"O365_BUSINESS_ESSENTIALS"			     = "Microsoft 365 Business Basic"
	"SMB_BUSINESS_PREMIUM"			     	 = "Microsoft 365 Business Standard"
	"O365_BUSINESS_PREMIUM"				     = "Microsoft 365 Business Standard"
	"DESKLESSPACK"						     = "Office 365 (Plan K1)"
	"DESKLESSWOFFPACK"					     = "Office 365 (Plan K2)"
	"LITEPACK"							     = "Office 365 (Plan P1)"
	"EXCHANGESTANDARD"					     = "Office 365 Exchange Online Only"
	"STANDARDPACK"						     = "Enterprise Plan E1"
	"STANDARDWOFFPACK"					     = "Office 365 (Plan E2)"
	"ENTERPRISEPACK"						 = "Enterprise Plan E3"
	"ENTERPRISEPACKLRG"					     = "Enterprise Plan E3"
	"ENTERPRISEWITHSCAL"					 = "Enterprise Plan E4"
	"STANDARDPACK_STUDENT"				     = "Office 365 (Plan A1) for Students"
	"STANDARDWOFFPACKPACK_STUDENT"		     = "Office 365 (Plan A2) for Students"
	"ENTERPRISEPACK_STUDENT"				 = "Office 365 (Plan A3) for Students"
	"ENTERPRISEWITHSCAL_STUDENT"			 = "Office 365 (Plan A4) for Students"
	"STANDARDPACK_FACULTY"				     = "Office 365 (Plan A1) for Faculty"
	"STANDARDWOFFPACKPACK_FACULTY"		     = "Office 365 (Plan A2) for Faculty"
	"ENTERPRISEPACK_FACULTY"				 = "Office 365 (Plan A3) for Faculty"
	"ENTERPRISEWITHSCAL_FACULTY"			 = "Office 365 (Plan A4) for Faculty"
	"OFFICESUBSCRIPTION_FACULTY"			 = "Office 365 ProPlus for faculty"
	"ENTERPRISEPACK_B_PILOT"				 = "Office 365 (Enterprise Preview)"
	"STANDARD_B_PILOT"					     = "Office 365 (Small Business Preview)"
	"VISIOCLIENT"						     = "Visio Pro Online"
	"POWER_BI_ADDON"						 = "Office 365 Power BI Addon"
	"POWER_BI_INDIVIDUAL_USE"			     = "Power BI Individual User"
	"POWER_BI_STANDALONE"				     = "Power BI Stand Alone"
	"POWER_BI_STANDARD"					     = "Power-BI Standard"
	"POWERAPPS_VIRAL"					     = "Microsoft PowerApps Plan 2"
	"PROJECTESSENTIALS"					     = "Project Lite"
	"PROJECTCLIENT"						     = "Project Professional"
	"PROJECTONLINE_PLAN_1"				     = "Project Online"
	"PROJECTONLINE_PLAN_2"				     = "Project Online and PRO"
	"ProjectPremium"						 = "Project Online Premium"
	"ECAL_SERVICES"						     = "ECAL"
	"EMS"								     = "Enterprise Mobility Suite"
	"EMSPREMIUM"							 = "Enterprise Mobility & Security Suite E5"
	"RIGHTSMANAGEMENT_ADHOC"				 = "Windows Azure Rights Management"
	"MCOMEETADV"							 = "PSTN conferencing"
	"SHAREPOINTSTORAGE"					     = "SharePoint storage"
	"PLANNERSTANDALONE"					     = "Planner Standalone"
	"CRMIUR"								 = "CMRIUR"
	"BI_AZURE_P1"						     = "Power BI Reporting and Analytics"
	"INTUNE_A"							     = "Windows Intune Plan A"
	"PROJECTWORKMANAGEMENT"				     = "Office 365 Planner Preview"
	"ATP_ENTERPRISE"						 = "Exchange Online Advanced Threat Protection"
	"EQUIVIO_ANALYTICS"					     = "Office 365 Advanced eDiscovery"
	"AAD_BASIC"							     = "Azure Active Directory Basic"
	"RMS_S_ENTERPRISE"					     = "Azure Active Directory Rights Management"
	"AAD_PREMIUM"						     = "Azure Active Directory Premium"
	"AAD_PREMIUM_P2"						 = "Azure Active Directory Premium Plan 2"
	"MFA_PREMIUM"						     = "Azure Multi-Factor Authentication"
	"STANDARDPACK_GOV"					     = "Microsoft Office 365 (Plan G1) for Government"
	"STANDARDWOFFPACK_GOV"				     = "Microsoft Office 365 (Plan G2) for Government"
	"ENTERPRISEPACK_GOV"					 = "Microsoft Office 365 (Plan G3) for Government"
	"ENTERPRISEWITHSCAL_GOV"				 = "Microsoft Office 365 (Plan G4) for Government"
	"DESKLESSPACK_GOV"					     = "Microsoft Office 365 (Plan K1) for Government"
	"ESKLESSWOFFPACK_GOV"				     = "Microsoft Office 365 (Plan K2) for Government"
	"EXCHANGESTANDARD_GOV"				     = "Microsoft Office 365 Exchange Online (Plan 1) only for Government"
	"EXCHANGEENTERPRISE_GOV"				 = "Microsoft Office 365 Exchange Online (Plan 2) only for Government"
	"SHAREPOINTDESKLESS_GOV"				 = "SharePoint Online Kiosk"
	"EXCHANGE_S_DESKLESS_GOV"			     = "Exchange Kiosk"
	"RMS_S_ENTERPRISE_GOV"				     = "Windows Azure Active Directory Rights Management"
	"OFFICESUBSCRIPTION_GOV"				 = "Office ProPlus"
	"MCOSTANDARD_GOV"					     = "Lync Plan 2G"
	"SHAREPOINTWAC_GOV"					     = "Office Online for Government"
	"SHAREPOINTENTERPRISE_GOV"			     = "SharePoint Plan 2G"
	"EXCHANGE_S_ENTERPRISE_GOV"			     = "Exchange Plan 2G"
	"EXCHANGE_S_ARCHIVE_ADDON_GOV"		     = "Exchange Online Archiving"
	"EXCHANGE_S_DESKLESS"				     = "Exchange Online Kiosk"
	"SHAREPOINTDESKLESS"					 = "SharePoint Online Kiosk"
	"SHAREPOINTWAC"						     = "Office Online"
	"YAMMER_ENTERPRISE"					     = "Yammer for the Starship Enterprise"
	"EXCHANGE_L_STANDARD"				     = "Exchange Online (Plan 1)"
	"MCOLITE"							     = "Lync Online (Plan 1)"
	"SHAREPOINTLITE"						 = "SharePoint Online (Plan 1)"
	"OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ"	 = "Office ProPlus"
	"EXCHANGE_S_STANDARD_MIDMARKET"		     = "Exchange Online (Plan 1)"
	"MCOSTANDARD_MIDMARKET"				     = "Lync Online (Plan 1)"
	"SHAREPOINTENTERPRISE_MIDMARKET"		 = "SharePoint Online (Plan 1)"
	"OFFICESUBSCRIPTION"					 = "Office ProPlus"
	"YAMMER_MIDSIZE"						 = "Yammer"
	"DYN365_ENTERPRISE_PLAN1"			     = "Dynamics 365 Customer Engagement Plan Enterprise Edition"
	"ENTERPRISEPREMIUM_NOPSTNCONF"		     = "Enterprise E5 (without Audio Conferencing)"
	"ENTERPRISEPREMIUM"					     = "Enterprise E5 (with Audio Conferencing)"
	"MCOSTANDARD"						     = "Skype for Business Online Standalone Plan 2"
	"PROJECT_MADEIRA_PREVIEW_IW_SKU"		 = "Dynamics 365 for Financials for IWs"
	"STANDARDWOFFPACK_IW_STUDENT"		     = "Office 365 Education for Students"
	"STANDARDWOFFPACK_IW_FACULTY"		     = "Office 365 Education for Faculty"
	"EOP_ENTERPRISE_FACULTY"				 = "Exchange Online Protection for Faculty"
	"EOP_ENTERPRISE_PREMIUM_FACULTY"		 = "Exchange Enterprise Online Protection for Faculty"
	"EXCHANGESTANDARD_STUDENT"			     = "Exchange Online (Plan 1) for Students"
	"OFFICESUBSCRIPTION_STUDENT"			 = "Office ProPlus Student Benefit"
	"STANDARDWOFFPACK_FACULTY"			     = "Office 365 Education E1 for Faculty"
	"STANDARDWOFFPACK_STUDENT"			     = "Microsoft Office 365 (Plan A2) for Students"
	"DYN365_FINANCIALS_BUSINESS_SKU"		 = "Dynamics 365 for Financials Business Edition"
	"DYN365_FINANCIALS_TEAM_MEMBERS_SKU"	 = "Dynamics 365 for Team Members Business Edition"
	"DYN365_BUSCENTRAL_ESSENTIAL"			 = "Dynamics 365 Business Central Essential"
	"M365EDU_A5_FACULTY"	 				 = "Microsoft 365 A5 for faculty"
	"FLOW_FREE"							     = "Microsoft Flow Free"
	"POWER_BI_PRO"						     = "Power BI Pro"
	"O365_BUSINESS"						     = "Microsoft 365 Apps for Business"
	"DYN365_ENTERPRISE_SALES"			     = "Dynamics Office 365 Enterprise Sales"
	"RIGHTSMANAGEMENT"					     = "Rights Management"
	"PROJECTPROFESSIONAL"				     = "Project Professional"
	"VISIOONLINE_PLAN1"					     = "Visio Online Plan 1"
	"EXCHANGEENTERPRISE"					 = "Exchange Online Plan 2"
	"DYN365_ENTERPRISE_P1_IW"			     = "Dynamics 365 P1 Trial for Information Workers"
	"DYN365_ENTERPRISE_TEAM_MEMBERS"		 = "Dynamics 365 For Team Members Enterprise Edition"
	"CRMSTANDARD"						     = "Microsoft Dynamics CRM Online Professional"
	"EXCHANGEARCHIVE_ADDON"				     = "Exchange Online Archiving For Exchange Online"
	"EXCHANGEDESKLESS"					     = "Exchange Online Kiosk"
	"SPZA_IW"							     = "App Connect"
	"WINDOWS_STORE"						     = "Windows Store for Business"
	"MCOEV"								     = "Microsoft Phone System"
	"VIDEO_INTEROP"						     = "Polycom Skype Meeting Video Interop for Skype for Business"
	"SPB"					     			 = "Microsoft 365 Business Premium"
	"SPE_E5"								 = "Microsoft 365 E5"
	"SPE_E3"								 = "Microsoft 365 E3"
	"ATA"								     = "Advanced Threat Analytics"
	"MCOPSTN2"							     = "Domestic and International Calling Plan"
	"FLOW_P1"							     = "Microsoft Flow Plan 1"
	"FLOW_P2"							     = "Microsoft Flow Plan 2"
	"WIN_DEF_ATP"                            = "Windows Defender ATP"
	"NONPROFIT_PORTAL"                       = "Nonprofit Portal"
	"STREAM"		                       	 = "Microsoft Stream"
	"WACONEDRIVESTANDARD"                  	 = "OneDrive for Business Plan 1"	
	"WACONEDRIVEENTERPRISE"                	 = "OneDrive for Business Plan 2"	
	"TEAMS_EXPLORATORY"	                	 = "Microsoft Teams Exploratory (Free)"	
	"MEETING_ROOM"	                	 	 = "Microsoft Teams Rooms Standard"		
}



#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host
Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
	New-Item -ItemType Directory -Path $ReportPath
	write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
  }


$Users = Get-MsolUser -All | Where-Object { $_.isLicensed -eq "TRUE" } | Sort-Object DisplayName
Foreach ($User in $Users)
{
	Write-Host "Working on $($User.DisplayName)..." -ForegroundColor $InfoColor
	#Gets users license and splits it at the semicolon
	Write-Host "Getting all licenses for $($User.DisplayName)..." -ForegroundColor $InfoColorv2
	$Licenses = ((Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses).AccountSkuID
	$Company=(Get-AzureADUser -ObjectID $User.UserPrincipalName).CompanyName
	If (($Licenses).Count -gt 1)
	{
		Foreach ($License in $Licenses)
		{
			Write-Host "Finding $License in the Hash Table..." -ForegroundColor $InfoColorv2
			$LicenseItem = $License -split ":" | Select-Object -Last 1
			$TextLic = $Sku.Item("$LicenseItem")
			If (!($TextLic))
			{
				Write-Host "Error: The Hash Table has no match for $LicenseItem for $($User.DisplayName)!" -ForegroundColor Red
				$LicenseFallBackName = $License.AccountSkuId
				$NewObject02 = $null
				$NewObject02 = @()
				$NewObject01 = New-Object PSObject
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "Name" -Value $User.DisplayName
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "User Principal Name" -Value $User.UserPrincipalName
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "Company" -Value "$Company"
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "License" -Value "$LicenseFallBackName"
				$NewObject02 += $NewObject01
				$NewObject02 | Export-CSV $ResultsFile -NoTypeInformation -Append
			}
			Else
			{
				
				$NewObject02 = $null
				$NewObject02 = @()
				$NewObject01 = New-Object PSObject
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "Name" -Value $User.DisplayName
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "User Principal Name" -Value $User.UserPrincipalName
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "Company" -Value "$Company"
				$NewObject01 | Add-Member -MemberType NoteProperty -Name "License" -Value "$TextLic"
				$NewObject02 += $NewObject01
				$NewObject02 | Export-CSV $ResultsFile -NoTypeInformation -Append
				
			}
		}
		
	}
	Else
	{
		Write-Host "Finding $Licenses in the Hash Table..." -ForegroundColor $InfoColorv2
		$LicenseItem = ((Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses).AccountSkuID -split ":" | Select-Object -Last 1
		$TextLic = $Sku.Item("$LicenseItem")
		If (!($TextLic))
		{
			Write-Host "Error: The Hash Table has no match for $LicenseItem for $($User.DisplayName)!" -ForegroundColor Red
			$LicenseFallBackName = $License.AccountSkuId
			$NewObject02 = $null
			$NewObject02 = @()
			$NewObject01 = New-Object PSObject
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "Name" -Value $User.DisplayName
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "User Principal Name" -Value $User.UserPrincipalName
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "Office" -Value "$Office"
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "License" -Value "$LicenseFallBackName"
			$NewObject02 += $NewObject01
			$NewObject02 | Export-CSV $ResultsFile -NoTypeInformation -Append
		}
		Else
		{
			$NewObject02 = $null
			$NewObject02 = @()
			$NewObject01 = New-Object PSObject
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "Name" -Value $User.DisplayName
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "User Principal Name" -Value $User.UserPrincipalName
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "Office" -Value "$Office"
			$NewObject01 | Add-Member -MemberType NoteProperty -Name "License" -Value "$TextLic"
			$NewObject02 += $NewObject01
			$NewObject02 | Export-CSV $ResultsFile -NoTypeInformation -Append
		}
	}
}

Write-Host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------