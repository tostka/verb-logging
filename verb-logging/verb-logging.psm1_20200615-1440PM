# verb-logging.psm1


  <#
  .SYNOPSIS
  verb-logging - Logging-related generic functions
  .NOTES
  Version     : 1.0.46.0
  Author      : Todd Kadrie
  Website     :	https://www.toddomation.com
  Twitter     :	@tostka
  CreatedDate : 2/18/2020
  FileName    : verb-logging.psm1
  License     : MIT
  Copyright   : (c) 2/18/2020 Todd Kadrie
  Github      : https://github.com/tostka
  AddedCredit : REFERENCE
  AddedWebsite:	REFERENCEURL
  AddedTwitter:	@HANDLE / http://twitter.com/HANDLE
  REVISIONS
  * 7:47 AM 3/9/2020 reworked get-winEventsLoopedIDs; added Verbose support across all get-last*()
  * 2/18/2020 - 1.0.0.0
  # 8:33 AM 2/18/2020 get-ArchivePath: shifted paths into global varis in profile, duped/renamed for module as VERB-LOGGING -> verb-logging
  # 11:38 AM 12/30/2019 ran vsc alias-expan ; updated Usage block to cover below
  * 12:03 PM 12/29/2019 added Start-Log, added else wh on pswls entries
  * 11:35 AM 8/26/2019 Write-Log: fixed missing noecho parameter desig in comment help
  * 12:51 PM 6/5/2019 added latkin's ColorMatch highlit write-host variant
  * 11:32 AM 2/28/2019 added write-log support to demo below, also moved the start-trans* up above module loads, to capture fails there
  * 9:31 AM 2/15/2019:Write-Log: added Level:Debug support, and broader init
              block example with $whatif & $ticket support, added -NoEcho to suppress console
              echos and just use it for writing logged output
  * 8:57 PM 11/25/2018 Write-Log:shifted copy to verb-transcript, added defer to scope $script versions
  * 8:13 AM 10/2/2018 Cleanup():make it defer to existing script-copy, ren'd $bdebug -> $showdebug
  * 2:37 PM 9/19/2018 fixed a filename invocation bug in Start-IseTranscript ; added CleanUp() example (with archivevelog disabled), formalized notes block, w demo load
  * 11:29 AM 11/1/2017 initial version
  .DESCRIPTION
  verb-logging - Logging-related generic functions
  .LINK
  https://github.com/tostka/verb-logging
  #>


$script:ModuleRoot = $PSScriptRoot ;
$script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;

#*======v FUNCTIONS v======



#*------v Archive-Log.ps1 v------
function Archive-Log {
    <#.SYNOPSIS
    ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .NOTES
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() function

    REVISIONS   :
    # 9:15 AM 4/24/2015 shifted all $archpath detection code out to separate get-ArchivePath()
    # 2:49 PM 4/23/2015 recast $ArchPath as $archPath script scope
    # 9:39 AM 4/13/2015 tightened up formatting, crushed lines ; update-RetiringConfRmWindows-prod-tests-20150413-0917AM.ps1 version
    # 7:30 AM 1/28/2015 in use in LineURI script
    # 10:37 AM 1/21/2015 moved out of the if\else
    # 1:44 PM 1/16/2015 repurposed from Stop-TranscriptLog, focused this on just moving to archive location
    # 1:18 PM 1/14/2015 added Lync fs rpt share support ; added Lync FS support ; added lab support (lynms650d\d$)
    # 10:48 AM 1/14/2015 adde lab support for archpath ; tshot Archive-Log archmove, for existing file clashes
    # 9:04 AM 12/10/2014 shifted more into the try block
    #12:49 PM 12/9/2014 init
    .INPUTS
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    Archive-Log
    #>

    Param([parameter(Mandatory=$true)] $FilePath) ;

    if ($showdebug) {"Archive-Log"}
    if(!(Test-Path $FilePath)) {
      write-host -foregroundcolor yellow  "$((get-date).ToString('HH:mm:ss')):Specified file...`n$Filepath`n NOT FOUND! ARCHIVING FAILED!";
    } else {
      # valid filepath passed in
      Try {
          if ($showdebug) {
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`$archPath:$archPath `n" ;
            write-host -foregroundcolor green "`$FilePath:$FilePath"
          };

          if ((Test-Path $FilePath)) {
            write-host  ("$((get-date).ToString('HH:mm:ss')):Moving `n$FilePath `n to:" + $archPath)

            # 9:59 AM 12/10/2014 pretest for clash

            $ArchTarg = (Join-Path $archPath (Split-Path $FilePath -leaf));
            if ($showdebug) {write-host -foregroundcolor green "`$ArchTarg:$ArchTarg"}
            if (Test-Path $ArchTarg) {
                $FilePathObj = Get-ChildItem $FilePath;
                $ArchTarg = (Join-Path $archPath ($FilePathObj.BaseName + "-B" + $FilePathObj.Extension))
                if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):CLASH DETECTED, RENAMING ON MOVE: `n`$ArchTarg:$ArchTarg"};
                Move-Item $FilePath $ArchTarg
            } else {
                # 8:41 AM 12/10/2014 add error checking
                $error.Clear()
                Move-Item $FilePath $archPath
            } # if-E
          } else {
            if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):NO TRANSCRIPT FILE FOUND! SKIPPING MOVE"}
          }  # if-E

      } # TRY-E
      Catch {
              Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to move `n$FilePath to `n$archPath"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
              Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
              Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
      } ;
      if (!(Test-Transcribing)) {  return $true } else {return $false};
    } # if-E Filepath test
}

#*------^ Archive-Log.ps1 ^------

