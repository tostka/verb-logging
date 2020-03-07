#*------v Function get-lastshutdown  v------
function get-lastshutdown {get-lastevent -shutdown } ; 
if (!(get-alias -name "gls" -ea 0 )) { Set-Alias -Name 'gls' -Value 'get-lastshutdown' ; } ;
#*------^ END Function Function get-lastshutdown  ^------