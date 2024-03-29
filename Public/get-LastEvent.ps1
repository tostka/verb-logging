﻿#*------v get-LastEvent.ps1 v------
function get-lastevent {
    <#
    .SYNOPSIS
    get-lastevent - get-winevent wrapper to pull most recent (Bootup|Shutdown|Sleep|Wake|Logon|Logoff) system eventlog markers on local system. Expands get-winevents builtin -filterhashtable, with post-filtering on Message content. By default returns most recent 7 of each ID specified.
    .NOTES
    Version     : 1.0.29.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka
    CreatedDate : 2/18/2020
    FileName    : get-lastevent.ps1
    License     : MIT
    Copyright   : (c) 2/18/2020 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	REFERENCEURL
    AddedTwitter:	@HANDLE / http://twitter.com/HANDLE
    REVISIONS
    * 12:51 PM 7/7/2022 fixed tag typo in logoff; updated CBH to dump examples of native get-winevent filters for each role (simple routine reference for other work); added std PS> prefixes to examples
    * 7:47 AM 3/9/2020 reworked get-winEventsLoopedIDs; added Verbose support across all get-last*()
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 7:19 AM 3/6/2020 rewriting to consolidate several get-lastxxx, with params to tag the variants, and an alias/function to deliver the matching names
    # 11:16 AM 1/5/2017 fixed # in report ; expanded returns: returning 14, but use only last 7 ; reworked on new event, and added AM/PM filtering to the events ; corrected echo to reflect wake, not sleep, added reference to the NETLOGON 5719 that might be a better target for below
    # 1:44 PM 10/3/2016 ported from get-lastsleep
    # vers: 7:17 AM 8/26/2014 corrected date fmt string
    # ver: 2:48 PM 8/25/2014 - fixed output to display day of week as well
    .DESCRIPTION
    get-lastevent - get-winevent wrapper to pull most recent (Bootup|Shutdown|Sleep|Wake|Logon|Logoff) system eventlog markers on local system. Expands get-winevents builtin -filterhashtable, with post-filtering on Message content. By default returns most recent 7 of each ID specified.

    ## FilterhashTable param options:
    |Key name|Value data type|Accepts wildcard characters?|
    |---|---|---|
    |LogName|<String[]>|Yes|
    |ProviderName|<String[]>|Yes|
    |Path|<String[]>|No|
    |Keywords|<Long[]>|No|
    |ID|<Int32[]>|No|
    |Level|<Int32[]>|No|
    |StartTime|<DateTime>|No|
    |EndTime|<DataTime>|No|
    |UserID|<SID>|No|
    |Data|<String[]>|No|
    |*|<String[]>|No|

    ## Keywords values
    |Name|Value|
    |---|---|
    |AuditFailure|4503599627370496|
    |AuditSuccess|9007199254740992|
    |CorrelationHint2|18014398509481984|
    |EventLogClassic|36028797018963968|
    |Sqm|2251799813685248|
    |WdiDiagnostic|1125899906842624|
    |WdiContext|562949953421312|
    |ResponseTime|281474976710656|
    |None|0|

    ## Type names converted to get-winevent-compatible Levels
    |Name|Value|
    |---|---|
    |Verbose|5|
    |Informational|4|
    |Warning|3|
    |Error|2|
    |Critical|1|
    |LogAlways|0|
    
    .PARAMETER MaxEvents
    Maximum # of events to poll for each event specified[-MaxEvents 14]
    .PARAMETER FinalEvents
    Final # of sorted events of all types to return [-FinalEvents 7]
    .PARAMETER Bootup
    Return most recent Bootup events [-Bootup]
    .PARAMETER Shutdown
    Return most recent Shutdown events [-Shutdown]
    .PARAMETER Sleep
    Return most recent Sleep events [-Sleep]
    .PARAMETER Wake
    Return most recent Wake events [-Wake]
    .PARAMETER Logon
    Return most recent Logon events [-Logon]
    .PARAMETER Logoff
    Return most recent Logoff events [-Logoff]
    .EXAMPLE
    PS> get-lastevent -Shutdown -verbose
    Get last Shutdown events w verbose output
    .EXAMPLE
    PS> get-lastevent -Bootup 
    Get last Bootup events
    .EXAMPLE
    PS> get-lastevent -Sleep 
    Get last Sleep events
    .EXAMPLE
    PS> get-lastevent -Wake 
    Get last Wake events 
    .EXAMPLE
    PS> get-lastevent -Logon
    Return most recent Logon events
    .EXAMPLE
    PS> get-lastevent -Logoff
    Return most recent Logoff events
    .EXAMPLE
    PS> $hlastBootUp=@{
    PS>     logname      = "System" ;
    PS>     ProviderName = "EventLog" ;
    PS>     ID           = 6009 ;
    PS>     Level        = 4 ;
    PS>     Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS> } ;
    PS> $evts = get-winevent -FilterHashtable $hlastBootUp ; 
    Demo native get-winevent -filter for LastBootup events
    .EXAMPLE
    PS>  $hlastShutdown=@{
    PS>      logname      = 'System';
    PS>      ProviderName = $null ;
    PS>      ID           = '13','6008','13','6008','6006' ;
    PS>      Level        = 4 ;
    PS>      Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastShutdown ; 
    Demo native get-winevent -filter for lastShutdown events
    .EXAMPLE
    PS>  $hlastSleep=@{
    PS>      logname      = "System" ;
    PS>      ProviderName = "Microsoft-Windows-Kernel-Power" ;
    PS>      ID           = 42 ;
    PS>      Level        = 4  ;
    PS>      Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastSleep ; 
    PS>  
    Demo native get-winevent -filter for lastSleep events
    .EXAMPLE
    PS>  $hlastWake=@{
    PS>      logname      = "System" ;
    PS>      ProviderName = "NETLOGON" ;
    PS>      ID           = 5719 ;
    PS>      Level    = 2 ;
    PS>      Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastWake ; 
    PS>  
    Demo native get-winevent -filter for lastWake events
    .EXAMPLE
    PS>  $hlastLogon=@{
    PS>      logname      = "security";
    PS>      ProviderName = $null ;
    PS>      ID           = 4624 ;
    PS>      Level        = 4  ;
    PS>      Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastLogon ; 
    Demo native get-winevent -filter for lastLogon events
    .EXAMPLE
    PS>  $hlastLogoff=@{
    PS>      logname      = "Security";
    PS>      ProviderName = $null ;
    PS>      ID           = 4634 ;
    PS>      Level        = 4  ;
    PS>      Verbose      = $($VerbosePreference -eq 'Continue') ;
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastLogoff ; 
    Demo native get-winevent -filter for lastLogoff events
    .LINK
    https://github.com/tostka/verb-logging
    #>
    ##Requires -Module verb-xxx
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage = "Maximum # of events to poll for each event specified[-MaxEvents 14]")]
        [int] $MaxEvents = 14,
        [Parameter(HelpMessage = "Final # of sorted events of all types to return [-FinalEvents 7]")]
        [int] $FinalEvents = 7,
        [Parameter(HelpMessage="Return most recent System Bootup events [-Bootup]")]
        [switch] $Bootup,
        [Parameter(HelpMessage="Return most recent System Shutdown events [-Shutdown]")]
        [switch] $Shutdown,
        [Parameter(HelpMessage="Return most recent System Sleep events [-Sleep]")]
        [switch] $Sleep,
        [Parameter(HelpMessage="Return most recent System Wake events [-Wake]")]
        [switch] $Wake,
        [Parameter(HelpMessage="Return most recent System Logon events [-Logon]")]
        [switch] $Logon,
        [Parameter(HelpMessage="Return most recent System Logoff events [-Logoff]")]
        [switch] $Logoff
    ) ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;
    [array]$evts = @() ;

    $hlastBootUp=@{
        logname      = "System" ;
        ProviderName = "EventLog" ;
        ID           = 6009 ;
        Level        = 4 ;
        Verbose      = $($VerbosePreference -eq 'Continue') ;
    } ;

    if($Bootup){
        $filter =  $hlastBootUp ;
        $Tag = "Bootup" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Shutdown) {
        # lose computername = localhost - it causes filterhashtable to fail qry - cuz it's not a supporte field of the param!
        $hlastShutdown=@{
            logname      = 'System';
            ProviderName = $null ;
            ID           = '13','6008','13','6008','6006' ;
            Level        = 4 ;
            Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter = $hlastShutdown ;
        $Tag = "Shutdown" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter   ;
        $evts = $evts | Sort-Object TimeCreated -desc ;
        if ((New-TimeSpan -start $(get-date $evts[0].timecreated) -end $(get-date)).days -gt 3) {
            write-verbose -verbose:$verbose "(adding logoffs)" ;
            $filter.ID = '7002' ;
            write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
            $evts += get-winEventsLoopedIDs $filter ;
        } ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Sleep) {
        $hlastSleep=@{
            logname      = "System" ;
            ProviderName = "Microsoft-Windows-Kernel-Power" ;
            ID           = 42 ;
            Level        = 4  ;
            Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter =  $hlastSleep ;
        $Tag = "Sleep" ;
        $message = "*sleep*"  ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Wake) {
        $hlastWake=@{
            logname      = "System" ;
            ProviderName = "NETLOGON" ;
            ID           = 5719 ;
            Level    = 2 ;
            Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter =  $hlastWake ;
        $Tag = "Wake" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Logon) {
        $hlastLogon=@{
            logname      = "security";
            ProviderName = $null ;
            ID           = 4624 ;
            Level        = 4  ;
            Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter =  $hlastLogon ;
        $Tag = "Logon" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        # additional property filter specific to logon events:
        $evts = $evts | Where-Object { $_.properties[8].value -eq 2 } ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Logoff) {
        $hlastLogoff=@{
            logname      = "Security";
            ProviderName = $null ;
            ID           = 4634 ;
            Level        = 4  ;
            Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter =  $hlastLogoff ;
        $Tag = "Logoff" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        # additional property filter specific to logon events:
        #$evts = $evts | where { $_.properties[8].value -eq 2 } ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } else {
        $filter =  $hlastBootUp ;
        $Tag = "Bootup (default)" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } ;

    #region output
    if ($AMPMFilter){
        $evts = $evts | Where-Object { (get-date -date $_.TimeCreated -Uformat %p) -eq $AMPMFilter }
    } ;
    $evts = $evts | Sort-Object TimeCreated -desc ;
    write-verbose -verbose:$verbose "events: `n$(($evts|out-string).trim())" ;

    $evts = $evts | Sort-Object TimeCreated -desc | Select-Object -first $MaxEvents | Select-Object @{Name = 'Time'; Expression = { get-date $_.TimeCreated -format 'ddd MM/dd/yyyy h:mm tt' } }, Message ;

    #$evts[0..$($FinalEvents)] | write-output
    #$evts[0..$($FinalEvents)] | ft -auto;
    $sBnr="`n#*======v LAST $($FinalEvents) $($Tag) Events: v======" ;
    $smsg = "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
    $smsg += "`n$(($evts[0..$($FinalEvents)] | Format-Table -auto |out-string).trim())" ;
    $smsg += "`n$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))`n" ;
    write-host -foregroundcolor green $smsg ;

    #endregion
}

#*------^ get-LastEvent.ps1 ^------