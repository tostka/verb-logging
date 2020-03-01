#*------v Function get-lastsleep() v------
function get-lastsleep {
    # return the last 7 sleep events on the local pc
    # usage: get-lastsleep | ft -auto ;
    # 11:16 AM 1/5/2017 fixed # in report ; expanded returns: returning 14, but use only last 7 ; back port updates from get-lastwake, strip out custom MyAccount log (was pulling wakes not sleeps).
    # 1:49 PM 10/3/2016 add custom log/events support
    # vers: 7:17 AM 8/26/2014 corrected date fmt string
    # ver: 2:48 PM 8/25/2014 - fixed output to display day of week as well
    # 10:25 AM 1/5/2017 backport the get-lastwake updates to get-lastsleep

    <# Information	1/4/2017 2:44:10 PM	Kernel-Power	42	(64)	Info
    The system is entering sleep.
    Sleep Reason: Application API
    # cmdline works: Get-Eventlog -LogName System -Source Microsoft-Windows-Kernel-Power -entrytype Information -instanceid 42 -newest 7 -message "*sleep*"
    #>
    $nEvt = 14;
    $nFinalEvts = 7 ;
    $tevLog = "System";
    $tevSrc = "Microsoft-Windows-Kernel-Power";
    $tevType = "Information" ;
    $tevID = 42 ;
    $tevMsg = "*sleep*" ;
    $AMPMFilter = $null ;
    #"AM" ; # new ampm post filtering on TimeGenerated

    write-host -fore yellow ("=" * 10);
    write-host -fore yellow "`n===$_ LAST $($nFinalEvts) Hibe/Sleep===" ;
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
    # return an object v2/v3: return $evts; write-output $evts ;
    # or just dump to cons
    #$evts| ft -auto;
    returning 14, but use only last 7
    $evts[0..$($nFinalEvts)] | ft -auto;
} #*------^ END Function get-lastsleep() ^------