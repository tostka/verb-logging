﻿# verb-logging.psm1


  <#
  .SYNOPSIS
  verb-logging - Logging-related generic functions
  .NOTES
  Version     : 1.0.8.0
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

#*------v get-lastsleep.ps1 v------
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
}

#*------^ get-lastsleep.ps1 ^------

#*------v get-lastwake.ps1 v------
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
}

#*------^ get-lastwake.ps1 ^------

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
    Version     : 1.0.8
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 12/29/2019
    FileName    : Start-Log.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
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
    $reqMods += "Test-TranscriptionSupported;Test-Transcribing;Stop-TranscriptLog;Start-IseTranscript;Start-TranscriptLog;get-ArchivePath;Archive-Log;Start-TranscriptLog;Write-Log;Start-Log".split(";") ;
    $reqMods = $reqMods | Select-Object -Unique ;
    if ($reqMods) {
        #*------v Function check-ReqMods v------
        function check-ReqMods ($reqMods) { $bValidMods = $true ; $reqMods | foreach-object { if ( !(test-path function:$_ ) ) { write-error "$((get-date).ToString("yyyyMMdd HH:mm:ss")):Missing $($_) function." ; $bValidMods = $false ; } } ; write-output $bValidMods ; } ; #*------^ END Function check-ReqMods ^------
    } ;
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
    .LINK
    https://github.com/tostka/verb-logging
    #>
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to target script (defaults to `$PSCommandPath) [-Path -Path .\path-to\script.ps1]")]
        [ValidateScript({Test-Path $_})]$Path,
        [Parameter(HelpMessage="Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]")]
        [string]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;

    $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
    if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))"  ;
    if($Tag){
        $transcript += "-$($Tag)" ; 
    } ; 
    $transcript += "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
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
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() & Test-TranscriptionSupported() functions
    REVISIONS   :
    # 10:19 AM 12/10/2014 cleanup
    12:36 PM 12/9/2014 init
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
    Author: Oisin Grehan
    URL: http://poshcode.org/1500
    requires -version 2.0, and Test-TranscriptionSupported()
    REVISIONS   :
    10:13 AM 12/10/2014
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

    Begin {
        $VerbosePreference = 'Continue'  ; # Set VerbosePreference to Continue so that verbose messages are displayed.
    }  ;
    Process {
        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."  ;
            Return  ;
        }
        elseif (!(Test-Path $Path)) {
            # create the file including the path when missing.
            Write-Verbose "Creating $Path."  ;
            $NewLogFile = New-Item $Path -Force -ItemType File  ;
        }
        else {
            # Nothing to see here yet.
        }  ;

        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  ;
        $EchoTime = "$((get-date).ToString('HH:mm:ss')):" ;

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                if ($useHost) {
                    write-host -foregroundcolor red ($EchoTime + $Message)   ;
                }
                else {
                    if (!$NoEcho) { Write-Error ($EchoTime + $Message) } ;
                } ;
                $LevelText = 'ERROR:'  ;
            }
            'Warn' {
                if ($useHost) {
                    write-host -foregroundcolor yellow ($EchoTime + $Message)    ;
                }
                else {
                    if (!$NoEcho) { Write-Warning ($EchoTime + $Message) } ;
                } ;
                $LevelText = 'WARNING:'  ;
            }
            'Info' {
                if ($useHost) {
                    write-host -foregroundcolor green ($EchoTime + $Message)   ;
                }
                else {
                    if (!$NoEcho) { Write-Verbose ($EchoTime + $Message) } ;
                } ;
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

Export-ModuleMember -Function Archive-Log,Cleanup,get-ArchivePath,get-lastsleep,get-lastwake,Start-IseTranscript,Start-Log,start-TranscriptLog,Stop-TranscriptLog,Test-Transcribing,Test-TranscriptionSupported,Write-Log -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU45zhXGotQqnDiAqmYLJFHkK0
# wNugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQUSiGP
# kG0t1QagjVyM+2GDwzXHYDANBgkqhkiG9w0BAQEFAASBgCZHYl7KVNskzwhiSMGu
# UMmjK6BL/e4XEQmbLlm2MvdhH6hLO4WcWjcl9bJ4WgcDZJ6aaMvO41iD0ncBF3fR
# ndQiBu1N9wn4X4QHt+4czh+coFM6ft2h983CvpWPFXHUuX5/rRF1cX3WlWiHvwRr
# bO+EGhv3vsP2U3zHYpp+qW4J
# SIG # End signature block