#*------v Cleanup.ps1 v------
if(test-path function:Cleanup){
    "(deferring to `$script:cleanup())" ;
} else {
    "(using default verb-logging:cleanup())" ;
    function Cleanup {
        # clear all objects and exit
        # Clear-item doesn't seem to work as a variable release
        # 3:18 PM 2/13/2019 Cleanup: add in the smtp mailer and Change/Error report mailing code from maintain-exombxretentionpolicies.ps1
        # 8:15 AM 10/2/2018 Cleanup:make it defer to $script:cleanup() (needs to be preloaded before verb-transcript call in script), added missing semis, replaced all $bDebug -> $showDebug
        # 2:02 PM 9/21/2018 missing $timestampnow, hardcode
        # 8:45 AM 10/13/2015 reset $DebugPreference to default SilentlyContinue, if on
        # # 8:46 AM 3/11/2015 at some time from then to 1:06 PM 3/26/2015 added ISE Transcript
        # 8:39 AM 12/10/2014 shifted to stop-transcriptLog function
        # 7:43 AM 1/24/2014 always stop the running transcript before exiting
        if ($showdebug) {"CLEANUP"} ;
        #stop-transcript ;
        if($host.Name -eq "Windows PowerShell ISE Host"){
            # 8:46 AM 3/11/2015 shift the logfilename gen out here, so that we can arch it
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
            # 2:16 PM 4/27/2015 shift to static timestamp $timeStampNow
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + $timeStampNow + "-ISEtrans.log")) ;
            # 2:02 PM 9/21/2018 missing $timestampnow, hardcode
            $Logname=(join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -format 'yyyyMMdd-HHmmtt') + "-ISEtrans.log")) ;
            $smsg= "`$Logname: $Logname";
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

            Start-iseTranscript -logname $Logname ;
            #Archive-Log $Logname ;
            # 1:23 PM 4/23/2015 standardize processing file so that we can send a link to open the transcript for review
            $transcript = $Logname ;
        } else {
            if($showdebug){ write-debug "$(get-timestamp):Stop Transcript" };
            Stop-TranscriptLog ;
            #if($showdebug){ write-debug "$(get-timestamp):Archive Transcript" };
            #Archive-Log $transcript ;
        } # if-E

        if($whatif){
            $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
            $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
            $Logname=$Logname.replace("-BATCH","-BATCH-WHATIF") ;

        } else {
            $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
            $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
            $Logname=$Logname.replace("-BATCH","-BATCH-EXEC") ;
        } ;

        # 12:09 PM 4/26/2017 need to email transcript before archiving it
        if($showdebug){
            $smsg= "Mailing Report"
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        };

        #$smtpSubj= "Proc Rpt:$($ScriptBaseName):$(get-date -format 'yyyyMMdd-HHmmtt')"   ;

        #Load as an attachment into the body text:
        #$body = (Get-Content "path-to-file\file.html" ) | converto-html ;
        #$SmtpBody += ("Pass Completed "+ [System.DateTime]::Now + "`nResults Attached: " +$transcript) ;
        # 4:07 PM 10/11/2018 giant transcript, no send
        #$SmtpBody += "Pass Completed $([System.DateTime]::Now)`nResults Attached:($transcript)" ;
        $SmtpBody += "Pass Completed $([System.DateTime]::Now)`nTranscript:($transcript)" ;
        # 12:55 PM 2/13/2019 append the $PassStatus in for reference
        if($PassStatus ){
            $SmtpBody += "`n`$PassStatus triggers:: $($PassStatus)`n" ;
        } ;
        $SmtpBody += "`n$('-'*50)" ;
        #$SmtpBody += (gc $outtransfile | ConvertTo-Html) ;
        # name $attachment for the actual $SmtpAttachment expected by Send-EmailNotif
        #$SmtpAttachment=$transcript ;
        # 1:33 PM 4/28/2017 test for ERROR|CHANGE - actually non-blank, only gets appended to with one or the other
        if($PassStatus ){
            Send-EmailNotif ;
        } else {
            $smsg= "No Email Report: `$Passstatus is $null" ;
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        } ;

        #11:10 AM 4/2/2015 add an exit comment
        $smsg= "END $BARSD4 $scriptBaseName $BARSD4"  ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        $smsg= "$BARSD40" ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        # finally restore the DebugPref if set
        if ($ShowDebug -OR ($DebugPreference = "Continue")) {
            $smsg= "Resetting `$DebugPreference from 'Continue' back to default 'SilentlyContinue'" ;
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

            $showdebug=$false ;
            # 8:41 AM 10/13/2015 also need to enable write-debug output (and turn this off at end of script, it's a global, normally SilentlyContinue)
            $DebugPreference = "SilentlyContinue" ;
        } # if-E

        $smsg= "#*======^ END PASS:$($ScriptBaseName) ^======" ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

        EXIT ;
    } ;
}

#*------^ Cleanup.ps1 ^------

