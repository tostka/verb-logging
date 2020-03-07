#*----------------v Function get-EventsFiltered v------
function get-EventsFiltered {
    <#
    .SYNOPSIS
    get-EventsFiltered() - DESC
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 1:54 PM 3/6/2020 roughed-in, untested. Intent was to use it in place of what wound up being get-winEventsLoopedIDs - which has a much simpler subset of params & features, but got the job done.
    .DESCRIPTION
    XXX - XXX
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .PARAMETER Whatif
    Parameter to run a Test no-change pass, and log results [-Whatif switch]
    .PARAMETER ShowProgress
    Parameter to display progress meter [-ShowProgress switch]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass, and log results [-Whatif switch]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.

    .LINK
    #>

    ##Requires -Version 2.0
    ##Requires -Version 3
    ##requires -PSEdition Desktop
    ##requires -PSEdition Core
    ##Requires -PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
    ##Requires -Modules ActiveDirectory,  Azure,  AzureAD,  AzureRM,  GroupPolicy,  Lync,  Microsoft.Online.SharePoint.PowerShell,  MSOnline,  ScheduledTasks,  SkypeOnlineConnector
    ##Requires -RunasAdministrator
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("(lyn|bcc|spb|adl)ms6(4|5)(0|1).(china|global)\.ad\.toro\.com")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    # retain minimum Param() to have $verbosepref updated by -verbose call
    PARAM (
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,
        Mandatory=$True,HelpMessage="LogName[-LogName System]")]
        [ValidateNotNull()]
        [string[]]$LogName,
        [parameter(Mandatory=$True,HelpMessage="ID[-ID 4740]")]
        [ValidateNotNull()]
        [int]$ID,
        [parameter(HelpMessage="ProviderName[-ProviderName EventLog]")]
        [ValidateNotNull()]
        [string[]]$ProviderName,
        [parameter(HelpMessage="Message text to be matched [-Message '*sleep*']")]
        [string[]]$Message,
        [parameter(HelpMessage="TypeName (Legacy text alt to Level)[-Type Error]")]
        [ValidateSet("LogAlways","Critical","Error","Warning","Informational","Verbose")]
        [string[]]$Type,
        [parameter(Mandatory=$True,HelpMessage="Level (numeric 'Type')[-Level 2]")]
        [ValidateRange(0,5)]
        [int]$Level,
        [parameter(Mandatory=$True,HelpMessage="Level[-ID 4740]")]
        [int]$MaxEvents,
        [parameter(Mandatory=$True,HelpMessage="StartTime[-StartTime xxx]")]
        [ValidateNotNull()]
        $StartTime,
        [parameter(Mandatory=$True,HelpMessage="StartTime[-StartTime xxx]")]
        [ValidateNotNull()]
        $EndTime,
        [parameter(HelpMessage="TypeName (Legacy text alt to Level)[-Type Error]")]
        [ValidateSet("AM","PM")]
        [string[]]$AMPMFilter,
        [Parameter(HelpMessage="Failure Audit[-FailureAudit]")]
        [switch] $FailureAudit ,
        [Parameter(HelpMessage="Success audit[-SuccessAudit]")]
        [switch] $SuccessAudit,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    ) ;

    BEGIN {
        $Verbose = ($VerbosePreference -eq 'Continue') ; # if using explicit write-verbose -verbose, this converts the vPref into a usable vari in those lines
        $sBnr="#*---===v Function: $($MyInvocation.MyCommand) v===---" ;
        $smsg= "$($sBnr)" ;
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;

    }  # BEG-E ;

    PROCESS {
            if($StartTime){$StartTime = get-date $StartTime} ;
            if($EndTime){$EndTime = get-date $StartTime} ;

            if($host.version.major -ge 3){$FilterHashtable=[ordered]@{Dummy = $null } ;
            } else {$FilterHashtable = New-Object Collections.Specialized.OrderedDictionary } ;
            If($FilterHashtable.Contains("Dummy")){$FilterHashtable.remove("Dummy")} ;
            $FilterHashtable.Add("LogName",$LogName) ;

            if($host.version.major -ge 3){$pltWinEvt=[ordered]@{Dummy = $null } ;
            } else {$pltWinEvt = New-Object Collections.Specialized.OrderedDictionary } ;
            If($pltWinEvt.Contains("Dummy")){$pltWinEvt.remove("Dummy")} ;
            $pltWinEvt.Add("ErrorAction",0) ;

            if($ID){$FilterHashtable.add('ID',$ID) } ;
            if($ProviderName){$FilterHashtable.add('ProviderName',$ProviderName)} ;
            if($Message){$FilterHashtable.add('Message',$Message) } ;
            if($Type){
                switch ($Type) {
                    "Verbose" { $FilterHashtable.add("Level", 5) }
                    "Informational" { $spltEvt.add("Level", 4) }
                    "Warning" { $spltEvt.add("Level", 3) }
                    "Error" { $spltEvt.add("Level", 2) }
                    "Critical" { $spltEvt.add("Level", 1) }
                    "LogAlways" { $spltEvt.add("Level", 0) }
                } ;
            } ;
            if($Level){$FilterHashtable.add('Level',$Level) } ;
            if($FailureAudit){$FilterHashtable.add('Level',$Level) } ;
            if($Level){$FilterHashtable.add('Level',$Level) } ;
            if($StartTime){$FilterHashtable.add('StartTime',$StartTime) } ;
            if($EndTime){$FilterHashtable.add('EndTime',$EndTime) } ;

            if($MaxEvents){$pltWinEvt.add('MaxEvents',$MaxEvents) } ;

            if($FailureAudit){$pltWinEvt.add('Keywords','4503599627370496') } ;
            if($SuccessAudit){$pltWinEvt.add('Keywords','9007199254740992') } ;

            if($MaxEvents){$pltWinEvt.add('MaxEvents',$MaxEvents) ;

            # add the completed FilterHashtable to the splat
            $pltWinEvt.add('FilterHashtable',$FilterHashtable) ;

            $error.clear() ;
            $continue = $true ;
            $PriorEAPref = $ErrorActionPreference ;
            TRY {
                $ErrorActionPreference = "Stop" ;
                write-verbose -verbose:$verbose "$((get-date).ToString('HH:mm:ss')):get-winevent w`n$(($pltWinEvt|out-string).trim())`nw FilterHashtable:`n$(($FilterHashtable|out-string).trim())`n" ;

                $evts = get-winevent @pltWinEvt | Sort-Object TimeCreated -desc ;

                if ($AMPMFilter -eq "AM") {
                    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):Note: filtering AM events" ;
                    $evts = $evts | Where-Object { (get-date -date $_.TimeCreated -Uformat %p) -eq "AM" } ;
                } ;

                $evts | write-output ;



            } CATCH {
                $ErrTrpd = $_ ;
                $smsg = "Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Exit #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
            } ;
            $ErrorActionPreference = $PriorEAPref ;


        } # loop-E ;
    } # PROC-E ;

    END {
        $smsg= "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ; # END-E
} #*----------------^ END Function get-EventsFiltered ^--------
