<#
    .Link
    IT Glue: https://relianceit.itglue.com/3476556/docs/5847535#version=published&documentMode=view
    
    Microsoft:
    Deployment overview: https://docs.microsoft.com/en-us/microsoftteams/rooms/rooms-deploy
    Configure accounts for Microsoft Teams Rooms: https://docs.microsoft.com/en-us/microsoftteams/rooms/rooms-configure-accounts
    *Deploy Microsoft Teams Rooms with Microsoft 365 or Office 365: https://docs.microsoft.com/en-us/microsoftteams/rooms/with-office-365

    Third Party:
    Creating Microsoft Teams Rooms Accounts: http://blog.schertz.name/2019/02/creating-microsoft-teams-rooms-accounts/
    How to create and configure an account for your Microsoft Teams Room: https://ucstatus.com/2019/09/09/how-to-create-and-configure-an-account-for-your-microsoft-teams-room/

    .Description
    Deploy Microsoft Teams Rooms
 
    .Notes
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
$InfoColor = "Yellow"
$ErrorMessageColor = "Red"
$WarningMessageColor = "Yellow"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Script Variables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Room = "CAZConferenceRoom2@aureliametals.com.au"
$Password = "T1I&C^3u"
$Responce = "Microsoft Teams Meeting Room - Peak Conference Room 2"
$RegistrarPool = "sippoolsy3au103.infra.lync.com"


#----------------------------------------------------------------


#----------------------------------------------------------------
################# Start of Script ################
#----------------------------------------------------------------
Clear-Host

Write-Host -foregroundcolor $SystemMessageColor "`nScript started`n"

Set-Mailbox -Identity $Room -EnableRoomMailboxAccount $true -RoomMailboxPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force)
Set-CalendarProcessing -Identity $Room -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse $Responce
Set-CalendarProcessing -Identity $Room -ProcessExternalMeetingMessages $true
Set-MsolUser -UserPrincipalName $Room -PasswordNeverExpires $true

Import-Module SkypeOnlineConnector
$cssess=New-CsOnlineSession -Credential $cred  
Import-PSSession $cssess -AllowClobber

Enable-CsMeetingRoom -Identity $Room -RegistrarPool $RegistrarPool -SipAddressType EmailAddress

Write-Host -foregroundcolor $SystemMessageColor "`nScript complete`n"
#----------------------------------------------------------------