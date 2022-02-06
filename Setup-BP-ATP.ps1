## For O365 Advanced Threat Protection (ATP) ##
## Ensure you have Exchange Online, Security Center and AzureAD module loaded

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessMessageColor = "Green"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"
$ErrorMessageColor = "Red"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SafeLinksPolicyName = "M365B Links Policy"  
$SafeLinksRuleName = "M365B Links Rule"
$SafeAttachPolicyName = "M365B Attachment Policy"
$SafeAttachRuleName = "M365B Attachment Rule"
$PhishingPolicyName = "M365B Phishing Policy"
$PhishingRuleName = "M365B Phishing Rule"
$RecipientDomain = Get-MsolDomain
$Users = Get-MsolUser -All | where {$_.isLicensed -eq $true}

<# 
.Notes If you need to split per licence type
$Users = Get-MsolUser -All | where {$_.Licenses.AccountSkuId -contains "reseller-account:ENTERPRISEPACK"}
#>

#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

Enable-OrganizationCustomization

## Default policy
Write-host -ForegroundColor $processmessagecolor "Start - Configure default policy"
Set-atppolicyforo365 -allowclickthrough $false -enablesafelinksforclients $true -enableatpforspoteamsodb $true -trackclicks $true
## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/set-atppolicyforo365?view=exchange-ps
Write-host -ForegroundColor $processmessagecolor "Finish - Configure default policy"

## SafeLinks
<#      Check for existing rules of same name       #>
Write-host -ForegroundColor $processmessagecolor "Start - Safe Links configuration"
Write-host -ForegroundColor $processmessagecolor "Check for existing policy"
$policycheck = Get-safelinksPolicy

if ($policycheck.name -contains $safelinkspolicyname){            ## Does an existing spam policy of same name already exist?
    write-host -ForegroundColor $errormessagecolor ($safelinkspolicyname,"already exists - No changes made")
} else {                                                ## If not create a policy
    New-safelinkspolicy -name $safelinkspolicyname -admindisplayname $safelinkspolicyname -donotallowclickthrough $true -donottrackuserclicks $false -enableforinternalsenders $true -isenabled $true -scanurls $true -trackclicks $true -delivermessageafterscan $true
    ## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safelinkspolicy?view=exchange-ps

    New-SafeLinksRule -Name $safelinksrulename -SafelinksPolicy $safelinkspolicyname -enabled $true -priority 0 -recipientdomainis $RecipientDomain.name
    ## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safelinksrule?view=exchange-ps
}
Write-host -ForegroundColor $processmessagecolor "Finish - Safe Links configuration"

## SafeAttachments
<#      Check for existing rules of same name       #>
Write-host -ForegroundColor $processmessagecolor "Start - Safe Attachments configuration"
Write-host -ForegroundColor $processmessagecolor "Check for existing policy"
$policycheck = Get-safeattachmentPolicy

if ($policycheck.name -contains $safeattachpolicyname){            ## Does an existing spam policy of same name already exist?
    write-host -ForegroundColor $errormessagecolor ($safeattachpolicyname,"already exists - No changes made")
} else {                                                ## If not create a policy
    ## Action options = Block | Replace | Allow | DynamicDelivery
    New-safeattachmentpolicy -name $safeattachpolicyname -admindisplayname $safeattachpolicyname -enable $true -action Block -actiononerror $true -redirect $false
    ## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safeattachmentpolicy?view=exchange-ps

    New-SafeAttachmentRule -Name $safeattachrulename -SafeAttachmentPolicy $safeattachpolicyname -enabled $true -priority 0 -recipientdomainis $RecipientDomain.name
    ## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-safeattachmentrule?view=exchange-ps
}
Write-host -ForegroundColor $processmessagecolor "Finish - Safe Attachments configuration"



## Anti-Phishing policy

<#      Check for existing rules of same name       #>
Write-host -ForegroundColor $processmessagecolor "Start - Anti-phishing configuration"
Write-host -ForegroundColor $processmessagecolor "Check for existing policy"
$policycheck = Get-AntiPhishPolicy
	
## Users who will be protected saved to variable $userstoprotect
## Select users = "Displayname1;user1@domain.com", "DisplayName2;user2@domain.com", "Displayname3;user3@domain.com"
## Need to set both policy and rule for this to take effect

