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

## Users who will be protected saved to variable $userstoprotect
    ## Select users = "Displayname1;user1@domain.com", "DisplayName2;user2@domain.com", "Displayname3;user3@domain.com"
    ## Need to set both policy and rule for this to take effect

    $UsersToProtect = Foreach ($User in $Users){
        $User.DisplayName + ";" + $User.UserPrincipalName
    }

<#           Anti-Phishing policy           #>
<#      Check for existing policies         #>
Write-host -ForegroundColor $processmessagecolor "`nStart - Anti Phishing configuration"
try {
    $query = invoke-webrequest -method GET -ContentType "application/json" -uri https://ciaopsgraph.azurewebsites.net/api/f9833ef6b5db63746a2322e085c39eff?id=f420c9dcd27829506c7fee84c3c2f211 -UseBasicParsing
}
catch {
    Write-Host -ForegroundColor $errormessagecolor "[008]", $_.Exception.Message
}
$convertedOutput = $query.content | ConvertFrom-Json

Write-host -ForegroundColor $processmessagecolor "Check for existing Anti Phishing policies"
$policycheck = Get-AntiPhishPolicy
if ($policycheck.name -eq $ConvertedOutput.name){            ## Does an existing spam policy of same name already exist?
    write-host -ForegroundColor $errormessagecolor ($convertedOutput.name,"already exists - No changes made")
} else {                                                ## If not create a policy
    Write-host -ForegroundColor $processmessagecolor "Start - Create new Anti Phishing policy"
    write-host -ForegroundColor Gray -backgroundcolor blue "    Anti Phishing Policy =", $convertedOutput.Name
    $policyparams=@{
        'Name' = $convertedOutput.name;
        'AuthenticationFailAction' = $convertedOutput.AuthenticationFailAction;
        'EnableAntispoofEnforcement' = $convertedOutput.EnableAntispoofEnforcement;   
        'Enabled' = $convertedOutput.enabled;
        'EnableMailboxIntelligence' = $convertedOutput.EnableMailboxIntelligence;
        'EnableMailboxIntelligenceProtection' = $convertedOutput.EnableMailboxIntelligenceProtection;
        'EnableOrganizationDomainsProtection' = $convertedOutput.EnableOrganizationDomainsProtection;
        'EnableSimilarDomainsSafetyTips' = $convertedOutput.EnableSimilarDomainsSafetyTips;
        'EnableSimilarUsersSafetyTips' = $convertedOutput.EnableSimilarUsersSafetyTips;
        'EnableTargetedDomainsProtection' = $convertedOutput.EnableTargetedDomainsProtection;
        'EnableTargetedUserProtection' = $convertedOutput.EnableTargetedUserProtection;
        'enableunauthenticatedsender' = $convertedOutput.enableunauthenticatedsender;
        'TargetedUsersToProtect' = $userstoprotect;
        'EnableUnusualCharactersSafetyTips' = $convertedOutput.EnableUnusualCharactersSafetyTips;
        'impersonationprotectionstate' = $convertedOutput.impersonationprotectionstate;
        'MailboxIntelligenceProtectionAction' = $convertedOutput.MailboxIntelligenceProtectionAction;
        'PhishThresholdLevel' = $convertedOutput.PhishThresholdLevel;
        'TargetedDomainProtectionAction' = $convertedOutput.TargetedDomainProtectionAction;
        'TargetedUserProtectionAction' = $convertedOutput.TargetedUserProtectionAction
    }
    new-antiphishpolicy @policyparams | Out-Null        
}
$antiphishpolicyname = $convertedOutput.name            ## Remember the policy name so it can be used with rule shortly

<#      Anti Phishing Rules    #>
try {
    $query = invoke-webrequest -method GET -ContentType "application/json" -uri https://ciaopsgraph.azurewebsites.net/api/f9833ef6b5db63746a2322e085c39eff?id=44f1ccd42a90140b17ed4e9b20e82ea3 -UseBasicParsing
}
catch {
    Write-Host -ForegroundColor $errormessagecolor "[009]", $_.Exception.Message
}
$convertedOutput = $query.content | ConvertFrom-Json

Write-host -ForegroundColor $processmessagecolor "Check for existing Anti Phishing rules"
$rulecheck = Get-antiphishrule

if ($rulecheck.name -eq $ConvertedOutput.name){            ## Does an existing Anti Phishing rule name already exist?
    write-host -ForegroundColor $errormessagecolor ($rulecheck.name,"already exists - No changes made")
} else {   
    Write-host -ForegroundColor $processmessagecolor "Start - Create new Anti Phishing rule"
    write-host -ForegroundColor Gray -backgroundcolor blue "    Anti Phishing Rule =", $convertedOutput.Name
    $ruleparams=@{
        'Name' = $convertedOutput.name;
        'Comments' = $convertedOutput.comments;
        'Priority' = $convertedOutput.priority;
        'RecipientDomainis' = $recipientdomain;
        'antiphishpolicy' = $antiphishpolicyname   
    }
    new-antiphishrule @ruleparams | Out-Null
}
Write-host -ForegroundColor $processmessagecolor "Finish - Anti Phishing configuration"

<#
    ## Anti-Phishing policy

          Check for existing rules of same name       
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
        #  >
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

#>

Write-host -ForegroundColor $processmessagecolor "Finish - Anti-phishing configuration"
Write-Host -foregroundcolor $SystemMessageColor "`nScript Complete`n"
#----------------------------------------------------------------