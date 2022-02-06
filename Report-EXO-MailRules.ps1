
#----------------------------------------------------------------
################# Variables ################
#----------------------------------------------------------------
$SystemMessageColor = "Cyan"
$OutputColor = "Green"
$NoErrorColor = "Green"
$InfoColor = "Yellow"
$ErrorColor = "Red"


#Ask for User you are disabling
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'User'
$msg   = 'Enter Email of User to Check:'
$user = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
#----------------------------------------------------------------

#----------------------------------------------------------------
################# Check Rules ################
#----------------------------------------------------------------
"`n`n"
Get-InboxRule -Mailbox $user
"`n`n`n`n"
Get-InboxRule -Mailbox $user |fl
#----------------------------------------------------------------