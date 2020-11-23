#*------v get-lastshutdown.ps1 v------
function get-lastshutdown {[CmdletBinding()]PARAM() ; get-lastevent -Shutdown -Verbose:$($VerbosePreference -eq 'Continue') }
if (!(get-alias -name "gls" -ea 0 )) { Set-Alias -Name 'gls' -Value 'get-lastshutdown' ; }

#*------^ get-lastshutdown.ps1 ^------