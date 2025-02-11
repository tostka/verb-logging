#*------v get-winEventsLoopedIDs.ps1 v------
function get-winEventsLoopedIDs {
    <#
    .SYNOPSIS
    get-winEventsLoopedIDs - get-winevent -filterhashtable paremeter supports an array in the ID key, but I want MaxEvents _per event_ filtered, not overall (total most recent 7 drawn from most recent 14 of each type, sorted by date). This function pulls the ID array off and loops & aggregates the events, sorts on time, and returns the most recent x. 
    .NOTES
    Version     : 1.0.11.0
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
    * 9:10 AM 2/11/2025 minor rem'd cleanup
    * 3:09 PM 2/10/2025 splice in xml-expanded evt properties (rather than positional Properties[8]): from: [POSH/MS Windows Event properties: Enumeration : r/PowerShell](https://www.reddit.com/r/PowerShell/comments/1bhevkc/poshms_windows_event_properties_enumeration/)
        was demo code snippet from [BlackV](https://www.reddit.com/user/BlackV/); 
        Updated to fix borked get-lastevent -logon; found Teams is spamming Sec log with 4673 errors, rolling over prematurely (details in Description);
        rem'd -FinalEvents
    * 12:28 PM 7/7/2022 updated CBH syn/desc to more accurately reflect function
    * 8:11 AM 3/9/2020 added verbose support & verbose echo'ing of hash values
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 1:11 PM 3/6/2020 init
    .DESCRIPTION
    get-winEventsLoopedIDs -filterhashtable supports an array in the ID key, but I want MaxEvents _per event_ filtered, not overall (total most recent 7 drawn from most recent 14 of each type, sorted by date). Passed a -filter hashtable, this function pulls the ID array off and loops & aggregates the events, sorts on time, and returns the most recent x of each ID. 
    .PARAMETER MaxEvents
    Maximum # of events to poll for each event specified -MaxEvents 14]
    .PARAMETER Filter
    get-WinEvents -FilterHashtable hash obj to be queried to return matching events[-filter `$hashobj]
    A typical hash of this type, could look like: @{logname='System';id=6009 ;ProviderName='EventLog';Level=4;}S
    Corresponding to a search of the System log, EventLog source, for ID 6009, of Informational type (Level 4).
    .EXAMPLE
    PS> [array]$evts = @() ;
    PS> $hlastShutdown=@{logname = 'System'; ProviderName = $null ;  ID = '13','6008','13','6008','6006' ; Level = 4 ; } ;
    PS> $evts += get-winEventsLoopedIDs -filter $hlastShutdown -MaxEvents ;
    Demo raw underlying query code: The above runs a collection pass for each of the ID's specified above (which are associated with shutdowns),
    returns the 14 most recent of each type, sorts the aggregate matched events on timestamp, and returns the most
    recent 7 events of any of the matched types.
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage = "Maximum # of events to poll for each event specified[-MaxEvents 14]")]
            [int] $MaxEvents = 30,
        # not used, do $FinalEvents filtering in the outputs
        #[Parameter(HelpMessage = "Final # of sorted events of all types to return [-FinalEvents 7]")]
        #    [int] $FinalEvents = 7,
        [Parameter(Position=0,Mandatory=$True,HelpMessage="get-WinEvents -FilterHashtable hash obj to be queried to return matching events[-filter `$hashobj]")]
        $Filter
    ) ;
    [CmdletBinding()]
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $EventProperties ="timecreated","id","leveldisplayname","message" ;
    $tIDs = $filter.ID ;
    $filter.remove('Verbose') ; 
    $pltWinEvt=@{
        FilterHashtable=$null;
        MaxEvents=$MaxEvents;
        Verbose=$($VerbosePreference -eq 'Continue') ;
        erroraction=0 ;
    } ;
    foreach($ID in $tIDs){
        $filter.ID = $id ;
        # purge empty values (throws up on ProviderName:$null)
        $filter | ForEach-Object {$p = $_ ;@($p.GetEnumerator()) | Where-Object{ ($_.Value | Out-String).length -eq 0 } | Foreach-Object {$p.Remove($_.Key)} ;} ;
        $pltWinEvt.FilterHashtable = $filter ; 
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winevent w`n$(($pltWinEvt|out-string).trim())`n`n`Expanded -filterhashtable:$(($filter|out-string).trim())" ; 
        #$evts += get-winevent @pltWinEvt | Select-Object $EventProperties ;
        # filtering $EventProperties strips out the $Properties[8] that you post filter for Logon events, and IP Addresses; try returning them raw
        $evts += get-winevent @pltWinEvt # | Select-Object $EventProperties ;
        # n
        $Results = foreach ($SingleEvent in $evts) {
            $xmldoc = [xml]($SingleEvent.toxml())
            <# full propertries on a logon event
            $xmldoc.event.EventData.Data

            Name                      #text                                 
            ----                      -----                                 
            SubjectUserSid            S-1-5-18                              
            SubjectUserName           xxx-9x5xxx3$                          
            SubjectDomainName         DOMAIN                                  
            SubjectLogonId            0x3e7                                 
            TargetUserSid             S-1-5-18                              
            TargetUserName            SYSTEM                                
            TargetDomainName          NT AUTHORITY                          
            TargetLogonId             0x3e7                                 
            LogonType                 5                                     
            LogonProcessName          Advapi                                
            AuthenticationPackageName Negotiate                             
            WorkstationName           -                                     
            LogonGuid                 {00000000-0000-0000-0000-000000000000}
            TransmittedServices       -                                     
            LmPackageName             -                                     
            KeyLength                 0                                     
            ProcessId                 0x3a4                                 
            ProcessName               C:\Windows\System32\services.exe      
            IpAddress                 -                                     
            IpPort                    -                                     
            ImpersonationLevel        %%1833                                
            RestrictedAdminMode       -                                     
            TargetOutboundUserName    -                                     
            TargetOutboundDomainName  -                                     
            VirtualAccount            %%1843                                
            TargetLinkedLogonId       0x0                                   
            ElevatedToken             %%1842

            #>
            #[pscustomobject]@{
            # lets 2step it
            $logonprops = [ordered]@{
                LogName         = $SingleEvent.LogName ; 
                ProviderName    = $SingleEvent.ProviderName
                EventID         = $SingleEvent.id
                Level           = $SingleEvent.Level
                LevelDisplayName= $SingleEvent.LevelDisplayName
                MachineName     = $SingleEvent.MachineName
                ProcessId       = $SingleEvent.ProcessId
                TimeCreated     = $SingleEvent.TimeCreated
                TaskDisplayName = $SingleEvent.TaskDisplayName
                Message         = $SingleEvent.Message
                #ObjectName      = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'ObjectName'}).'#text'
                #HandleId        = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'HandleId'}).'#text'
                ProcessName     = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'ProcessName'}).'#text' ; 
                SubjectUserName = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'SubjectUserName'}).'#text' ; 
                SubjectDomainName = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'SubjectDomainName'}).'#text' ; 
                TargetUserName = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'TargetUserName'}).'#text' ; 
                TargetDomainName = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'TargetDomainName'}).'#text' ; 
                LogonType = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'LogonType'}).'#text' ; 
                LogonProcessName = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'LogonProcessName'}).'#text' ; 
                IpAddress = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'IpAddress'}).'#text' ; 
                IpPort = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'IpPort'}).'#text' ; 
                ElevatedToken = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'ElevatedToken'}).'#text' ; 
                #KeywordsDisplayNames = ($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'KeywordsDisplayNames'}).'#text'
            }; 
            # HandleId
            if($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'HandleId'}){
                $logonprops.add('HandleId',$xmldoc.event.eventdata.Data.HandleId) ;     
            } ; 
            # KeywordsDisplayNames
            if($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'KeywordsDisplayNames'}){
                $logonprops.add('HandleId',$xmldoc.event.eventdata.Data.KeywordsDisplayNames) ;  
            } ; 
            # ObjectName
            if($xmldoc.event.eventdata.Data |  ?{$_.name -eq 'ObjectName'}){
                $logonprops.add('HandleId',$xmldoc.event.eventdata.Data.ObjectName) ;   
            } ; 

            [pscustomobject]$logonprops ; 
        } ;
    } ; 
    $evts = $Results | Sort-Object TimeCreated -desc ; 
    $evts | write-output ;
} ;
#*------^ get-winEventsLoopedIDs.ps1 ^------