#*------v get-ArchivePath.ps1 v------
function get-ArchivePath {
    <#.SYNOPSIS
    ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .NOTES
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() function
    REVISIONS   :
    # 8:33 AM 2/18/2020 get-ArchivePath: shifted paths into global varis in profile
    # 8:52 AM 4/24/2015 shifted internal func vari name from $archPath to $ArchiveLocation, to avoid overlap clash/confusion ; shifted archpath detection code out of send-mailmessage and archive-log, into get-ArchivePath()
    # 2:49 PM 4/23/2015 recast $ArchPath as $archPath script scope
    # 9:39 AM 4/13/2015 tightened up formatting, crushed lines ; update-RetiringConfRmWindows-prod-tests-20150413-0917AM.ps1 version
    # 7:30 AM 1/28/2015 in use in LineURI script
    # 10:37 AM 1/21/2015 moved out of the if\else
    # 1:44 PM 1/16/2015 repurposed from Stop-TranscriptLog, focused this on just moving to archive location
    # 1:18 PM 1/14/2015 added Lync fs rpt share support ; adde Lync FS support ; added lab support ; added lab support for archpath
    # 10:11 AM 12/10/2014 tshot get-ArchivePath archmove, for existing file clashes ; shifted more into the try block
    #12:49 PM 12/9/2014 init
    .INPUTS
    leverages the global $transcript variable (must be set in the root script; not functions)
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    $archPath = get-ArchivePath ;
    Retrieve the functional Archivepath into a variable.
    #>

    # 11:57 AM 4/24/2015update, no params, this returns a value, but needs nothing
    #   [parameter(Mandatory=$true)]$FilePath

    Param() ;

        # moved to globals in profile
        $gVaris = "ArchPathProd","ArchPathLync","ArchPathLab","ArchPathLabLync","rgxRestrictedNetwork" ;
        foreach($gVari in $gVaris){
            if(-not(get-variable $gVari -scope Global)){
                $smsg = "Undefined `$global:$($gvari) variable!. ABORTING!" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Exit ;
            } ;
        } ;

        if ($showdebug) { write-verbose "$((get-date).ToString('HH:mm:ss')) Start get-ArchivePath" -Verbose:$verbose}

        # if blocked for SMB use custom arch server for reporting
        $IPs=get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress ;
        $IPs | ForEach-Object {
            if ($_.ipaddress -match $rgxRestrictedNetwork){
                # server with blocks to SMB to archserver
                if ($showdebug) {write-host -foregroundcolor yellow  "$((get-date).ToString('HH:mm:ss')):Restricted Subnet Detected. Using Lync ArchPath";};

                if($env:USERDOMAIN -eq $domLab){
                    if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLabLync"};
                    # lync Edge or FE server
                    if(test-path $ArchPathLabLync) {
                        $ArchiveLocation = $ArchPathLabLync;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lab Lync `$ArchiveLocation. Exiting.";
                        exit
                    };  # if-E
                } else {
                    # non-lab prod Lync
                    if(test-path $ArchPathLync) {
                        $ArchiveLocation =$ArchPathLync;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lync `$ArchiveLocation. Exiting.";
                        exit
                    }; # if-E non-lab
                }; # lync lab or prod
            } else {
                # non-Lync/restricted subnet
                if($env:USERDOMAIN -eq $domLab){
                    if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLab"};
                    # lync Edge or FE server
                    if(test-path $ArchPathLab) {
                        $ArchiveLocation = $ArchPathLab;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lab `$ArchiveLocation. Exiting.";
                        #Cleanup; # nope, cleanup normally CALLS STOP-TRANSLOG
                        exit
                    };  # if-E
                    } else {
                    # non-lab prod
                    if(test-path $ArchPathProd) {
                        $ArchiveLocation =$ArchPathProd;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Prod `$ArchiveLocation. Exiting.";
                        exit
                    };  # if-E
                }; # if-E non-lab
            }; # if-E restricted subnet test
        };  # loop-E $IPs
        if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`$ArchiveLocation:$ArchiveLocation"};

        Try {
            # validate the archpath
            if (!(Test-Path $ArchiveLocation)) {
                # gui prompt
                $ArchiveLocation = [Microsoft.VisualBasic.Interaction]::InputBox("Input ArchPath[UNCPath]", "Archpath", "") ;
            }
            if($showdebug){Write-Verbose "$((get-date).ToString('HH:mm:ss'))End get-ArchivePath" -Verbose:$verbose} ;
            # 2:21 PM 4/24/2015 try flattening in here.
            if($ArchiveLocation -is [system.array]){
                write-verbose "Flattening in get-ArchivePath" -verbose:$verbose ;
                $ArchiveLocation = $ArchiveLocation[0]
            } # if-E
            Return $ArchiveLocation

        } # TRY-E
        Catch {
                Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to move `n$FilePath to `n$ArchiveLocation"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
                Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
        } ;

}

#*------^ get-ArchivePath.ps1 ^------

#*------v get-EventsFiltered.ps1 v------
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
}

#*------^ get-EventsFiltered.ps1 ^------

#*------v get-lastboot.ps1 v------
function get-lastlogon {[CmdletBinding()]PARAM() ; get-lastevent -Logon -Verbose:$($VerbosePreference -eq 'Continue') }

#*------^ get-lastboot.ps1 ^------

#*------v get-LastEvent.ps1 v------
function get-lastevent {
    <#
    .SYNOPSIS
    get-lastevent - return the last 7 wake events on the local pc
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
    * 7:47 AM 3/9/2020 reworked get-winEventsLoopedIDs; added Verbose support across all get-last*()
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 7:19 AM 3/6/2020 rewriting to consolidate several get-lastxxx, with params to tag the variants, and an alias/function to deliver the matching names
    # 11:16 AM 1/5/2017 fixed # in report ; expanded returns: returning 14, but use only last 7 ; reworked on new event, and added AM/PM filtering to the events ; corrected echo to reflect wake, not sleep, added reference to the NETLOGON 5719 that might be a better target for below
    # 1:44 PM 10/3/2016 ported from get-lastsleep
    # vers: 7:17 AM 8/26/2014 corrected date fmt string
    # ver: 2:48 PM 8/25/2014 - fixed output to display day of week as well
    .DESCRIPTION
    get-lastevent - return the last 7 sleep/wake/shutdown/bootup events on the local pc

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
    Return most recent Logoff events [-Logon]
    .EXAMPLE
    get-lastevent -Shutdown -verbose
    Get last Shutdown events w verbose output
    .EXAMPLE
    get-lastevent -Bootup 
    Get last Bootup events w verbose output
    .EXAMPLE
    get-lastevent -Sleep 
    Get last Sleep events w verbose output
    .EXAMPLE
    get-lastevent -Wake 
    Get last Wake events w verbose output
    .EXAMPLE
    get-lastevent -Logoff
    Return most recent Logoff events [-Logon]
    .LINK
    https://github.com/tostka/verb-logging
    #>
    ##Requires -Module verb-Logging
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage = "Maximum # of events to poll for each event specified[-MaxEvents 14]")]
        [int] $MaxEvents = 14,
        [Parameter(HelpMessage = "Final # of sorted events of all types to return [-FinalEvents 7]")]
        [int] $FinalEvents = 7,
        [Parameter(HelpMessage="Return most recent Bootup events [-Bootup]")]
        [switch] $Bootup,
        [Parameter(HelpMessage="Return most recent Shutdown events [-Shutdown]")]
        [switch] $Shutdown,
        [Parameter(HelpMessage="Return most recent Sleep events [-Sleep]")]
        [switch] $Sleep,
        [Parameter(HelpMessage="Return most recent Wake events [-Wake]")]
        [switch] $Wake,
        [Parameter(HelpMessage="Return most recent Logon events [-Logon]")]
        [switch] $Logon,
        [Parameter(HelpMessage="Return most recent Logoff events [-Logon]")]
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
        $hlastLogon=@{
            logname      = "Security";
            ProviderName = $null ;
            ID           = 4634 ;
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

#*------v get-lastlogon.ps1 v------
function get-lastlogon {get-lastevent -Logon }

#*------^ get-lastlogon.ps1 ^------

#*------v get-lastshutdown.ps1 v------
function get-lastshutdown {[CmdletBinding()]PARAM() ; get-lastevent -Shutdown -Verbose:$($VerbosePreference -eq 'Continue') }
if (!(get-alias -name "gls" -ea 0 )) { Set-Alias -Name 'gls' -Value 'get-lastshutdown' ; }

#*------^ get-lastshutdown.ps1 ^------

#*------v get-lastsleep.ps1 v------
function get-lastsleep {[CmdletBinding()]PARAM() ; get-lastevent -Sleep -Verbose:$($VerbosePreference -eq 'Continue') }

#*------^ get-lastsleep.ps1 ^------

#*------v get-lastwake.ps1 v------
function get-lastwake {[CmdletBinding()]PARAM() ; get-lastevent -Wake -Verbose:$($VerbosePreference -eq 'Continue') }

#*------^ get-lastwake.ps1 ^------

#*------v get-winEventsLoopedIDs.ps1 v------
function get-winEventsLoopedIDs {
    <#
    .SYNOPSIS
    get-lastevent - return the last 7 wake events on the local pc
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
    * 8:11 AM 3/9/2020 added verbose support & verbose echo'ing of hash values
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 1:11 PM 3/6/2020 init
    .DESCRIPTION
    get-winevents -filterhashtable supports an array in the ID field, but I want MaxEvents _per event_ filtered,
    not overall (total most recent 7 drawn from most recent 14 of each type, sorted by date)
    This function pulls the ID array off and loops & aggregate the events,
    sorts on time, and returns the most recent x
    .PARAMETER MaxEvents
    Maximum # of events to poll for each event specified -MaxEvents 14]
    .PARAMETER FinalEvents
    Final # of sorted events of all types to return [-FinalEvents 7]
    .PARAMETER Filter
    get-WinEvents -FilterHashtable hash obj to be queried to return matching events[-filter `$hashobj]
    A typical hash of this type, could look like: @{logname='System';id=6009 ;ProviderName='EventLog';Level=4;}
    Corresponding to a search of the System log, EventLog source, for ID 6009, of Informational type (Level 4).
    .EXAMPLE
    [array]$evts = @() ;
    $hlastShutdown=@{logname = 'System'; ProviderName = $null ;  ID = '13','6008','13','6008','6006' ; Level = 4 ; } ;
    $evts += get-winEventsLoopedIDs -filter $hlastShutdown -MaxEvents ;
    The above runs a collection pass for each of the ID's specified above (which are associated with shutdowns),
    returns the 14 most recent of each type, sorts the aggregate matched events on timestamp, and returns the most
    recent 7 events of any of the matched types.
    .LINK
    https://github.com/tostka/verb-logging
    #>
    PARAM(
        [Parameter(HelpMessage = "Maximum # of events to poll for each event specified[-MaxEvents 14]")]
        [int] $MaxEvents = 14,
        [Parameter(HelpMessage = "Final # of sorted events of all types to return [-FinalEvents 7]")]
        [int] $FinalEvents = 7,
        [Parameter(Position=0,Mandatory=$True,HelpMessage="get-WinEvents -FilterHashtable hash obj to be queried to return matching events[-filter `$hashobj]")]
        $Filter
    ) ;
    $EventProperties ="timecreated","id","leveldisplayname","message" ;
    $tIDs = $filter.ID ;
    $filter.remove('Verbose') ; 
    $pltWinEvt=@{
        FilterHashtable=$null;
        MaxEvents=$MaxEvents ;
        Verbose=$($VerbosePreference -eq 'Continue') ;
        erroraction=0 ;
    } ;
    foreach($ID in $tIDs){
        $filter.ID = $id ;
        # purge empty values (throws up on ProviderName:$null)
        $filter | ForEach-Object {$p = $_ ;@($p.GetEnumerator()) | Where-Object{ ($_.Value | Out-String).length -eq 0 } | Foreach-Object {$p.Remove($_.Key)} ;} ;
        $pltWinEvt.FilterHashtable = $filter ; 
        write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):get-winevent w`n$(($pltWinEvt|out-string).trim())`n`n`Expanded -filterhashtable:$(($filter|out-string).trim())" ; 
        $evts += get-winevent @pltWinEvt | Select-Object $EventProperties ;
    } ;
    $evts = $evts | Sort-Object TimeCreated -desc ; 
    $evts | write-output ;
}

