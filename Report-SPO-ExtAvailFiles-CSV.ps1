<#
    .Link
    https://github.com/directorcia/patron/blob/master/o365-spo-extavail-csv.ps1

    .Description
    Report on files that are accessible externally i.e. have been shared with people otside the tenant and export that list to CSV

    This script will create a new compliance search and then run a compliance search and export the results to a CSV file. 
    The content search will be for any externally shared files across your tenant.
    ** You can re-run this script at anytime to update the results by setting the variable $createnewsearch=$false.

    .Notes
    Prerequisites = 2
        1. Connected to Security and Compliance Center
        2. Ensure the user running the script is an eDiscovery manager use add-ediscoverycaseadmin to set this in PowerShell
    
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
$OutputColor = "Green"


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard File Saver
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LocalHost = $env:COMPUTERNAME
$ClientName = Read-Host -Prompt 'What Tenent is this for'
$Date = Get-Date -Format "yyyy-MM-dd"
$ReportName = ( "$Date" + "-" + "MobileDevices-" + $ClientName)
$ReportPath = "C:\RelianceIT\Reports"   ## Local Path where report will be saved
$ResultsFile = Join-Path -Path $ReportPath -ChildPath "$ReportName.csv"      ## Location of export file

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Results = @()                              ## where the ultimate results end up
$SearchName = 'Externally shared'           ## What the content will be called in the portal
$SearchdeScript = 'Search for file content that is shared externally outside the tenant'
$CreateNewSearch = $false                   ## Set whether a new search will be created. Leave set to false if search already exists and you just want to refresh


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

If (!(test-path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath
    write-host -foregroundcolor $SystemMessageColor "`nFolder Created: $ReportPath"
}


If ($createnewsearch){
    write-host -foregroundcolor $processmessagecolor "Start create a new compliance search called",$searchname
    New-compliancesearch -name $searchname -contentmatchquery "ViewableByExternalUsers=TRUE" -description $searchdescript -sharepointlocation all 
    write-host -foregroundcolor $processmessagecolor "Completed creating a new compliance search called",$searchname 
}

write-host -foregroundcolor $processmessagecolor "Start run compliance search called",$searchname
Start-compliancesearch -identity $searchname
write-host -foregroundcolor $processmessagecolor "Completed run compliance search called",$searchname

write-host -foregroundcolor $processmessagecolor "Start compliance search status named",$searchname
$searchstatus = Get-ComplianceSearch  -Identity $searchname
$i=0
while ($searchstatus.status -ne "Completed"){
    ++$i
    write-host -foregroundcolor $processmessagecolor "Waiting for running search to complete",$i
    $searchstatus = Get-ComplianceSearch  -Identity $searchname
}
write-host -foregroundcolor $processmessagecolor "Completed compliance search status named",$searchname

write-host -foregroundcolor $processmessagecolor "Start creating a compliance search preview for",$searchname
$searchstatus = New-compliancesearchaction -searchname $searchname -preview
$searchpreview = $searchname+"_preview"
$i=0
while ($searchstatus.status -ne "Completed"){
    ++$i
    write-host -foregroundcolor $processmessagecolor "Waiting for running search to complete",$i
    $searchstatus = Get-ComplianceSearch  -Identity $searchname
}
write-host -foregroundcolor $processmessagecolor "Finished creating a compliance preview created called",$searchpreview

write-host -foregroundcolor $processmessagecolor "Start getting compliance search results from",$searchpreview
$dataresults = Get-ComplianceSearchAction  -Identity $searchpreview | select-object -Property Results
write-host -foregroundcolor $processmessagecolor "Finished getting compliance search results for",$searchname


## Tidy Results
write-host -foregroundcolor $processmessagecolor "Start cleaning up data"
$searchresults=$dataresults.Results.split(";")
$searchresults=$searchresults.split(",")
$searchresults=$searchresults.replace('{','')
$searchresults=$searchresults.replace( '}','')
$searchresults=$searchresults.replace(' ','')
write-host -foregroundcolor $processmessagecolor "Completed cleaning up data"

$sender2=$false         ## Set initial multiple sender variable to not enabled

<#
Data field formats extracted from results:
1. Location
2. Sender
3. Sender1
4. Sender2
5. Subject
6. Type
7. Size
8. Received time
9. Data link
#>

for ($i=0;$i -le ($searchresults.length-1); $i++){      ## loop through all the available entries in results
    $entry1=$searchresults[$i].split(":"" ",2)          ## split the string at the : and <space> character
    If ($entry1 -ne $searchresults[$i]){
        $entry1A=$entry1.Split(" ")[0].trim()               ## remove leading spaces from first component and split at the <space>
        $entry1B=$entry1.split(" ")[1]                      ## save second parameter split at <space> 
    } elseif ($sender2 -eq $false) {
        $entry1a = "Sender1"
        $entry1b = $entry1
        $sender2 = $true
    } else {
        $entry1a = "Sender2"
        $entry1b = $entry1
        $sender2 = $true
    }
    write-host -foregroundcolor $processmessagecolor "Line item ",$i        ## Record number from results
    write-host -foregroundcolor $processmessagecolor "entry 1 = ",$entry1A  ## Report parameter1
    write-host -foregroundcolor $processmessagecolor "entry 2 = ",$entry1B  ## Report parameter2
        
    If ($entry1a -eq "Location"){       ## Is parameter1 the Location field (which is the first field)
        $return="" | select-object Location,Sender, sender1,sender2, Subject,Type,Size,Receivedtime,Datalink    ## Initialise array variable to hold results for record
        $return.location = $entry1b     ## Set array Location field to parameter2
    }
    If ($entry1a -eq "Sender"){         ## Is parameter1 the Sender field
        $return.sender=$entry1b         ## Set array Sender field to parameter2
    }
    If ($entry1a -eq "Sender1"){        ## Is parameter1 the Sender1 field
        $return.sender1=$entry1b        ## Set array Sender1 field to paramter2
    }
    If ($entry1a -eq "Sender2"){        ## Is parameter1 the Sender2 field
        $return.sender2=$entry1b        ## Set array Sender2 field to parameter2
    }
    If ($entry1a -eq "Subject"){        ## Is parameter1 the Subject field
        $return.subject=$entry1b        ## Set array Subject field to parameter2
    }
    If ($entry1a -eq "Type"){           ## Is paramter1 the Type field
        $return.type=$entry1b           ## Set array Type field to parameter2
    }
    If ($entry1a -eq "Size"){           ## Is parameter1 the Size field
        $return.size=$entry1b           ## Set array Size field to parameter2
    }
    If ($entry1a -eq "Receivedtime"){   ## Is parameter1 the Receivedtime field
        $return.receivedtime=$entry1b   ## Set array Receivedtime field to parameter2
    }
    If ($entry1a -eq "DataLink"){       ## Is parameter1 the Datalink field
        $return.datalink=$entry1b       ## Set array Datalink field to paramter2
        $results += $return             ## Write the complete array to a new variable because this is the last field in record
    }
}

$Results | export-csv -path $ReportPath -NoTypeInformation 


write-host -foregroundcolor $OutputColor "`nFile $ResultsFile Created"
Invoke-Item $ReportPath
Invoke-Item $ResultsFile

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------