$UsersToProtect = Foreach ($User in $Users){
    $User.DisplayName + ";" + $User.UserPrincipalName
 }

 if ($policycheck.name -contains $phishingpolicyname){            ## Does an existing spam policy of same name already exist?
    write-host -ForegroundColor $errormessagecolor ($phishingpolicyname,"already exists - No changes made")
} else {     
$imperspolicyparams=@{

	<#
		'Name' = $phishingpolicyname;
		'AdminDisplayName' = $phishingpolicyname
	 	'AuthenticationFailAction' =  'MoveToJmf';
	   	'EnableAntispoofEnforcement' = $true;
	   	#'EnableAuthenticationSafetyTip' = $true;
		#'EnableAuthenticationSoftPassSafetyTip' = $true;
		'Enabled' = $true;
		'EnableMailboxIntelligence' = $true;
		'EnableOrganizationDomainsProtection' = $true;
		'EnableSimilarDomainsSafetyTips' = $true;
		'EnableSimilarUsersSafetyTips' = $true;
		'EnableTargetedDomainsProtection' = $false;
		'EnableTargetedUserProtection' = $true;
		'TargetedUsersToProtect' = $userstoprotect;
		'EnableUnusualCharactersSafetyTips' = $true;
		'PhishThresholdLevel' = 1;
		'TargetedDomainProtectionAction' =  'MoveToJmf';
		'TargetedUserProtectionAction' =  'MoveToJmf';
		#'TreatSoftPassAsAuthenticated' = $true
	#>
	'Name' = $phishingpolicyname;
    'AdminDisplayName' = $phishingpolicyname;
    'AuthenticationFailAction' =  'MoveToJmf';
    'EnableAntispoofEnforcement' = $true;
##    'EnableAuthenticationSafetyTip' = $true;              ## causing an error even though documented - https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishpolicy?view=exchange-ps        
##    'EnableAuthenticationSoftPassSafetyTip' = $true;              ## causing an error even though documented - https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishpolicy?view=exchange-ps        
    'Enabled' = $true;
    'EnableMailboxIntelligence' = $true;
    'EnableMailboxIntelligenceProtection' = $true;              ## Specifies whether to enable or disable intelligence based impersonation protection. Valid values are: $true: Enable intelligence based impersonation protection. $false: Don't enable intelligence based impersonation protection. This is the default value.
    'EnableOrganizationDomainsProtection' = $true;
    'EnableSimilarDomainsSafetyTips' = $true;
    'EnableSimilarUsersSafetyTips' = $true;
    'EnableTargetedDomainsProtection' = $false;
    'EnableTargetedUserProtection' = $true;
    'MailboxIntelligenceProtectionAction' = 'MovetoJmf';        ## 
    'TargetedUsersToProtect' = $userstoprotect;
    'EnableUnusualCharactersSafetyTips' = $true;
    'PhishThresholdLevel' = 1;
    'TargetedDomainProtectionAction' =  'MoveToJmf';
    'TargetedUserProtectionAction' =  'MoveToJmf'
##    'TreatSoftPassAsAuthenticated' = $true                    ## causing an error even though documented - https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishpolicy?view=exchange-ps
		
	}
New-AntiPhishPolicy @imperspolicyparams
## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishpolicy?view=exchange-ps
	
## Domains that will be protected saved to variable $RecipientDomain
## Select domains = "domain1.com", "domain2.com", "domain3.com"
$imperruleparams = @{
    'Name' = $phishingrulename;
	'AntiPhishPolicy' = $phishingpolicyname;  ## Needs to match the above policy name
	'RecipientDomainis' = $RecipientDomain.name;
	'Enabled' = $true;
	'Priority' = 0
}
New-antiphishrule @imperruleparams
## https://docs.microsoft.com/en-us/powershell/module/exchange/advanced-threat-protection/new-antiphishrule?view=exchange-ps
}

Write-host -ForegroundColor $processmessagecolor "Finish - Anti-phishing configuration"
Write-Host -foregroundcolor $SystemMessageColor "`nScript Complete`n"
#----------------------------------------------------------------