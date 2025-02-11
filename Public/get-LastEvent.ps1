#*------v get-LastEvent.ps1 v------
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
    9:37 AM 2/11/2025 updated CBH examples to include each of the variants (get-help isn't showing the output specd though).
    * 3:09 PM 2/10/2025 Updated to fix borked get-lastevent -logon; found Teams is spamming Sec log with 4673 errors, rolling over prematurely (details in Description).
        This makes get-lastevent -logon & -logoff essentially useless; there's no security data to output.
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
    
    NOTE: Bad Teams implementation has 4-5yr old bug that saturates the Security log with bogus Audit Fail 4673 errors  (tons):

    [windows event log - Microsoft Teams filling Security Log with seProfileSingleProcessPrivilege - Server Fault](https://serverfault.com/questions/1115846/microsoft-teams-filling-security-log-with-seprofilesingleprocessprivilege)

        Recently, we started seeing a phenomenon where any machine running Microsoft Teams (office 365 E3 version) will emit event 4673 at a high rate, indicating a failed attempt to use the seProfileSingleProcessPrivilege. Counting one random second's worth of these entries, I saw 120. The volume of these audit failures is causing the security log to fill and overwrite so quickly that no valuable information can be retained.

        By policy, we audit both success and failure on privilege use, so turning off audit is not an option. Granting the privilege to all users seems like a poor security practice as well.

        I do not see chatter about this issue, so I am wondering if we are alone with this symptom.

        I can't explain why Teams would be attempting to grant this privilege to itself.

        ---


        We opened a case with Microsoft Support. They dug a bit and found that Teams is written on top of Chromium. Chromium is calling QueryWorkingSetEx. It is unclear why this is interesting, but QueryWorkingSetEx requires seProfileSingleProcessPrivilege. It is unclear if QueryWorkingSetEx just fails or if it does something interesting even if it can't enable the privilege. Microsoft is still reviewing at this time.

        Update 1/19/2023 - Microsoft closed the case on this with no action. They could update Chromium so that this behavior is mitigated. They chose not to. They adamantly don't care about this issue and their official recommendation was to stop logging the error.
        Share
        Improve this answer
        Follow
        edited Jan 19, 2023 at 21:27
        answered Dec 5, 2022 at 22:10
        Prof Von Lemongargle's user avatar
        Prof Von Lemongargle
        39844 silver badges10

        ---

        I love it how they're blaming "Chromium", when it's their own code ("WebView2") running on top of their highly modified version that the Edge browser runs on. They might as well stop claiming Edge is a separate browser if it's so impossible to fix. office365itpros.com/2021/06/25/… Also, unfortunately, there are a lot of "false positive" audit errors of this kind in products going back many years (not just Edge-based) that MSFT doesn't bother fixing. – 
        LeeM
        Commented Jan 19, 2023 at 22:18

        ===

        [Event ID 4673 for Teams.exe and msedge.exe : r/sysadmin](https://www.reddit.com/r/sysadmin/comments/10285sd/event_id_4673_for_teamsexe_and_msedgeexe/)


        Hofsizzle
        •
        2y ago

        Just wanted to provide an update - had a ticket with Microsoft, below is there exact response. So it seems there is no fix, and ignoring it is basically our best option.

        Microsoft Response
        Here is the information that I wanted to discuss with you today:

        After researching the issue, my team and I have found that this is a known issue that is not unique to Teams or Edge. This issue occurs with Chrome and Chromium applications. The issue occurs with Chromium-based applications if their default configurations are changed. 
 
        At this time, there are three options to move forward:

            You can permit SeProfileSingleProcessPrivilege for users.

            You can disable the failure audits.

            You can continue to monitor with the high volume of events being generated.


        [Excessive Windows 10 Audit Failures from chrome.exe, teams.exe or edge.exe - Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/1468731/excessive-windows-10-audit-failures-from-chrome-ex)

        Accepted answer

        [Thameur-BOURBITA](https://learn.microsoft.com/en-us/users/na/?userid=8880cc80-2edd-449a-b44e-edf51fbbcbe6) •

        Follow

        35,436 Reputation points

        Dec 26, 2023, 1:15 PM

        Hi @[Augusto Alves](https://learn.microsoft.com/en-us/users/na/?userid=b73c744b-e97f-4fc4-851b-6314838f838d)

        I think The thread below is talking about the same issue.

        Following to the microsoft feedback in the link below,it's a known issue and you can ignore it .

        You can try to contact again Microsoft to confirm if there is a fix for this event:

        [Excessive Windows 10 Audit Failures from chrome.exe, teams.exe or edge.exe](https://learn.microsoft.com/en-us/answers/questions/1144610/event-id-4673-for-teams-exe-and-msedge-exe)

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
    PS> get-lastevent -Bootup ; 

        #*======v UP TO LAST 7 Bootup Events: v======
        Time                   Message
        ----                   -------
        Mon 02/10/2025 8:38 AM Microsoft (R) Windows (R) 10.00. 19045  Multiprocessor Free.
        Wed 02/05/2025 8:24 AM Microsoft (R) Windows (R) 10.00. 19045  Multiprocessor Free.
        Thu 01/23/2025 8:39 AM Microsoft (R) Windows (R) 10.00. 19045  Multiprocessor Free.
        Fri 01/17/2025 2:38 PM Microsoft (R) Windows (R) 10.00. 19045  Multiprocessor Free.
        09:26:14:
        #*======^ UP TO LAST 7 Bootup Events: ^======

    Demo Bootup
    .EXAMPLE
    PS> get-lastevent -Shutdown ; 

        09:26:14:
        #*======v UP TO LAST 7 Shutdown Events: v======
        Time                   Message
        ----                   -------
        Mon 02/10/2025 8:29 AM The operating system is shutting down at system time ‎2025‎-‎02‎-‎10T14:29:16.917923600Z.
        Mon 02/10/2025 8:29 AM The operating system is shutting down at system time ‎2025‎-‎02‎-‎10T14:29:16.917923600Z.
        Mon 02/10/2025 8:29 AM The Event log service was stopped.
        Wed 02/05/2025 8:24 AM The operating system is shutting down at system time ‎2025‎-‎02‎-‎05T14:24:04.677351000Z.
        Wed 02/05/2025 8:24 AM The operating system is shutting down at system time ‎2025‎-‎02‎-‎05T14:24:04.677351000Z.
        Wed 02/05/2025 8:23 AM The Event log service was stopped.
        Thu 01/23/2025 8:38 AM The operating system is shutting down at system time ‎2025‎-‎01‎-‎23T14:38:42.477811000Z.
        Thu 01/23/2025 8:38 AM The operating system is shutting down at system time ‎2025‎-‎01‎-‎23T14:38:42.477811000Z.
        09:26:14:
        #*======^ UP TO LAST 7 Shutdown Events: ^======

    Demo Shutdown
    .EXAMPLE
    PS> get-lastevent -Sleep ; 

        09:26:15:
        #*======v UP TO LAST 7 Sleep Events: v======
        Time                   Message
        ----                   -------
        Mon 02/10/2025 5:34 PM The system is entering sleep....
        Fri 02/07/2025 3:21 PM The system is entering sleep....
        Thu 02/06/2025 4:18 PM The system is entering sleep....
        Wed 02/05/2025 4:20 PM The system is entering sleep....
        Sat 01/25/2025 6:40 PM The system is entering sleep....
        Fri 01/24/2025 6:01 PM The system is entering sleep....
        Thu 01/23/2025 5:46 PM The system is entering sleep....
        Wed 01/22/2025 4:52 PM The system is entering sleep....
        09:26:15:
        #*======^ UP TO LAST 7 Sleep Events: ^======

    Demo Sleep
    .EXAMPLE
    PS> get-lastevent -Wake ; 

            09:26:15:
            #*======v UP TO LAST 7 Wake Events: v======
            Time                   Message
            ----                   -------
            Tue 02/11/2025 8:09 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Mon 02/10/2025 8:39 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Mon 02/10/2025 8:18 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Fri 02/07/2025 8:37 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Thu 02/06/2025 4:18 PM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Thu 02/06/2025 8:30 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Wed 02/05/2025 8:24 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            Wed 02/05/2025 8:09 AM This computer was not able to set up a secure session with a domain controller in domain TORO due to the following: ...
            09:26:15:
            #*======^ UP TO LAST 7 Wake Events: ^======

    Demo Wake
    .EXAMPLE
    PS> get-lastevent -Logon ; 

        WARNING: No matching events
            if Logon/Security log: see [windows event log - Microsoft Teams filling Security Log with seProfileSingleProcessPrivilege - Server Fault](https://serverfault.com/questions/1115846/microsoft-teams-filling-security-log-with-seprofilesingleprocessprivilege)
        Teams chromium/Process Name: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\132.0.2957.140\msedgewebview2.exe
        spamming SecLog with 4673 events, saturating rollover of logs
        leaving *zero* events to poll, shortly after successful logon!
        (20mb rollover spec on Security log)

    Demo Logon, with typical output, since MS ruined the Security log by Teams permission model, that spams the log with 4673 evts, pushing useful logon records out on continuous rollover.
    .EXAMPLE
    PS> get-lastevent -Logoff ; 

        WARNING: No matching events
            if Logon/Security log: see [windows event log - Microsoft Teams filling Security Log with seProfileSingleProcessPrivilege - Server Fault](https://serverfault.com/questions/1115846/microsoft-teams-filling-security-log-with-seprofilesingleprocessprivilege)
        Teams chromium/Process Name: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\132.0.2957.140\msedgewebview2.exe
        spamming SecLog with 4673 events, saturating rollover of logs
        leaving *zero* events to poll, shortly after successful logon!
        (20mb rollover spec on Security log)

    Demo Logoff, with typical output, since MS ruined the Security log by Teams permission model, that spams the log with 4673 evts, pushing useful logon records out on continuous rollover.
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
    PS>  $hlastLogon=
    PS>      logname = 'Security'; 
    PS>      id = 4624 ; 
    PS>  } ;
    PS>  $evts = get-winevent -FilterHashtable $hlastLogon ; 
    Demo native get-winevent -filter for lastLogon events
    .EXAMPLE
    #Get-WinEvent -FilterHashtable @{logname = 'Security'; id = 4634}
    PS>  $hlastLogoff=@{
    PS>      logname = 'Security'; 
    PS>      id = 4634
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
            [int] $MaxEvents = 30,
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

    $prpFta =  @{Name = 'Time'; Expression = { get-date $_.TimeCreated -format 'ddd MM/dd/yyyy h:mm tt' } },'Message' ; 
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
            #ProviderName = $null ;
            ID           = 4624 ;
            #Level        = 4  ; # use of $null ProviderName & Level 4 doesn't work; Security + 4 does
            #Verbose      = $($VerbosePreference -eq 'Continue') ;
        } ;
        $filter =  $hlastLogon ;
        $Tag = "Logon" ;
        $message = $null ;
        $AMPMFilter = $null ;
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winEventsLoopedIDs w`n$(($filter|out-string).trim())" ; 
        $evts += get-winEventsLoopedIDs $filter ;
        # additional property filter specific to logon events:
        #$evts = $evts | Where-Object { $_.properties[8].value -eq 2 } ;
        # 1:09 PM 2/10/2025 above breaking now; not sure what was going after before, in the properties, but for interactive user logons, I'd want logons where $_.targetusername -ne 'SYSTEM'
        # looks like property 8, at least in xml was 'LogoinType' which is cominb back 7 & 5, not _2_, so we'll go this route
        $evts = $evts | ?{$_.targetusername -ne 'SYSTEM' -AND $_.targetusername -eq "$($env:computername)`$" } ; 
        If ($message) {$evts = $evts | Where-Object { ($_.Message -like $($message)) } } ;
    } elseif ($Logoff) {
        $hlastLogoff=@{
            logname      = "Security";
            #ProviderName = $null ;
            ID           = 4634 ;
            #Level        = 4  ;
            #Verbose      = $($VerbosePreference -eq 'Continue') ;
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
    if($evts){

        $evts = $evts | Sort-Object TimeCreated -desc | Select-Object -first $MaxEvents | Select-Object @{Name = 'Time'; Expression = { get-date $_.TimeCreated -format 'ddd MM/dd/yyyy h:mm tt' } },'TargetUserName','Message' ;
        #$evts[0..$($FinalEvents)] | write-output
        #$evts[0..$($FinalEvents)] | ft -auto;
        if($filter.logname -eq 'Security'){
            write-host $filter.logname; 
            $prpFta =  @{Name = 'Time'; Expression = { get-date $_.Time -format 'ddd MM/dd/yyyy h:mm tt' } },'TargetUserName','Message' ; 
            $sBnr="`n#*======v UP TO LAST $($FinalEvents) $($Tag) Events (non-SYSTEM): v======" ;
        } else {
            $prpFta =  @{Name = 'Time'; Expression = { get-date $_.Time -format 'ddd MM/dd/yyyy h:mm tt' } },'Message' ; 
            $sBnr="`n#*======v UP TO LAST $($FinalEvents) $($Tag) Events: v======" ;
        } ;  
        $smsg = "$((get-date).ToString('HH:mm:ss')):$($sBnr)" ;
        #$smsg += "`n$(($evts[0..$($FinalEvents)] | Format-Table -auto |out-string).trim())" ;
        $smsg += "`n$(($evts[0..$($FinalEvents)] | Format-Table -auto $prpFta |out-string).trim())" ;
        $smsg += "`n$((get-date).ToString('HH:mm:ss')):$($sBnr.replace('=v','=^').replace('v=','^='))`n" ;
        write-host -foregroundcolor green $smsg ;
    } else {
        $smsg = "No matching events" ; 
        $smsg += "`n if Logon/Security log: see [windows event log - Microsoft Teams filling Security Log with seProfileSingleProcessPrivilege - Server Fault](https://serverfault.com/questions/1115846/microsoft-teams-filling-security-log-with-seprofilesingleprocessprivilege)" ; 
        $smsg += "`nTeams chromium/Process Name: C:\Program Files (x86)\Microsoft\EdgeWebView\Application\132.0.2957.140\msedgewebview2.exe"
        $smsg += "`nspamming SecLog with 4673 events, saturating rollover of logs" ; 
        $smsg += "`nleaving *zero* events to poll, shortly after successful logon!" ; 
        $smsg += "`n(20mb rollover spec on Security log)" ; 
        Write-Warning $smsg ; 
    } ; 
    #endregion
}

#*------^ get-LastEvent.ps1 ^------