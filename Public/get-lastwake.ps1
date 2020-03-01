#*------v Function get-lastwake() v------
function get-lastwake {
    # return the last 7 sleep events on the local pc
    # usage: get-lastwake | ft -auto ;
    # 11:16 AM 1/5/2017 fixed # in report ; expanded returns: returning 14, but use only last 7 ; reworked on new event, and added AM/PM filtering to the events ; corrected echo to reflect wake, not sleep, added reference to the NETLOGON 5719 that might be a better target for below
    # 1:44 PM 10/3/2016 ported from get-lastsleep
    # vers: 7:17 AM 8/26/2014 corrected date fmt string
    # ver: 2:48 PM 8/25/2014 - fixed output to display day of week as well
    <# 8:05 AM 1/5/2017 sleep as a splt: logname System -computername localhost -Source Microsoft-Windows-Kernel-Power -EntryType Information -newest $nEvt -message "*sleep*"
    $nEvt=7;$tevID=5719 ;$tevLog="System";$tevSrc="Microsoft-Windows-Kernel-Power";$tevID=1 ;$tevType="Information" ; ; $tevMsg="*sleep*" ;  #>
    <# 7:54 AM 1/5/2017 # below is missing de-hibs, since 12/30, shift to the alt: Error	1/3/2017 6:54:13 AM	NETLOGON	5719
    $nEvt=7;$tevLog="MyAccountScripts";$tevSrc="MyAccountWakeSleep";$tevID=1 ;$tevMsg=$null ;  #>
    <# 7:54 AM 1/5/2017: Error	1/3/2017 6:54:13 AM	NETLOGON	5719 #>
    #Not perfect, hits 2x per day on boot/dehyb, and again 1-230p. post-filter out the PM's
    $nEvt = 14;
    $nFinalEvts = 7 ;
    $tevLog = "System";
    $tevSrc = "NETLOGON";
    $tevID = 5719 ;
    $tevType = "Error" ; # 7:56 AM 1/5/2017 add entrytype
    $tevMsg = $null ;
    $AMPMFilter = "AM" ; # new ampm post filtering on TimeGenerated
    write-host -fore yellow ("=" * 10);
    # you can stack the 'logs' here comma-delimmed and loop them (no longer used, using explicit -logname now)
    #"System" | %{
    write-host -fore yellow "`n===$_ LAST $($nFinalEvts) Wake/Sleep===" ;
    #$sleeps=(get-eventlog -logname System -computername localhost -Source Microsoft-Windows-Kernel-Power -EntryType Information -newest $nEvt -message "*sleep*" | select TimeGenerated,Message);
    #wakes: -logname $tevLog -computername localhost -Source $tevSrc -InstanceID $tevID -EntryType $tevType -newest $nEvt=7
    $spltEvt = @{
        computername = "localhost" ;
        logname      = $($tevLog) ;
        Source       = $($tevSrc) ;
        InstanceID   = $($tevID) ;
        newest       = $($nEvt)
    } ;
    if ($tevType) { $spltEvt.Add("EntryType", $($tevType)) } ;
    if ($tevMsg) { $spltEvt.Add("message", $($tevMsg)) } ;
    #write-verbose -verbose:$true "$($spltEvt|out-string )" ;  # echo for debugging
    #$evts=(get-eventlog -logname $tevLog -computername localhost -Source $tevSrc -EntryType Information -InstanceID $tevID -EntryType $tevType -newest $nEvt=7 | select @{Name='Time';Expression={get-date $_.TimeGenerated -format 'ddd MM/dd/yyyy h:mm tt'}},Message) ;
    $evts = get-eventlog @spltEvt ;
    if ($AMPMFilter -eq "AM") {
        "note: filtering AM events" ;
        $evts = $evts | ? { (get-date -date $_.TimeGenerated -Uformat %p) -eq "AM" } ;
    }
    elseif ($AMPMFilter -eq "PM") {
        "note: filtering PM events" ;
        $evts = $evts | ? { (get-date -date $_.TimeGenerated -Uformat %p) -eq "PM" } ;
    } ;
    $evts = $evts | sort TimeGenerated -desc | select @{Name = 'Time'; Expression = { get-date $_.TimeGenerated -format 'ddd MM/dd/yyyy h:mm tt' } }, Message ;
    #} ; # the logname loop (disabled, we're explicit on it now)

    # return an object v2/v3: return $evts; write-output $evts ;
    # or just dump to cons
    #$evts| ft -auto;
    # 11:10 AM 1/5/2017 returning 14, but use only last 7
    $evts[0..$($nFinalEvts)] | ft -auto;
} #*------^ END Function get-lastwake() ^------