#*------^ get-winEventsLoopedIDs.ps1 ^------

#*------v Start-IseTranscript.ps1 v------
Function Start-IseTranscript {
    <#
    .SYNOPSIS
    This captures output from a script to a created text file
    .NOTES
    NAME:  Start-iseTranscript
    EDITED BY: Todd Kadrie
    AUTHOR: ed wilson, msft
    REVISIONS:
    * 12:05 PM 3/1/2020 rewrote header to loosely emulate most of psv5.1 stock transcirpt header
    * 8:40 AM 3/11/2015 revised to support PSv3's break of the $psise.CurrentPowerShellTab.consolePane.text object
        and replacement with the new...
            $psise.CurrentPowerShellTab.consolePane.text
        (L13 FEs are PSv4, lyn650 is PSv2)
    * 9:22 AM 3/5/2015 tweaked, added autologname generation (from script loc & name)
    * 09/10/2010 17:27:22 - original
    TYPICAL USAGE:
        Call from Cleanup() (or script-end, only populated post-exec, not realtime)
        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        if($host.Name -eq "Windows PowerShell ISE Host"){
                # 8:46 AM 3/11/2015 shift the logfilename gen out here, so that we can arch it
                $Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
                write-host "`$Logname: $Logname";
                Start-iseTranscript -logname $Logname ;
                # optional, normally wouldn't archive ISE debugging passes
                #Archive-Log $Logname ;
            } else {
                if($showdebug){ write-host -ForegroundColor Yellow "$((get-date).ToString('HH:mm:ss')):Stop Transcript" };
                Stop-TranscriptLog ;
                if($showdebug){ write-host -ForegroundColor Yellow "$((get-date).ToString('HH:mm:ss')):Archive Transcript" };
                Archive-Log $transcript ;
            } # if-E
        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    KEYWORDS: Transcript, Logging, ISE, Debugging
    HSG: WES-09-25-10
    .DESCRIPTION
    use if($host.Name -eq "Windows PowerShell ISE Host"){ } to detect and fire this only when in ISE
    .PARAMETER Logname
    the name and path of the log file.
    .INPUTS
    [string]/fso file object
    .OUTPUTS
    [io.file]
    .EXAMPLE
    Archive-Log $Logname ;
    Archives specified file to Archive
    .Link
    Http://www.ScriptingGuys.com
    #Requires -Version 2.0
    #>

    Param([string]$Logname)

    if (!($Logname)) {
        # build from script if nothing passed in
        if (!($scriptDir) -OR !($scriptNameNoExt)) {
            throw "`$scriptDir & `$scriptNameNoExt are REQUIRED values from the main script SUBMAIN. ABORTING!"
            # can't interpolate from here, because the script because the invokation is the function, rather than the script
        } ;
        # 1:06 PM 4/26/2017 flip log ext to .txt - so OL can preview it properly for fast review
        $Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + $timeStampNow + "-ISEtrans-log.txt")) ;
        write-host "ISE Trans `$Logname: $Logname";
    };
    <# original header: Pre-PSv5
    $TranscriptHeader = @"
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date)
UserName: $env:username
UserDomain: $env:USERDNSDOMAIN
ComputerName: $env:COMPUTERNAME
Windows version: $((Get-WmiObject win32_operatingsystem).version)
**************************************
Transcript started. Output file is $Logname
"@
#>
    # header (updated to emulate most of Psv5.1 header)
    $OS = Get-WmiObject win32_operatingsystem ; 
    $TranscriptHeader = @"
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date -format 'yyyyMMddHHmmss')
UserName: $env:userdomain\$env:username
RunAs User: $env:userdomain\$env:username
Configuration Name: 
Machine: $env:COMPUTERNAME ($($os.caption.tostring()) $($os.version.tostring())) 
Windows version: $((Get-WmiObject win32_operatingsystem).version)
Host Application: $((resolve-path $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe).path)
PSVersion: $($host.version.tostring())
PSEdition: Desktop
PSCompatibleVersions: 
Platform: $($os.CreationClassName.split('_')[0])NT
BuildVersion: 
CLRVersion: 
WSManStackVersion: 
OS: $($os.caption.tostring()) $($os.version.tostring())
PSRemotingProtocolVersion: 
SerializationVersion: 
**************************************
Transcript started. Output file is $Logname
"@
        $TranscriptHeader | out-file $Logname -append

        #$psISE.CurrentPowerShellTab.Output.Text >> $Logname
        <# 8:37 AM 3/11/2015 PSv3 broke/hid the above object, new object is
        $psISE.CurrentPowerShellTab.ConsolePane.text
        Note, it's reportedly not realtime, as the Psv2 .type param was
        #>
        if (($host.version) -lt "3.0") {
            # use legacy obj
            $psISE.CurrentPowerShellTab.Output.Text | out-file $Logname -append
        } else {
            # use the new object
            $psISE.CurrentPowerShellTab.ConsolePane.text | out-file $Logname -append
        } # if-E

}

