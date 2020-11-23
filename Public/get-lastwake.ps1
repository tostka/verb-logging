#*------v get-lastwake.ps1 v------
function get-lastwake {[CmdletBinding()]PARAM() ; get-lastevent -Wake -Verbose:$($VerbosePreference -eq 'Continue') }

#*------^ get-lastwake.ps1 ^------