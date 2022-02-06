<#
    .SCRIPT
       Version:        1.6.7
       Author:         Andrew Gallagher
       Contributor:    Robert Crane
       Contributor:    Yeoman Yu 
       Contributor:    Caleb Bateman
       Creation Date:  22/09/2020
       Modified Date:  23/10/2020

    .UPDATE 
       v1.6.6 - AG - Due to Cloud Flare incompatibility with -ANY Type a new variable called $Types is created which stores each of the individual DNS types.
                   - The script loops each of the individual $Types to gather the details required. This change does make the script runtime longer.
              - AG - Added Color variables instead of hard coding the output Color.
       v1.6.7 - AG - Nested Loop gone, script runs quicker.
              - AG - Progress of script running changed to text only format
              - AG - DNS Summary created. Displayed on screen and in the exported text file but not in CSV File.
              - AG - A few cosmetic colour changes
              - AG - Cannot fault output files. Location of files displayed on screen at start and end of display.
       
    .LINK
    Script: https://github.com/directorcia/patron/blob/master/o365-dns-get.ps1
    
       Powershell cheat sheet: http://ramblingcookiemonster.github.io/images/Cheat-Sheets/powershell-cheat-sheet.pdf
       Basic cheat sheet: http://ramblingcookiemonster.github.io/images/Cheat-Sheets/powershell-basic-cheat-sheet2.pdf
  
    .Description
       This is a simple method of retreiving DNS records for a domain.  
       The script will export the DNS values for the given domain name.
       
    .SYNOPSIS
    
    .PARAMETER Domain
       Specifies the domain to be looked up.
   
    .OUTPUTS
       Results are displayed on the screen
       Results are exported to a CSV file.
       Results are exported to a TXT file.
       Transcript are exported to a TXT file.
       
    .EXAMPLE
       C:\PS> .\DNS-Lookup.ps1
      
    .EXAMPLE
       C:\PS> .\DNS-Lookup.ps1 ciaops.com
     
    .NOTES
       It is very important to check the values of the following variables below $ResultsFile, $AllHeaderExport
    
       If you have running scripts that don't have a certificate, run this command once to disable that level of security
           Set-Executionpolicy -ExecutionPolicy Bypass -Scope Currentuser -Force
           Set-Executionpolicy remotesigned
           Set-Executionpolicy -ExecutionPolicy remotesigned -Scope Currentuser -Force
  
       Disconnect PowerShell Sessions:
       - Get-PSSession | Remove-PSSession
  
#>


#If a domain paramater is specified bring that value into the script.
param ($PDomain)

#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Ignore errors and move on with script.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ErrorActionPreference= 'silentlycontinue'      ## Not best practice but removes many errors on DNS resolution

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Choose DNS Server to use to find the records.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DNS_Server = "8.8.8.8"
#$DNS_Server = "8.8.4.4"
#$DNS_Server = "1.1.1.1"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Change the Delimiter between fields if required.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OutputDelimiter = "`t"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Export the headers into the log text file.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#$AllHeaderExport="N"
$AllHeaderExport="Y"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Initalize Arrays
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$A_Record_Outputs = @()
$NS_Record_Outputs = @()
$SOA_Record_Outputs = @()
$AAAA_Record_Outputs = @()
$SRV_Record_Outputs = @()
$MX_Record_Outputs = @()
$TXT_Record_Outputs = @()
$CNAME_Record_Outputs = @()
$ATableResults = @()
$AAAATableResults = @()
$CTableResults = @()
$MXTableResults = @()
$NSTableResults = @()
$SOATableResults = @()
$SRVTableResults = @()
$TXTTableResults = @()
$DNSHost = ''
$O365DirectoryId = ''
$TenantName = ''
$O365ExchangeOnline = ''
$SPF = ''
$DMARC = ''
$DKIM = 'False'
$GotSPF = $False
$GotDMARC = $False
$S1 = $False
$S2 = $False

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Output Colors
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DNSHeaderColor = "Yellow"
$DNSRecordTypeHeader = "Green"
$DNSRecordColor = "White"
$DNSSummaryColor = "White"
$ExportFileColor = "Gray"
$SystemMessageColor = "cyan"
$ProcessMessageColor = "green"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Local Path where report will be saved
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ReportPath = "C:\RelianceIT\Reports\"   ## Local Path where report will be saved
#$ReportPath = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#$ReportPath = (Get-Item .).FullName+"\"      ## Current directory