#*------^ Start-IseTranscript.ps1 ^------

#*------v Start-Log.ps1 v------
function Start-Log {
    <#
    .SYNOPSIS
    Start-Log.ps1 - Configure base settings for use of write-Log() logging
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 12/29/2019
    FileName    : Start-Log.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
    * 12:35 PM 5/5/2020 added -NotTimeStamp param, and supporting code to return non-timestamped filenames
    * 12:44 PM 4/23/2020 shift $path validation to parent folder - with AllUsers scoped scripts, we need to find paths, and *fake* a path to ensure logs aren't added to AllUsers %progfiles%\wps\scripts\(logs). So the path may not exist, but the parent dir should
    * 3:56 PM 2/18/2020 Start-Log: added $Tag param, to support descriptive string for building $transcript name
    * 11:16 AM 12/29/2019 init version
    .DESCRIPTION
    Start-Log.ps1 - Configure base settings for use of write-Log() logging
    Usage:
    #-=-=-=-=-=-=-=-=
    $backInclDir = "c:\usr\work\exch\scripts\" ;
    #*======v FUNCTIONS v======
    $tModFile = "verb-logging.ps1" ; $sLoad = (join-path -path $LocalInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {     Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug) { Write-Verbose -verbose "Post $sLoad" }; } else {     $sLoad = (join-path -path $backInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {         Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug) { Write-Verbose -verbose "Post $sLoad" };     }     else { Write-Warning ((Get-Date).ToString("HH:mm:ss") + ":MISSING:" + $sLoad + " EXITING...") ; exit; } ; } ;
    #*======^ END FUNCTIONS ^======
    #*======v SUB MAIN v======
    [array]$reqMods = $null ; # force array, otherwise single first makes it a [string]
    $reqMods += "Write-Log;Start-Log".split(";") ;
    $reqMods = $reqMods | Select-Object -Unique ;
    if ( !(check-ReqMods $reqMods) ) { write-error "$((get-date).ToString("yyyyMMdd HH:mm:ss")):Missing function. EXITING." ; throw "FAILURE" ; }  ;
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -showdebug:$($showdebug) -whatif:$($whatif) ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
    } else {throw "Unable to configure logging!" } ;
    #-=-=-=-=-=-=-=-=
    .PARAMETER  Path
    Path to target script (defaults to $PSCommandPath)
    .PARAMETER Tag
    Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .EXAMPLE
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -showdebug:$($showdebug) -whatif:$($whatif) ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
    } else {throw "Unable to configure logging!" } ;
    Configure default logging from parent script name
    .EXAMPLE
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -NoTimeStamp ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        start-Transcript -path $transcript ; 
    } else {throw "Unable to configure logging!" } ;
    Configure default logging from parent script name, with no Timestamp
    .LINK
    https://github.com/tostka/verb-logging
    #>
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to target script (defaults to `$PSCommandPath) [-Path -Path .\path-to\script.ps1]")]
        [ValidateScript({Test-Path (split-path $_)})]$Path,
        [Parameter(HelpMessage="Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]")]
        [string]$Tag,
        [Parameter(HelpMessage="Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]")]
        [switch] $NoTimeStamp,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
    if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
    if($Tag){
        $transcript += "-$($Tag)" ; 
    } ; 
    $transcript += "-Transcript-BATCH"
    if(!$NoTimeStamp){ $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')" } ; 
    $transcript += "-trans-log.txt"  ;
    # add log file variant as target of Write-Log:
    $logfile = $transcript.replace("-Transcript", "-LOG").replace("-trans-log", "-log")
    if ($whatif) {
        $logfile = $logfile.replace("-BATCH", "-BATCH-WHATIF") ;
        $transcript = $transcript.replace("-BATCH", "-BATCH-WHATIF") ;
    }
    else {
        $logfile = $logfile.replace("-BATCH", "-BATCH-EXEC") ;
        $transcript = $transcript.replace("-BATCH", "-BATCH-EXEC") ;
    } ;
    $logging = $True ;

    $hshRet= [ordered]@{
        logging=$logging ;
        logfile=$logfile ;
        transcript=$transcript ;
    } ;
    if($showDebug){
        write-verbose -verbose:$true "$(($hshRet|out-string).trim())" ;  ;
    } ;
    Write-Output $hshRet ;
}

#*------^ Start-Log.ps1 ^------

#*------v start-TranscriptLog.ps1 v------
function start-TranscriptLog {
    <#.SYNOPSIS
    Configures and launches a transcript
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2014-12-10
    FileName    : test-IsElevated.ps1
    License     : MIT License
    Copyright   : (c) 2014 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Permissions,Session
    REVISIONS   :
    # 10:19 AM 12/10/2014 cleanup
    12:36 PM 12/9/2014 init
    .DESCRIPTION
    Configures and launches a transcript
    Requires test-transcribing() & Test-TranscriptionSupported() functions
    .INPUTS
    None
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting transcribe status
    .EXAMPLE
    start-TranscriptLog $Transcript
    #>

    param(
      [parameter(Mandatory=$true,Helpmessage="Transcript location")]
      [ValidateNotNullOrEmpty()]
      [alias("tfile")]
      [string]$Transcript
    )

    # Have to set relative $scriptDir etc OUTSIDE THE FUNC, build full path to generic core $Transcript vari, and then
    # start-transcript will auto use it (or can manual spec it with -path)

    if($host.Name -NE "Windows PowerShell ISE Host"){
        Try {
                if (Test-Transcribing) {Stop-Transcript}

                if($showdebug) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$Transcript: $($Transcript)" -verbose:$Verbose };
                # prevaidate specified logging dir is present
                $TransPath=(Split-Path $Transcript).tostring();
                if($showdebug) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose };
                if (Test-Path $TransPath ) { } else {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose ; mkdir $TransPath};
                #invoke-pause2
                Start-Transcript -path $Transcript
                if (Test-Transcribing) {  return $true } else {return $false};
            } Catch {
                Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to create $TransPath"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
                Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
            }  # try-E;

    } else {
        write-host "Test-Transcribing:SKIP PS ISE does not support transcription commands [returning $true]";
        return $true ;
    };  # if-E
}

#*------^ start-TranscriptLog.ps1 ^------

#*------v Stop-TranscriptLog.ps1 v------
function Stop-TranscriptLog {
    <#.SYNOPSIS
    Stops & ARCHIVES a transcript file (if no archive needed, just use the stock Stop-Transcript cmdlet)
    .NOTES
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() function
    REVISIONS   :
    # 1:18 PM 1/14/2015 added Lync fs rpt share support; added lab support (lynms650d\d$)
    # 10:11 AM 12/10/2014 tshot stop-transcriptlog archmove, for existing file clashes ; shifted more into the try block
    12:49 PM 12/9/2014 init
    .INPUTS
    leverages the global $transcript variable (must be set in the root script; not functions)
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    Stop-TranscriptLog
    #>

    #can't define $transcript as a local param/vari, without toasting the main vari!
    if ($showdebug) {"SUB: stop-transcriptlog"}

    # 10:48 AM 1/14/2015 adde lab support for archpath
    # 10:56 AM 1/14/2015 adde Lync FS support


    if($host.Name -ne "Windows PowerShell ISE Host"){
        Try {
            if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`n`$outtransfile:$outtransfile" ;};
                if (Test-Transcribing) {
                    # can't move it if it's locked
                    Stop-Transcript
                    if ($showdebug) {write-host -foregroundcolor green "`$transcript:$transcript"} ;
                }  # if-E
        } Catch {
                Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to move `n$transcript to `n$archPath"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
                Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
        }  # try-E;

        if (!(Test-Transcribing)) {  return $true } else {return $false};
    } else {
        write-host "Stop-Transcribing:SKIP PS ISE does not support transcription commands";
        return $true ;
    } # if-E ;
}

