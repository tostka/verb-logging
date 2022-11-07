#*------v get-lastlogon.ps1 v------
function get-lastlogon {[CmdletBinding()]PARAM() ; get-lastevent -Logon -Verbose:$($VerbosePreference -eq 'Continue') }
#*------^ get-lastlogon.ps1 ^------
