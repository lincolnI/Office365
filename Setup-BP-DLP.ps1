## Description
## Script designed to add default DLP policies to tenant

## Source - 

## Prerequisites = 1
## 1. Ensure Security and Compliance module installed or updated

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SystemMessageColor = "Cyan"
$ProcessmessageColor = "Green"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$mincount="1"
$maxcount="-1" ## = any
$minconfidence = "75"
$maxconfidence = "100"
#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
## If you have running scripts that don't have a certificate, run this command once to disable that level of security
##  set-executionpolicy -executionpolicy bypass -scope currentuser -force

Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"


## Configure Australian Privacy Act Policy
write-host -foregroundcolor $processmessagecolor "Start - Australian Privacy Act Policy"
$params = @{
'Name' = 'Australian Privacy Act';
'ExchangeLocation' ='All';
'OneDriveLocation' = 'All';
'SharePointLocation' =  'All';
'TeamsLocation' = 'All';
'Mode' = 'Enable'
}
$result=new-dlpcompliancepolicy @params

$senstiveinfo = @(@{Name ="Australia Driver's License Number"; minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Australia Passport Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence})

$Rulevalue = @{ 
'Name' = 'Low volume of content detected Australia Privacy Act';
'Comment' =  "Helps detect the presence of information commonly considered to be subject to the privacy act in Australia, like driver's license and passport number.";
'Policy' = 'Australian Privacy Act';
'ContentContainsSensitiveInformation'=$senstiveinfo;
'BlockAccess' = $true;
'AccessScope'='NotInOrganization';
'BlockAccessScope'='All';
'Disabled'=$false;
'GenerateAlert'='SiteAdmin';
'GenerateIncidentReport'='SiteAdmin';
'IncidentReportContent'='All';
'NotifyAllowOverride'='FalsePositive,WithJustification';
'NotifyUser'='Owner','SiteAdmin','LastModifier'
}

$result=New-dlpcompliancerule @rulevalue
write-host -foregroundcolor $processmessagecolor "Finish - Australian Privacy Act Policy`n"

## Configure Australian Financial Data Policy
write-host -foregroundcolor $processmessagecolor "Start - Australian Financial Data Policy"
$params = @{
'Name' = 'Australian Financial Data';
'ExchangeLocation' ='All';
'OneDriveLocation' = 'All';
'SharePointLocation' =  'All';
'TeamsLocation' = 'All';
'Mode' = 'Enable'
}
$result=new-dlpcompliancepolicy @params

$senstiveinfo = @(@{Name ="SWIFT Code"; minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Australia Tax File Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Australia Bank Account Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Credit Card Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence})

$Rulevalue = @{ 
'Name' = 'Low volume of content detected Australia Financial Data';
'Comment' =  "Helps detect the presence of information commonly considered to be financial data in Australia, including credit cards, and SWIFT codes.";
'Policy' = 'Australian Financial Data';
'ContentContainsSensitiveInformation'=$senstiveinfo;
'BlockAccess' = $true;
'AccessScope'='NotInOrganization';
'BlockAccessScope'='All';
'Disabled'=$false;
'GenerateAlert'='SiteAdmin';
'GenerateIncidentReport'='SiteAdmin';
'IncidentReportContent'='All';
'NotifyAllowOverride'='FalsePositive,WithJustification';
'NotifyUser'='Owner','SiteAdmin','LastModifier'
}

$result=New-dlpcompliancerule @rulevalue
write-host -foregroundcolor $processmessagecolor "Finish - Australian Financial Data Policy`n"

## Configure Australian Personally Identifable Information (PII) Data policy
write-host -foregroundcolor $processmessagecolor "Start - Australian Identifable Information (PII) Data Policy"

$params = @{
'Name' = 'Australian Personally Identifiable';
'ExchangeLocation' ='All';
'OneDriveLocation' = 'All';
'SharePointLocation' =  'All';
'TeamsLocation' = 'All';
'Mode' = 'Enable'
}
$result=new-dlpcompliancepolicy @params

$senstiveinfo = @(@{Name ="Australia Passport Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Australia Driver's License Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence})

$Rulevalue = @{ 
'Name' = 'Low volume of content detected Australia Personally Identifiable';
'Comment' =  "Helps detect the presence of information commonly considered to be subject to the privacy act in Australia, like driver's license and passport number.";
'Policy' = 'Australian Personally Identifiable';
'ContentContainsSensitiveInformation'=$senstiveinfo;
'BlockAccess' = $true;
'AccessScope'='NotInOrganization';
'BlockAccessScope'='All';
'Disabled'=$false;
'GenerateAlert'='SiteAdmin';
'GenerateIncidentReport'='SiteAdmin';
'IncidentReportContent'='All';
'NotifyAllowOverride'='FalsePositive,WithJustification';
'NotifyUser'='Owner','SiteAdmin','LastModifier'
}

$result=New-dlpcompliancerule @rulevalue
write-host -foregroundcolor $processmessagecolor "Finish - Australian Identifable Information (PII) Data Policy`n"

## Configure Australian Health Records Act (HRIP Act)
write-host -foregroundcolor $processmessagecolor "Start - Australian Health Records Act Policy"

$params = @{
'Name' = 'Australian Health Records Act (HRIP Act)';
'ExchangeLocation' ='All';
'OneDriveLocation' = 'All';
'SharePointLocation' =  'All';
'TeamsLocation' = 'All';
'Mode' = 'Enable'
}
$result=new-dlpcompliancepolicy @params

$senstiveinfo = @(@{Name ="Australia Tax File Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence},@{Name ="Australia Medical Account Number";minCount = $mincount; maxcount = $maxcount; minconfidence = $minconfidence; maxconfidence = $maxconfidence})

$Rulevalue = @{ 
'Name' = 'Low volume of content detected Australia Health Records';
'Comment' =  "Helps detect the presence of information commonly considered to be subject to the Health Records and Information Privacy (HRIP) act in Australia, like medical account number and tax file number.";
'Policy' = 'Australian Health Records Act (HRIP Act)';
'ContentContainsSensitiveInformation'=$senstiveinfo;
'BlockAccess' = $true;
'AccessScope'='NotInOrganization';
'BlockAccessScope'='All';
'Disabled'=$false;
'GenerateAlert'='SiteAdmin';
'GenerateIncidentReport'='SiteAdmin';
'IncidentReportContent'='All';
'NotifyAllowOverride'='FalsePositive,WithJustification';
'NotifyUser'='Owner','SiteAdmin','LastModifier'
}

$result=New-dlpcompliancerule @rulevalue
write-host -foregroundcolor $processmessagecolor "Start - Australian Health Records Act Policy`n"


Write-Host -foregroundcolor $SystemMessageColor "`nScript Complete`n"
#----------------------------------------------------------------