#*------^ Stop-TranscriptLog.ps1 ^------

#*------v Test-Transcribing.ps1 v------
function Test-Transcribing {
    <#.SYNOPSIS
    Tests for whether transcript (Start-Transcript) is already running
    .NOTES
    Version     : 1.0.0
    Author      : Oisin Grehan
    Website     :	http://poshcode.org/1500
    CreatedDate : 2020-
    FileName    : Test-Transcribing.ps1
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Logging
    REVISIONS   :
    * 12:18 PM 5/4/2020 updated CBH
    * 10:13 AM 12/10/2014
    This function will test to see if the current system is transcribing.
    This leverages $host properties, and is compatible with ISE, to the extent that it accomodates ISE use, and forced-returns $true (assumes ISE stop-TranscriptLog is used to stop & generate a native ISE-based). transcript)
    .INPUTS
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting transcribe status
    .EXAMPLE
    if (Test-Transcribing) {Stop-Transcript}
    #>
    if($host.Name -ne "Windows PowerShell ISE Host"){
        $ExternalHost = $host.gettype().getproperty("ExternalHost",
            [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
        try {
            if (Test-TranscriptionSupported) {
                $ExternalHost.gettype().getproperty("IsTranscribing",
                    [reflection.bindingflags]"NonPublic,Instance").getvalue($ExternalHost, @())
            } else {

            };  # if-E

        } catch {
            Write-Warning "Tested: This host does not support transcription."
        } # try-E
    } else {
        write-host "Test-Transcribing:SKIP PS ISE does not support transcription commands [returning `$true]";
        return $true ;
    } # if-E
}

#*------^ Test-Transcribing.ps1 ^------

#*------v Test-Transcribing2.ps1 v------
function test-Transcribing2 {
    <#.SYNOPSIS
    Tests for whether transcript (Start-Transcript) is already running
    .NOTES
    Version     : 1.0.0
    Author      : Darryl Kegg
    Website     :	http://poshcode.org/1500
    CreatedDate : 2020-
    FileName    : test-Transcribing2.ps1
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Logging
    REVISIONS   :
    * 12:02 PM 5/4/2020 minior cleanup, expanded CBH
    * 1.0 01 October, 2015 posted Initial Version
    .DESCRIPTION
    This function will test to see if the current system is transcribing.
    This try/catch-based version is compatible with ISE (vs test-Transcribing, which is not)
    Any currently running transcript will be stopped & resumed with information added to the transcript to show that the log was tested, then reutrn a boolean value.
    .INPUTS
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting transcribe status
    .EXAMPLE
    if (test-Transcribing2) {Stop-Transcript} ;
    Test transcription status, and stop transcript if transcribing
    .LINK
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param()
    $Verbose = ($VerbosePreference -eq "Continue") ;
    $IsTranscribing = $false ; 
    $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
    if (!$stopResults) {write-Verbose -verbose:$verbose "(not transcribing)"}
    elseif ($stopResults -and $stopResults -match 'not\sbeen\sstarted"') {write-Verbose -verbose:$verbose "(test-Transcribing2:Not transcribing)"}
    elseif ($stopResults -and $stopResults -match 'Transcript\sstopped,\soutput\sfile\sis'){
        write-Verbose -verbose:$verbose "(test-Transcribing2:Running transcript was found ; resuming...)" ; 
        Start-Transcript -path $stopResults.Split(" ")[-1] -append  | out-null ; 
        $IsTranscribing = $True ; 
    } ; 
    write-Verbose -verbose:$verbose "IsTranscribing:$($IsTranscribing)" ; 
    $IsTranscribing | write-output ; 
}

#*------^ Test-Transcribing2.ps1 ^------

#*------v Test-TranscriptionSupported.ps1 v------
function Test-TranscriptionSupported {
    <#
    .SYNOPSIS
    Tests to see if the current host supports transcription.
    .DESCRIPTION
    Powershell.exe supports transcription, WinRM and ISE do not.
    .Example
    #inside powershell.exe
    Test-Transcription
    #returns true
    Description
    -----------
    Returns a $true if the host supports transcription; $false otherwise
    #>
    $ExternalHost = $host.gettype().getproperty("ExternalHost",
    [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
    try {
      [Void]$ExternalHost.gettype().getproperty("IsTranscribing",
      [Reflection.BindingFlags]"NonPublic,Instance").getvalue($ExternalHost, @())
      $true
    } catch {
      $false
    } # try-E
}

#*------^ Test-TranscriptionSupported.ps1 ^------

#*------v Write-Log.ps1 v------
function Write-Log {
    <#
    .SYNOPSIS
    Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
    .NOTES
    Author: Jason Wasser @wasserja
    Website:	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
    Twitter:	@wasserja
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 3:50 PM 3/29/2020 minor tightening layout
    * 11:34 AM 8/26/2019 fixed missing noecho parameter desig in comment help
    * 9:31 AM 2/15/2019:Write-Log: added Level:Debug support, and broader init
        block example with $whatif & $ticket support, added -NoEcho to suppress console
        echos and just use it for writing logged output
    * 8:57 PM 11/25/2018 Write-Log:shifted copy to verb-transcript, added defer to scope $script versions
    * 2:30 PM 10/18/2018 added -useHost to have it issue color-keyed write-host commands vs write-(warn|error|verbose)
        switched timestamp into the function (as $echotime), rather than redundant code in the $Message contstruction.
    * 10:18 AM 10/18/2018 cleanedup, added to pshelp, put into OTB fmt, added trailing semis, parame HelpMessages, and -showdebug param
    * Code simplification and clarification - thanks to @juneb_get_help  ;
    * Added documentation.
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks  ;
    * Revised the Force switch to work as it should - thanks to @JeffHicks  ;

    To Do:  ;
    * Add error handling if trying to create a log file in a inaccessible location.
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate  ;
        duplicates.
    .DESCRIPTION
    The Write-Log function is designed to add logging capability to other scripts.
    In addition to writing output and/or verbose you can write to a log file for  ;
    later debugging.
    .PARAMETER Message  ;
    Message is the content that you wish to add to the log file.
    .PARAMETER Path  ;
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    .PARAMETER Level  ;
    Specify the criticality of the log information being written to the log defaults Info: (Error|Warn|Info)  ;
    .PARAMETER useHost  ;
    Switch to use write-host rather than write-[verbose|warn|error] [-useHost]
    .PARAMETER NoEcho
    Switch to suppress console echos (e.g log to file only [-NoEcho]
    .PARAMETER NoClobber  ;
    Use NoClobber if you do not wish to overwrite an existing file.
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Writes output to the specified Path.
    .EXAMPLE
    Write-Log -Message 'Log message'   ;
    Writes the message to c:\Logs\PowerShellLog.log.
    .EXAMPLE
    Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
    Writes the content to the specified log file and creates the path and file specified.
    .EXAMPLE
    Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error  ;
    Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
    .EXAMPLE
    # init content in script context ($MyInvocation is blank in function scope)
    $logfile = join-path -path $ofile -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-LOG.txt"  ;
    $logging = $True ;
    # ...
    $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
    $smsg="$($sBnr)" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    Example that uses a variable and the -useHost switch, to trigger write-host use
    .EXAMPLE
    $transcript = join-path -path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "logs" ;
    if(!(test-path -path $transcript)){ "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    $transcript=join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))"  ;
    $transcript+= "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
    # add log file variant as target of Write-Log:
    $logfile=$transcript.replace("-Transcript","-LOG").replace("-trans-log","-log")
    if($whatif){
        $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
        $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
    } else {
        $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
        $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
    } ;
    if($Ticket){
        $logfile=$logfile.replace("-BATCH","-$($Ticket)") ;
        $transcript=$transcript.replace("-BATCH","-$($Ticket)") ;
    } else {
        $logfile=$logfile.replace("-BATCH","-nnnnnn") ;
        $transcript=$transcript.replace("-BATCH","-nnnnnn") ;
    } ;
    $logging = $True ;

    $sBnr="#*======v START PASS:$($ScriptBaseName) v======" ;
    $smsg= "$($sBnr)" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    More complete boilerplate including $whatif & $ticket
    .LINK
    https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0  ;
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Message is the content that you wish to add to the log file")]
        [ValidateNotNullOrEmpty()][Alias("LogContent")]
        [string]$Message,
        [Parameter(Mandatory = $false, HelpMessage = "The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.")][Alias('LogPath')]
        [string]$Path = 'C:\Logs\PowerShellLog.log',
        [Parameter(Mandatory = $false, HelpMessage = "Specify the criticality of the log information being written to the log defaults Info: (Error|Warn|Info)")][ValidateSet("Error", "Warn", "Info", "Debug")]
        [string]$Level = "Info",
        [Parameter(HelpMessage = "Switch to use write-host rather than write-[verbose|warn|error] [-useHost]")]
        [switch] $useHost,
        [Parameter(HelpMessage = "Switch to suppress console echos (e.g log to file only [-NoEcho]")]
        [switch] $NoEcho,
        [Parameter(Mandatory = $false, HelpMessage = "Use NoClobber if you do not wish to overwrite an existing file.")]
        [switch]$NoClobber,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )  ;

    Begin {$VerbosePreference = 'Continue'  ; }  ;
    Process {
        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."  ;
            Return  ;
        } elseif (!(Test-Path $Path)) {
            # create the file including the path when missing.
            Write-Verbose "Creating $Path."  ;
            $NewLogFile = New-Item $Path -Force -ItemType File  ;
        } else {
          # Nothing to see here yet.
        }  ;

        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  ;
        $EchoTime = "$((get-date).ToString('HH:mm:ss')):" ;

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                if ($useHost) {write-host -foregroundcolor red ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Error ($EchoTime + $Message) } } ;
                $LevelText = 'ERROR:'  ;
            }
            'Warn' {
                if ($useHost) {write-host -foregroundcolor yellow ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Warning ($EchoTime + $Message) } } ;
                $LevelText = 'WARNING:'  ;
            }
            'Info' {
                if ($useHost) {write-host -foregroundcolor green ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Verbose ($EchoTime + $Message) } } ;
                $LevelText = 'INFO:'  ;
            }
            'Debug' {
                if (!$NoEcho) { Write-Debug -Verbose:$true ($EchoTime + $Message) }  ;
                $LevelText = 'DEBUG:'  ;
            }
        } ;

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append  ;
    }  ; # PROC-E
    End {}  ;
}

#*------^ Write-Log.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function Archive-Log,Cleanup,get-ArchivePath,get-EventsFiltered,get-lastlogon,get-lastevent,get-lastlogon,get-lastshutdown,get-lastsleep,get-lastwake,get-winEventsLoopedIDs,Start-IseTranscript,Start-Log,start-TranscriptLog,Stop-TranscriptLog,Test-Transcribing,test-Transcribing2,Test-TranscriptionSupported,Write-Log -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIUIQlmq2+7NDxupGL/JcD/Nx
# 4H6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSymc7J
# ZGtMFYPgpdDqNcBvPC1pwzANBgkqhkiG9w0BAQEFAASBgCaRCGPom2iZzwkjViF3
# lPVYV5QcfG2AkBNMkE8Uy8eHpEUBtl00atxu34n6S2jzFokoFSGHR86ACbo+xIO2
# 8je26o4qxrjnDy8mGiP0dF4G4atieozEg54wX8XaEJNDh/6KLrI7KcK/sIyR1AFK
# jtbxl/TJbBu2siHsiUHFbC5n
# SIG # End signature block