$timestamp = Get-Date -UFormat "-%d%m%Y-%T" | ForEach-Object { $_ -replace ":", "" }
#$Date = Get-Date -Format "yyyy-MM-dd"

#----------------------------------------------------------------
# Variable declartion complete.
#----------------------------------------------------------------

Clear-Host
write-host -foregroundcolor $systemmessagecolor "Script started`n"

#Check to see if the Data Directory exists.
If (-not (Test-Path -Path $ReportPath))
    {
     $TransName = "DNS_TransactionFile" +".txt"          
#     $TransFile = Join-Path -Path $ReportPath -ChildPath $TransName
     $TransFile =$reportpath+$transname
     start-transcript $TransFile | Out-Null
     write-host -ForegroundColor yellow -BackgroundColor red "[001] - Export Directory not found at",$ReportPath,"- Please ensure exists first`n"
     Stop-Transcript | Out-Null              ## Terminate transcription
     exit 1  
    }
else
    {
     $TransName = "DNS_TransactionFile" +".txt"          
#     $TransFile = Join-Path -Path $ReportPath -ChildPath $TransName
     $TransFile =$reportpath+$transname
     start-transcript $TransFile | Out-Null
     write-host -ForegroundColor $ProcessMessageColor "Export Directory directory found at", $ReportPath,"`n"
    }
    #write-host $PDomain

    #If the domain is not specified as a parameter ask the user for the domain.
    If ($PDomain -eq $null) 
        {
         #Ask the user for the domain to check
         $domain = Read-Host "Enter Domain Name"
        }
    Else
        {
         $domain = $PDomain
        }

    Do {
        $resolveDomain = (Resolve-DnsName -Name $domain -Server $DNS_Server -Type TXT | Where-Object { $_.Strings -ne '' } | Measure-Object).Count

        If ($resolveDomain -eq $null) {
            Write-Host "Didn't find Domain: $domain" -foregroundColor $ExportFileColor
            $domain = Read-Host "Enter Domain Name "        
        }
        Else {
            Write-Host "Found a record for $domain" -foregroundColor $ExportFileColor
##            $LocalHost = $env:COMPUTERNAME
            #$ReportName = ( "$Date" + "-" + "MobileDevices-" + $ClientName)           
            $ReportName = "DNS-" + $domain +".txt"
            $CSVName = "DNS-" + $domain +".csv"
            $HTMLName = "DNS-" + $domain +".html"
            $TransFinalName = "TRANS-" + $domain +".txt"
            
            $ReportDateName = $ReportName.Substring(0,($ReportName.length - 4)) + $timestamp + $ReportName.Substring($ReportName.length - 4)
            $CSVDateName = $CSVName.Substring(0,($CSVName.length - 4)) + $timestamp + $CSVName.Substring($CSVName.length - 4)
            $HTMLDateName = $HTMLName.Substring(0,($HTMLName.length - 5)) + $timestamp + $HTMLName.Substring($HTMLName.length - 5)
            $TransDateFinalName = $TransFinalName.Substring(0,($TransFinalName.length - 4)) + $timestamp + $TransFinalName.Substring($TransFinalName.length - 4)

            ## Location of export file
            #$ResultsFile = Join-Path -Path $ReportPath -ChildPath $ReportDateName
            $ResultsFile = $ReportPath+$ReportDateName
            #$CSVFile = Join-Path -Path $ReportPath -ChildPath $CSVDateName
            $CSVFile = $ReportPath+$CSVDateName
            #$HTMLFile = Join-Path -Path $ReportPath -ChildPath $HTMLDateName
            $HTMLFile = $ReportPath+$HTMLDateName
            #$TransDateDirFinalName = Join-Path -Path $ReportPath -ChildPath $TransDateFinalName
            $TransDateDirFinalName = $ReportPath+$TransDateFinalName
        }
    }
    Until ($resolveDomain -gt 0)

 # Basic Formatting used.

      Write-host " " 
      Write-host "Gathering Details for Domain : " $Domain -foregroundColor $DNSHeaderColor       
 
 # $Prefix variable is extremly important and can be modified
 # To obtain the root directory there must be a $Prefix record of ""
 # Add other prefixes as required

 #The following loop gathers the data for export into objects and arrays.
  
      $Prefixes = "","www","autodiscover","sip","lyncdiscover","msoid","enterpriseregistration","enterpriseenrollment","selector1._domainkey","selector2._domainkey","_sip._tls","_sipfederationtls._tcp","_dmarc"
      
        foreach ($Prefix in $Prefixes)
        {
            If ($Prefix -eq "")
            {
             $FullDomain = $Domain
            #Gather O365 Azure AD Directory ID           
              try 
               {
                $uri = "https://login.windows.net/" + $Domain + "/.well-known/openid-configuration"
                $openIDResponse = Invoke-RestMethod -Uri $uri -ErrorAction Stop
               }
              catch 
               {
                Write-Verbose "Couldn't retrieve federation data for domain: $DomainName"
               }
              if ($openIDResponse.token_endpoint) 
               {
                $O365DirectoryId = $openIDResponse.token_endpoint.split('/')[3]  
               }
              }
            
            else
            {
             $FullDomain = & { $($args -join ".")}  $Prefix $Domain
             Write-host "                               " $FullDomain -foregroundColor $DNSHeaderColor 
            }
                       

                 $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "A" | Where-Object {$_.Type -eq "A"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type               
                 foreach ($Result in $Results)
                 {
                  $A_Record_Name = $Result.Name
                  $A_Record_Type = $Result.Type
                  $A_Record_TTL = $Result.TTL
##                  $A_Record_Section = $Result.Section
                  $A_Record_IPAddress = $Result.IPAddress  
                  $A_Record_Outputs = $A_Record_Outputs + (& { "$($args -join "$OutputDelimiter")"}  $A_Record_Name $A_Record_Type $A_Record_TTL $A_Record_IPAddress)
                                    
                  $ATableResults += New-Object -TypeName PSCustomObject -Property @{
                    Type = $A_Record_Type
                    Name = $A_Record_Name
                    IPAddress = $A_Record_IPAddress
                    TTL = [math]::Round(($A_Record_TTL/60),0)}
                 }
                 $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "AAAA" | Where-Object {$_.Type -eq "AAAA"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                
                 foreach ($Result in $Results)
                 {
                  $AAAA_Record_Name = $Result.Name
                  $AAAA_Record_Type = $Result.Type
                  $AAAA_Record_TTL = $Result.TTL
##                  $AAAA_Record_Section = $Result.Section
                  $AAAA_Record_IPAddress = $Result.IPAddress  
                  $AAAA_Record_Outputs = $AAAA_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $AAAA_Record_Name $AAAA_Record_Type $AAAA_Record_TTL $AAAA_Record_IPAddress)

                  $AAAATableResults += New-Object -TypeName PSCustomObject -Property @{
                    Type = $AAAA_Record_Type
                    Name = $AAAA_Record_Name
                    IPAddress = $AAAA_Record_IPAddress
                    TTL = [math]::Round(($AAAA_Record_TTL/60),0)}                   
                  }                                                       
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "CNAME" | Where-Object {$_.Type -eq "CNAME"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                 
                  foreach ($Result in $Results)
                  {
                   $CNAME_Record_Name = $Result.Name
                   $CNAME_Record_Type = $Result.Type
                   $CNAME_Record_TTL = $Result.TTL
##                   $CNAME_Record_Section = $Result.Section
                   $CNAME_Record_NameHost = $Result.NameHost
                   $CNAME_Record_Outputs = $CNAME_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $CNAME_Record_Name $CNAME_Record_Type $CNAME_Record_TTL $CNAME_Record_NameHost)

                   $CTableResults += New-Object -TypeName PSCustomObject -Property @{
                     Type = $CNAME_Record_Type
                     Name = $CNAME_Record_Name
                     TTL = [math]::Round(($CNAME_Record_TTL/60),0)
                     Host = $CNAME_Record_NameHost}  

                   #Determine if a DKIM record is setup
                   if ($S1 -eq $False)
                    {
                     if (($CNAME_Record_Name.Substring(0,9)) -ieq 'selector1')
                     {
                      $S1 = $True
                     }
                     else 
                     {
                      $S1 = $false
                     }
                    }
                   if ($S2 -eq $False)
                    {
                     if (($CNAME_Record_Name.Substring(0,9)) -ieq 'selector2')
                      {
                       $S2 = $True
                      }
                     else 
                      {
                       $S2 = $false
                      }
                    }
                    if (($S1 -eq $True) -and ($S2 -eq $True))
                     {
                      $DKIM = "True"
                     }                  
                  }                                     
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "MX" | Where-Object {$_.Type -eq "MX"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                                  
                  foreach ($Result in $Results)
                  {
                   $MX_Record_Name = $Result.Name
                   $MX_Record_Type = $Result.Type
                   $MX_Record_TTL = $Result.TTL
##                   $MX_Record_Section = $Result.Section
                   $MX_Record_NameExchange = $Result.NameExchange
                   $MX_Record_Preference = $Result.Preference
                   $MX_Record_Outputs = $MX_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $MX_Record_Name $MX_Record_Type $MX_Record_TTL $MX_Record_NameExchange $MX_Record_Preference)

                   #Determine the Tenant Name and Exchange Online
                   $TenantName = $MX_Record_NameExchange | Where-Object {$_ -like '*.mail.protection.outlook.com'} | Select -First 1
                   if ($TenantName) 
                     { 
                      $TenantName = $TenantName.Replace('.mail.protection.outlook.com','') 
                      $O365ExchangeOnline = "Yes"
                     }
                   else
                     {
                      $O365ExchangeOnline = "No"
                     }
                  
                   $MXTableResults += New-Object -TypeName PSCustomObject -Property @{
                    Type = $MX_Record_Type
                    Name = $MX_Record_Name
                    TTL = [math]::Round(($MX_Record_TTL/60),0)
                    Host = $MX_Record_NameExchange
                    Preference = $MX_Record_Preference}                   
                  }
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "NS" | Where-Object {$_.Type -eq "NS"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                                                 
                  foreach ($Result in $Results)
                  {                                    
                   $NS_Record_Name = $Result.Name
                   $NS_Record_Type = $Result.Type
                   $NS_Record_TTL = $Result.TTL
##                   $NS_Record_Section = $Result.Section
                   $NS_Record_NameHost = $Result.NameHost
                   $NS_Record_Outputs = $NS_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $NS_Record_Name $NS_Record_Type $NS_Record_TTL $NS_Record_NameHost)
                   #Determine the DNS HOST
                   If ($DNSHost -eq '')
                     {
                      $DNSHost = $NS_Record_NameHost
                     }
                   Else
                     {
                      $DNSHost += ', ' + $NS_Record_NameHost
                     }
                  
                   $NSTableResults += New-Object -TypeName PSCustomObject -Property @{
                     Type = $NS_Record_Type
                     Name = $NS_Record_Name
                     TTL = [math]::Round(($NS_Record_TTL/60),0)
                     Host = $NS_Record_NameHost}                                                                                            
                  }                 
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "SOA" | Where-Object {$_.Type -eq "SOA"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                                                                 
                  foreach ($Result in $Results)
                  { 
                   $SOA_Record_Name = $Result.Name
                   $SOA_Record_Type = $Result.Type
                   $SOA_Record_TTL = $Result.TTL
##                   $SOA_Record_Section = $Result.Section
                   $SOA_Record_PrimaryServer = $Result.PrimaryServer
                   $SOA_Record_NameAdministrator = $Result.NameAdministrator
                   $SOA_Record_SerialNumber = $Result.SerialNumber
                   $SOA_Record_Outputs = $SOA_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $SOA_Record_Name $SOA_Record_Type $SOA_Record_TTL $SOA_Record_PrimaryServer $SOA_Record_NameAdministrator $SOA_Record_SerialNumber)
                  
                   $SOATableResults += New-Object -TypeName PSCustomObject -Property @{
                     Type = $SOA_Record_Type
                     Name = $SOA_Record_Name
                     TTL = [math]::Round(($SOA_Record_TTL/60),0)
                     Host = $SOA_Record_PrimaryServer
                     Administrator = $SOA_Record_NameAdministrator
                     Serial = $SOA_Record_SerialNumber}                                        
                   }
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "SRV" | Where-Object {$_.Type -eq "SRV"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                                                                                  
                  foreach ($Result in $Results)
                  { 
                   $SRV_Record_Name = $Result.Name
                   $SRV_Record_Type = $Result.Type
                   $SRV_Record_TTL = $Result.TTL
##                   $SRV_Record_Section = $Result.Section
                   $SRV_Record_NameTarget = $Result.NameTarget
                   $SRV_Record_Priority = $Result.Priority
                   $SRV_Record_Weight = $Result.Weight
                   $SRV_Record_Port = $Result.Port
                   $SRV_Record_Outputs = $SRV_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $SRV_Record_Name $SRV_Record_Type $SRV_Record_TTL $SRV_Record_NameTarget $SRV_Record_Priority $SRV_Record_Weight $SRV_Record_Port)
                   $SRVTableResults += New-Object -TypeName PSCustomObject -Property @{
                     Type = $SRV_Record_Type
                     Name = $SRV_Record_Name
                     TTL = [math]::Round(($SRV_Record_TTL/60),0)
                     Host = $SRV_Record_NameTarget
                     Target = $SRV_Record_NameTarget 
                     Priority = $SRV_Record_Priority 
                     Weight = $SRV_Record_Weight 
                     Port = $SRV_Record_Port}                   
                  }
                  $Results = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "TXT" | Where-Object {$_.Type -eq "TXT"} | Where-Object {$_.Name -eq $FullDomain} | Sort-Object -Property Type                                                                                                                  
                  foreach ($Result in $Results)
                  {                                  
                   $TXT_Record_Name = $Result.Name
                   $TXT_Record_Type = $Result.Type
                   $TXT_Record_TTL = $Result.TTL
##                   $TXT_Record_Section = $Result.Section
                   $TXT_Record_Strings = (@($Result.Strings) -join ',')
                   $TXT_Record_Outputs = $TXT_Record_Outputs + (& { $($args -join "$OutputDelimiter")}  $TXT_Record_Name $TXT_Record_Type $TXT_Record_TTL $TXT_Record_Strings)
        
                   $TXTTableResults += New-Object -TypeName PSCustomObject -Property @{
                   Type = $TXT_Record_Type
                   Name = $TXT_Record_Name
                   TTL = [math]::Round(($TXT_Record_TTL/60),0)
                   Host = $TXT_Record_Strings}                            

                   #Determine the SPF record
                   If ($GotSPF -ne $True)
                     {
                      $SPF = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "TXT" | Where-Object {$_.Strings -like '*v=spf1*'} -ErrorAction SilentlyContinue                   
                      if ($SPF -ne $null)
                       {
                        $GotSPF = $True
                        if (($SPF[0].Strings | Measure).Count -gt 1) 
                         {
                          $SPF = $SPF[0].Strings -join ''                    
                         }
                        else 
                         {
                          $SPF = $SPF[0].Strings[0]
                         }
                        }
                      }
                   #Determine the DMARC record
                   If ($GotDMARC -ne $True)
                     {
                      $DMARC = Resolve-DnsName -Name $FullDomain -Server $DNS_Server -Type "TXT" | Where-Object {$_.Strings -like '*v=DMARC1*'} -ErrorAction SilentlyContinue                   
                      if ($DMARC -ne $null)                      
                      {
                       $GotDMARC = $True
                       if (($DMARC[0].Strings | Measure).Count -gt 1) 
                        {
                         $DMARC = $DMARC[0].Strings -join ''                    
                        }
                       else 
                        {
                         $DMARC = $DMARC[0].Strings[0]
                        }
                       }
                      }

                  }
             }

           

#The following code exports the data out to files in order. 
#Note the order is determined by the running of the code and not a sort order.

## Export Domain Header to the export file.
      If ($AllHeaderExport -eq "Y")   
        {
         "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" | Out-file -filepath $ResultsFile -Append -width 180
         $Domain | Out-file -filepath $ResultsFile -Append -width 180
         "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" | Out-file -filepath $ResultsFile -Append -width 180
        }

## Export / Dislay A Records
           If ($AllHeaderExport -eq "Y" -and $A_Record_Outputs.Count -gt 0)    
           {
            "A Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($A_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   A Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($A_Record_Output in $A_Record_Outputs)
           {
            Write-host "     " $A_Record_Output -foregroundColor $DNSRecordColor  
            $A_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                                             
           }
           $ATableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
           
## Export / Dislay AAAA Records
           If ($AllHeaderExport -eq "Y" -and $AAAA_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "AAAA Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($AAAA_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   AAAA Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($AAAA_Record_Output in $AAAA_Record_Outputs)
           {
            Write-host "     " $AAAA_Record_Output -foregroundColor $DNSRecordColor  
            $AAAA_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                        
           }
           $AAAATableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
           
## Export / Dislay CNAME Records
           If ($AllHeaderExport -eq "Y" -and $CNAME_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "CNAME Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($CNAME_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   CNAME Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($CNAME_Record_Output in $CNAME_Record_Outputs)
           {
            Write-host "     " $CNAME_Record_Output -foregroundColor $DNSRecordColor  
            $CNAME_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                        
           }
           $CTableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
           
## Export / Dislay MX Records
           If ($AllHeaderExport -eq "Y" -and $MX_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "MX Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($MX_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   MX Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($MX_Record_Output in $MX_Record_Outputs)
           {
            Write-host "     " $MX_Record_Output -foregroundColor $DNSRecordColor  
            $MX_Record_Output | Out-file -filepath $ResultsFile -Append -width 180            
           }
           $MXTableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
           
## Export / Dislay NS Records
           If ($AllHeaderExport -eq "Y" -and $NS_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "NS Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($NS_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   NS Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($NS_Record_Output in $NS_Record_Outputs)
           {
            Write-host "     " $NS_Record_Output -foregroundColor $DNSRecordColor  
            $NS_Record_Output | Out-file -filepath $ResultsFile -Append -width 180            
           }
           $NSTableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
           
## Export / Dislay SOA Records
           If ($AllHeaderExport -eq "Y" -and $SOA_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "SOA Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($SOA_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   SOA Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($SOA_Record_Output in $SOA_Record_Outputs)
           {
            Write-host "     " $SOA_Record_Output -foregroundColor $DNSRecordColor  
            $SOA_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                        
           }           
           $SOATableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  

## Export / Dislay SRV Records
           If ($AllHeaderExport -eq "Y" -and $SRV_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "SRV Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($SRV_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   SRV Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($SRV_Record_Output in $SRV_Record_Outputs)
           {
            Write-host "     " $SRV_Record_Output -foregroundColor $DNSRecordColor  
            $SRV_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                     
           }           
           $SRVTableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  

## Export / Dislay TXT Records
           If ($AllHeaderExport -eq "Y" -and $TXT_Record_Outputs.Count -gt 0)    
           {
            "" | Out-file -filepath $ResultsFile -Append -width 180
            "TXT Records" | Out-file -filepath $ResultsFile -Append -width 180
           }
           If ($TXT_Record_Outputs.Count -gt 0)
           {
            Write-host " "
            Write-host "   TXT Records" -foregroundColor $DNSRecordTypeHeader
           }
           foreach ($TXT_Record_Output in $TXT_Record_Outputs)
           {
            Write-host "     " $TXT_Record_Output -foregroundColor $DNSRecordColor  
            $TXT_Record_Output | Out-file -filepath $ResultsFile -Append -width 180                     
           }           
           $TXTTableResults | Select-Object Type,Name,IPAddress,TTL,Host,Administrator,Preference,Serial,Target,Priority,Weight,Port | export-csv -Path $CSVFile -Append -NoTypeInformation                  
                  
    If ($AllHeaderExport -eq "Y")   
      {
       " " | Out-file -filepath $ResultsFile -Append -width 180
       "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" | Out-file -filepath $ResultsFile -Append -width 180
       " " | Out-file -filepath $ResultsFile -Append -width 180
      }


Write-host "`n------------- " -foregroundColor $DNSHeaderColor 
Write-host " DNS Summary" -foregroundColor $DNSHeaderColor 
Write-host "------------- " -foregroundColor $DNSHeaderColor 

Write-host "        DNS Registrar             :" $SOA_Record_NameAdministrator -foregroundColor $DNSSummaryColor 
Write-host "        DNS Host                  :" $DNSHost -foregroundColor $DNSSummaryColor 
Write-host " "
Write-host "        O365 Exchange Online      :" $O365ExchangeOnline -foregroundColor $DNSSummaryColor 
Write-host "        O365 Tenant Name          :" $TenantName -foregroundColor $DNSSummaryColor 
Write-host "        O365/AzureAD Directory ID :" $O365DirectoryId -foregroundColor $DNSSummaryColor 
Write-host " "
Write-host "        SPF Record                :" $SPF -foregroundColor $DNSSummaryColor 
Write-host "        DMARC Record              :" $DMARC -foregroundColor $DNSSummaryColor 
Write-host "        DKIM Enabled              :" $DKIM -foregroundColor $DNSSummaryColor 

"DNS Summary" | Out-file -filepath $ResultsFile -Append -width 180 
"        DNS Registrar             : " + $SOA_Record_NameAdministrator | Out-file -filepath $ResultsFile -Append -width 180   
"        DNS Host                  : " + $DNSHost | Out-file -filepath $ResultsFile -Append -width 180   

"" | Out-file -filepath $ResultsFile -Append -width 180   
"        O365 Exchange Online      : " + $O365ExchangeOnline | Out-file -filepath $ResultsFile -Append -width 180   
"        O365 Tenant Name          : " + $TenantName | Out-file -filepath $ResultsFile -Append -width 180   
"        O365/AzureAD Directory ID : " + $O365DirectoryId | Out-file -filepath $ResultsFile -Append -width 180   
"" | Out-file -filepath $ResultsFile -Append -width 180   
"        SPF Record                : " + $SPF | Out-file -filepath $ResultsFile -Append -width 180                                         
"        DMARC Record              : " + $DMARC | Out-file -filepath $ResultsFile -Append -width 180                                         
"        DKIM Enabled              : " + $DKIM | Out-file -filepath $ResultsFile -Append -width 180 
"--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" | Out-file -filepath $ResultsFile -Append -width 180
" " | Out-file -filepath $ResultsFile -Append -width 180                                        


Write-host " "
Write-host "Job Complete - Please view" -foregroundColor $DNSHeaderColor 
Write-host "        $ResultsFile" -foregroundColor $ExportFileColor 
Write-host "        $CSVFile" -foregroundColor $ExportFileColor
Write-host "        $TransDateDirFinalName" -foregroundColor $ExportFileColor
#Write-host "        $HTMLFile" -foregroundColor $ExportFileColor 
Invoke-Item $ReportPath

write-host -foregroundcolor $systemmessagecolor "`nScript Complete`n"

Stop-Transcript | Out-Null
Rename-Item -Path $TransFile -NewName $TransDateFinalName       ## Rename transcript file to match other export file names