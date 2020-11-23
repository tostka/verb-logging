#*------v get-lastboot.ps1 v------
function get-lastlogon {[CmdletBinding()]PARAM() ; get-lastevent -Logon -Verbose:$($VerbosePreference -eq 'Continue') }

#*------^ get-lastboot.ps1 ^------