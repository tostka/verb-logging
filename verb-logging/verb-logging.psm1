﻿# verb-logging.psm1


  <#
  .SYNOPSIS
  verb-logging - Logging-related generic functions
  .NOTES
  Version     : 1.3.0.0
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
  * 11:29 AM 11.3.0017 initial version
  .DESCRIPTION
  verb-logging - Logging-related generic functions
  .LINK
  https://github.com/tostka/verb-logging
  #>


    $script:ModuleRoot = $PSScriptRoot ;
    $script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ;
    $runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

#*======v FUNCTIONS v======




#*------v Archive-Log.ps1 v------
function Archive-Log {
    <#
    .SYNOPSIS
    Archive-Log - ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-09-22
    FileName    : Archive-Log.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell, logging
    REVISIONS
    * 4:17 PM 3/29/2021 set move/remove fails to non-terminating echo err, but don't exit
    * 4:00 PM 12/2/2020 updated and streamlined added -overwrite to force overwrite on clash, and -UniqueClash to append a GUID chunk to filename, to force unique file at dest, where pre-existing conflict exists
    # 3:04 PM 10/8/2020 add force, to overwrite on conflict
    # 3:37 PM 9/22/2020 added looping/mult $filepath added code to validate $filepath, and force $archpath if not already set
    # 9:15 AM 4/24/2015 shifted all $archpath detection code out to separate get-ArchivePath()
    # 2:49 PM 4/23/2015 recast $ArchPath as $archPath script scope
    # 9:39 AM 4/13/2015 tightened up formatting, crushed lines ; update-RetiringConfRmWindows-prod-tests-20150413-0917AM.ps1 version
    # 7:30 AM 1/28/2015 in use in LineURI script
    # 10:37 AM 1/21.3.05 moved out of the if\else
    # 1:44 PM 1/16/2015 repurposed from Stop-TranscriptLog, focused this on just moving to archive location
    # 1:18 PM 1/14/2015 added Lync fs rpt share support ; added Lync FS support ; added lab support (lynms650d\d$)
    # 10:48 AM 1/14/2015 adde lab support for archpath ; tshot Archive-Log archmove, for existing file clashes
    # 9:04 AM 12/10/2014 shifted more into the try block
    #12:49 PM 12/9/2014 init
    .DESCRIPTION
    Archive-Log - ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .PARAMETER  FilePath
    array of paths to log files to be archived[-FilePath 'c:\pathto\file1.txt','c:\pathto\file2.txt']
    .PARAMETER Overwrite
    Overwrite Flag (on pre-existing conflicts)[-Overwrite]
    .PARAMETER UniqueClash
    Flag that generates a unique filename, when conflicting file pre-exists, by appending a 4char GUID chunk to the end of the filename [-UniqueClash]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    $archPath = get-ArchivePath ;
    if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
        $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
        write-host "`$Logname: $Logname";
        Start-iseTranscript -logname $Logname ;
        Archive-Log $Logname ;
        $transcript = $Logname ; 
        if($host.version.Major -ge 5){ stop-transcript } ;
    } else {
        Stop-TranscriptLog ;
        Archive-Log -FilePath $transcript ;
    } # if-E
    Full stack use of get-ArchivePath(), Start-iseTranscript(), Stop-TranscriptLog(), & Archive-Log()
    .EXAMPLE
    $LOGFILE = 'c:\pathto\log.txt',c:\pathto\log2.txt'; 
    Archive-Log -FilePath $logfile -Verbose:($VerbosePreference -eq 'Continue') -Overwrite ;
    Example passing in an array of files to be archived, with Overwrite (other wise it renames clashes as -B)
    .LINK
    https://github.com/tostka/verb-logging
    #>
    
    [CmdletBinding()]
    PARAM(
        [parameter(Mandatory=$true,HelpMessage="Array of paths to log files to be archived[-FilePath 'c:\pathto\file1.txt','c:\pathto\file2.txt']")] 
        #[ValidateScript({Test-Path $_})]
        [array]$FilePath,
        [Parameter(ParameterSetName='Overwrite',HelpMessage="Overwrite Flag (on pre-existing conflicts)[-Overwrite]")]
        [switch] $Overwrite,
        [Parameter(ParameterSetName='Unique',HelpMessage="Flag that generates a unique filename, when conflicting file pre-exists, by appending a 4char GUID chunk to the end of the filename [-UniqueClash]")]
        [switch] $UniqueClash,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if ($showdebug -OR $verbose) {"Archive-Log"}
    if( (!$archpath) -OR (-not(Test-Path $archPath -ea 0 )) ){
            $archPath = get-ArchivePath -Verbose:($VerbosePreference -eq 'Continue') ;
    } ; 
    

    # valid filepath passed in
    $error.clear
    foreach($fpath in $FilePath){
       
            write-verbose "$((get-date).ToString('HH:mm:ss')):`$archPath:$archPath `n`$fpath:$fpath"
            if (($fsoObj = gci -path $fpath)) {
                write-host  ("$((get-date).ToString('HH:mm:ss')):Moving `n$($fsoobj.fullname) `n to:" + $archPath)
                $ArchTarg = (Join-Path -path $archPath -childpath $fsoObj.Name);
                $pltFile =@{path = $fpath ;destination = $archPath ;Force = $true ;verbose = $($verbose) ;} ; 
                if ( (Test-Path $ArchTarg) -AND (!$Overwrite) -AND (!$UniqueClash)) {
                    $pltFile.destination = $ArchTarg.replace($fsoObj.Extension,"-B$($fsoObj.Extension)") ; 
                    $cmdlet = "Move-Item" ; 
                    if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):CLASH DETECTED, RENAMING ON MOVE: `n`$ArchTarg:$ArchTarg"};
                }elseif ( (Test-Path $ArchTarg) -AND ($UniqueClash)) {
                    $unqStr = [guid]::NewGuid().tostring().split('-')[1] ; 
                    $pltFile.destination = $ArchTarg.replace($fsoObj.Extension,"-$($unqStr)$($fsoObj.extension)")
                    $cmdlet = "Move-Item" ; 
                    if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):CLASH DETECTED, RENAMING ON MOVE: `n`$ArchTarg:$ArchTarg"};
                } else {
                    # 8:41 AM 12/10/2014 add error checking
                    $error.Clear()
                    $cmdlet = "Copy-Item" ; 
                } # if-E
                write-verbose "$($Cmdlet) w`n$(($pltFile|out-string).trim())" ; 
                $error.clear() ;
                if($cmdlet -eq 'Move-Item'){
                    Try {
                        Move-Item @pltFile ;
                    } Catch {
                        $ErrTrapd=$Error[0] ;
                        $smsg= "Failed to exec cmd because: $($ErrTrapd)`n(non-terminating err)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;
                } elseif($cmdlet -eq 'Copy-Item'){
                    Try {
                        copy-item @pltFile ; 
                    } Catch {
                        $ErrTrapd=$Error[0] ;
                        $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        CONTINUE ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                    } ;
                    $pltFile.remove('destination') ; 
                    # this frequently fails, make it gracefully continue, without crashing host script
                    Try {
                        remove-item @pltFile ; 
                    } Catch {
                        $ErrTrapd=$Error[0] ;
                        $smsg= "Failed to exec cmd because: $($ErrTrapd)`n(non-terminating err)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #CONTINUE ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                    } ;
                } else {
                    throw "Unrecognized `$cmdlet:$($cmdlet)" ; 
                } ;
            } else {
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):NO TRANSCRIPT FILE FOUND! SKIPPING MOVE"
            }  # if-E
    } ;  # loop-E
    if (!(Test-Transcribing -Verbose:($VerbosePreference -eq 'Continue'))) {  return $true } else {return $false};
}

#*------^ Archive-Log.ps1 ^------


#*------v Cleanup.ps1 v------
function Cleanup {
    <#
    .SYNOPSIS
    Cleanup.ps1 - Cleanup, close logging & email reports template funcotin
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 8:38 AM 11/23/2020 add verbose support
    * 2:51 PM 9/22/2020 updated to cover ISE v5 transcription support
    .DESCRIPTION
    Cleanup.ps1 - Cleanup, close logging & email reports template funcotin
    .EXAMPLE
    .\Cleanup.ps1
    .EXAMPLE
    if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
        # STATIC transcript paths
        #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
        #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + $timeStampNow + "-ISEtrans.log")) ;
        # 2:02 PM 9/21.3.08 missing $timestampnow, hardcode
        #$Logname=(join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -format 'yyyyMMdd-HHmmtt') + "-ISEtrans.log")) ;
        # RENAME and use the pre-generated transcript
        $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
        write-host "`$Logname: $Logname";
        Start-iseTranscript -logname $Logname ;
        #Archive-Log $Logname ; 
        $transcript = $Logname ; 
        if($host.version.Major -ge 5){ stop-transcript } ;
    } else {
        if($showdebug -OR $verbose){ write-verbose -verbose:$true  "$((get-date).ToString('HH:mm:ss')):Stop Transcript" };
        Stop-TranscriptLog ;
        #Archive-Log $transcript ;
    } # if-E
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    # clear all objects and exit
    # Clear-item doesn't seem to work as a variable release
    # 3:18 PM 2/13/2019 Cleanup: add in the smtp mailer and Change/Error report mailing code from maintain-exombxretentionpolicies.ps1
    # 8:15 AM 10/2/2018 Cleanup:make it defer to $script:cleanup() (needs to be preloaded before verb-transcript call in script), added missing semis, replaced all $bDebug -> $showDebug
    # 2:02 PM 9/21.3.08 missing $timestampnow, hardcode
    # 8:45 AM 10/13/2015 reset $DebugPreference to default SilentlyContinue, if on
    # # 8:46 AM 3/11.3.05 at some time from then to 1:06 PM 3/26/2015 added ISE Transcript
    # 8:39 AM 12/10/2014 shifted to stop-transcriptLog function
    # 7:43 AM 1/24/2014 always stop the running transcript before exiting
    [CmdletBinding()]
    PARAM() # empty param, min verbose req
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if ($showdebug -OR $verbose) {"CLEANUP"} ;
    #stop-transcript ;
    if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
        #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
        #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + $timeStampNow + "-ISEtrans.log")) ;
        $Logname=(join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -format 'yyyyMMdd-HHmmtt') + "-ISEtrans.log")) ;
        $smsg= "`$Logname: $Logname";
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

        Start-iseTranscript -logname $Logname  -Verbose:($VerbosePreference -eq 'Continue') ;
        #Archive-Log $Logname ;
        $transcript = $Logname ;
    } else {
        if($showdebug -OR $verbose){ write-verbose -verbose:$true "$(get-timestamp):Stop Transcript" };
        Stop-TranscriptLog  -Verbose:($VerbosePreference -eq 'Continue') ;
        #if($showdebug -OR $verbose){ write-verbose -verbose:$true "$(get-timestamp):Archive Transcript" };
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
    if($showdebug -OR $verbose){
        $smsg= "Mailing Report"
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    };

    #$smtpSubj= "Proc Rpt:$($ScriptBaseName):$(get-date -format 'yyyyMMdd-HHmmtt')"   ;
    #Load as an attachment into the body text:
    #$body = (Get-Content "path-to-file\file.html" ) | converto-html ;
    #$SmtpBody += ("Pass Completed "+ [System.DateTime]::Now + "`nResults Attached: " +$transcript) ;
    # 4:07 PM 10/11.3.08 giant transcript, no send
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
        Send-EmailNotif -Verbose:($VerbosePreference -eq 'Continue');
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
    # 8:38 AM 11/23/2020 extend verbose supp
    # 3:48 PM 9/22/2020 cleanedup CBH, examples
    # 8:33 AM 2/18/2020 get-ArchivePath: shifted paths into global varis in profile
    # 8:52 AM 4/24/2015 shifted internal func vari name from $archPath to $ArchiveLocation, to avoid overlap clash/confusion ; shifted archpath detection code out of send-mailmessage and archive-log, into get-ArchivePath()
    # 2:49 PM 4/23/2015 recast $ArchPath as $archPath script scope
    # 9:39 AM 4/13/2015 tightened up formatting, crushed lines ; update-RetiringConfRmWindows-prod-tests-20150413-0917AM.ps1 version
    # 7:30 AM 1/28/2015 in use in LineURI script
    # 10:37 AM 1/21.3.05 moved out of the if\else
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
    .EXAMPLE
    $archPath = get-ArchivePath ;
    if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
        $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
        write-host "`$Logname: $Logname";
        Start-iseTranscript -logname $Logname ;
        Archive-Log $Logname ;
        $transcript = $Logname ; 
        if($host.version.Major -ge 5){ stop-transcript } ;
    } else {
        Stop-TranscriptLog ;
        Archive-Log $transcript ;
    } # if-E
    Full stack use of the functions
    .LINK
    https://www.toddomation.com
    #>
    [CmdletBinding()]
    PARAM() # empty param, min verbose req
    $verbose = ($VerbosePreference -eq "Continue") ; 
    Write-verbose -verbose:$verbose "$((get-date).ToString('HH:mm:ss')):MSG" ;
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

    if ($showdebug -OR $verbose) { write-verbose "$((get-date).ToString('HH:mm:ss')) Start get-ArchivePath" -Verbose:$verbose}

    # if blocked for SMB use custom arch server for reporting
    $IPs=get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress ;
    $IPs | ForEach-Object {
        if ($_.ipaddress -match $rgxRestrictedNetwork){
            # server with blocks to SMB to archserver
            if ($showdebug -OR $verbose) {write-host -foregroundcolor yellow  "$((get-date).ToString('HH:mm:ss')):Restricted Subnet Detected. Using Lync ArchPath";};

            if($env:USERDOMAIN -eq $domLab){
                if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLabLync"};
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
                if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLab"};
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
    if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`$ArchiveLocation:$ArchiveLocation"};

    Try {
        # validate the archpath
        if (!(Test-Path $ArchiveLocation)) {
            # gui prompt
            $ArchiveLocation = [Microsoft.VisualBasic.Interaction]::InputBox("Input ArchPath[UNCPath]", "Archpath", "") ;
        }
        if($showdebug -OR $verbose){Write-Verbose "$((get-date).ToString('HH:mm:ss'))End get-ArchivePath" -Verbose:$verbose} ;
        # 2:21 PM 4/24/2015 try flattening in here.
        if($ArchiveLocation -is [system.array]){
            write-verbose "Flattening in get-ArchivePath" -verbose:$verbose ;
            $ArchiveLocation = $ArchiveLocation[0]
        } # if-E
        Return $ArchiveLocation

    } # TRY-E
    Catch {
        $ErrTrapd=$Error[0] ;
        Start-Sleep -Seconds $RetrySleep ;
        $Exit ++ ;
        $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
        Exit ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
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


#*------v get-lastlogon.ps1 v------
function get-lastlogon {[CmdletBinding()]PARAM() ; get-lastevent -Logon -Verbose:$($VerbosePreference -eq 'Continue') }

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
    * 12:28 PM 7/7/2022 updated CBH syn/desc to more accurately reflect function
    * 8:11 AM 3/9/2020 added verbose support & verbose echo'ing of hash values
    * 4:00 PM 3/7/2020 ran vsc expalias
    * 1:11 PM 3/6/2020 init
    .DESCRIPTION
    get-winEventsLoopedIDs -filterhashtable supports an array in the ID key, but I want MaxEvents _per event_ filtered, not overall (total most recent 7 drawn from most recent 14 of each type, sorted by date). Passed a -filter hashtable, this function pulls the ID array off and loops & aggregates the events, sorts on time, and returns the most recent x of each ID. 
    .PARAMETER MaxEvents
    Maximum # of events to poll for each event specified -MaxEvents 14]
    .PARAMETER FinalEvents
    Final # of sorted events of all types to return [-FinalEvents 7]
    .PARAMETER Filter
    get-WinEvents -FilterHashtable hash obj to be queried to return matching events[-filter `$hashobj]
    A typical hash of this type, could look like: @{logname='System';id=6009 ;ProviderName='EventLog';Level=4;}
    Corresponding to a search of the System log, EventLog source, for ID 6009, of Informational type (Level 4).
    .EXAMPLE
    PS> [array]$evts = @() ;
    PS> $hlastShutdown=@{logname = 'System'; ProviderName = $null ;  ID = '13','6008','13','6008','6006' ; Level = 4 ; } ;
    PS> $evts += get-winEventsLoopedIDs -filter $hlastShutdown -MaxEvents ;
    The above runs a collection pass for each of the ID's specified above (which are associated with shutdowns),
    returns the 14 most recent of each type, sorts the aggregate matched events on timestamp, and returns the most
    recent 7 events of any of the matched types.
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(HelpMessage = "Maximum # of events to poll for each event specified[-MaxEvents 14]")]
        [int] $MaxEvents = 14,
        [Parameter(HelpMessage = "Final # of sorted events of all types to return [-FinalEvents 7]")]
        [int] $FinalEvents = 7,
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
    * 10:11 AM 12/2/2022 CBH expl update (-ISEtrans-log.txt)
    * 8:38 AM 7/29/2022 updated CBH example, to preclear consolet text, ahead of use (at the normal start-transcript loc); also added example code to defer to new start-transcript support on ISE for Psv5+ 
    * 12:05 PM 3/1/2020 rewrote header to loosely emulate most of psv5.1 stock transcirpt header
    * 8:40 AM 3/11.3.05 revised to support PSv3's break of the $psise.CurrentPowerShellTab.consolePane.text object
        and replacement with the new...
            $psise.CurrentPowerShellTab.consolePane.text
        (L13 FEs are PSv4, lyn650 is PSv2)
    * 9:22 AM 3/5/2015 tweaked, added autologname generation (from script loc & name)
    * 09/10/2010 17:27:22 - original
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
    PS> #region  ; #*------v GENERIC PATH DETECTION/TRANSCRIPT CODE v------
    PS> # switch path detection depending on if in func or in script
    PS> switch($pscmdlet.myinvocation.mycommand.CommandType){
    PS>     'Function' {
    PS>         $smsg = "(CommandType:Function:interpolating Context Path values from other configured sources)" ;
    PS>         write-verbose $smsg ;
    PS>         Try {$ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop }
    PS>         Catch {$ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path } ;
    PS>         $ScriptDir= $ScriptRoot ;
    PS>         $ScriptBaseName = $pscmdlet.myinvocation.mycommand.Name ;
    PS>         $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($pscmdlet.myinvocation.mycommand.Name ) ;
    PS>         $smsg += "`n--Legacy Path resolutions:" ;
    PS>         $smsg += "`n`$ScriptDir (fr `$PSScriptRoot):`t$($ScriptDir)" ;
    PS>         $smsg += "`n`$ScriptBaseName (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptBaseName)" ;
    PS>         $smsg += "`n`$ScriptNameNoExt (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptNameNoExt)" ;
    PS>     }
    PS>     'ExternalScript' {
    PS>         $smsg = "CommandType:ExternalScript:.ps1:Determining values from legacy sources)" ;
    PS>         write-verbose $smsg ;
    PS>         TRY{
    PS>             $ScriptDir=((Split-Path -parent $MyInvocation.MyCommand.Definition -ErrorAction STOP) + "\");
    PS>             $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ;
    PS>             $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
    PS>             $smsg += "`n--Legacy Path resolutions:" ;
    PS>             $smsg += "`n`$ScriptDir (fr `$MyInvocation):`t$($ScriptDir)" ;
    PS>             $smsg += "`n`$ScriptBaseName (fr &{$myInvocation}).ScriptName):`t$($ScriptBaseName)" ;
    PS>             $smsg += "`n`$ScriptNameNoExt (fr `$MyInvocation.InvocationName):`t$($ScriptNameNoExt)" ;
    PS>             $smsg += "`n`$MyInvocation.MyCommand.Path:`t$((Split-Path -parent $MyInvocation.MyCommand.Path))" ;
    PS>         } CATCH {
    PS>             $smsg = "Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ;
    PS>             $smsg += "(interpolating values from other configured sources)" ;
    PS>         } ;
    PS>     }
    PS>     default {
    PS>         write-warning "Unrecognized `$pscmdlet.myinvocation.mycommand.CommandType:$($pscmdlet.myinvocation.mycommand.CommandType)!" ;
    PS>     } ;
    PS> } ; 
    PS> write-verbose $smsg ; 
    PS> $transcript = join-path -path $ScriptDir -childpath 'Logs' ; 
    PS> if(!(test-path $transcript)){ mkdir $transcript -verbose } ; 
    PS> $transcript = join-path $transcript -childpath "$($ScriptNameNoExt)" ; 
    PS> # $transcript += "-TAG" ; 
    PS> if($whatif){$transcript += "-WHATIF" } ELSE { $transcript += "-EXEC" } ; 
    PS> $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')" ; 
    PS> $transcript += "-trans-log.txt" ; 
    PS> $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
    PS> TRY {
    PS>     if($psise -and ($host.version.major -lt 5)){
    PS>         Write-host -foregroundcolor white "Start-Transcript *is not* supported under PS$($host.version.major): (pre-clearing console for trailing start-ISETranscript use)" ;
    PS>         if ($host.version.major -lt 3) {$psISE.CurrentPowerShellTab.Output.Clear()}
    PS>         else {$psise.CurrentPowerShellTab.consolePane.Clear()} ;
    PS>     } else {
    PS>         $startResults = Start-transcript -path $transcript -ErrorAction stop;
    PS>         write-host $startResults ;
    PS>     } ;
    PS> } CATCH {
    PS>     Break ;
    PS> } ;    
    PS> #endregion  ; #*------^ END GENERIC TRANSCRIPT W PATH DETECTION ^------
    PS> #region  ; #*------v START-ISETRANSCRIPT WRAPPER BLOCK v------    
    PS> write-verbose "2. Call from Cleanup() (or script-end, only populated post-exec, not realtime)" ; 
    PS> if($psise -and ($host.version.major -lt 5)){
    PS>     if(-not $transcript){
    PS>         if($scriptNameNoExt){
    PS>             $transcript= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans-log.txt")) ;
    PS>         } else {
    PS>             $smsg = "unable to find/construct a $transcript!" ; 
    PS>             write-warning $smsg ; 
    PS>             throw $smsg ; 
    PS>             Break ; 
    PS>         } ;  
    PS>     } ;    
    PS>     write-host "`$Transcript: $transcript";
    PS>     Start-iseTranscript -logname $transcript ;
    PS>     # optional, normally wouldn't archive ISE debugging passes
    PS>     #Archive-Log $Logname ;
    PS> } else {
    PS>     $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
    PS>     write-host $stopResults ; 
    PS>     #Archive-Log $transcript ;
    PS> } ; 
    PS> #endregion  ; #*------^ END START-ISETRANSCRIPT WRAPPER BLOCK ^------  
    Demo full set of wrapper calls covering path detection, transcript path construction, and calls to Start-ISETranscript
    .Link
    Http://www.ScriptingGuys.com
    #Requires -Version 2.0
    #>
    [CmdletBinding()]
    Param([string]$Logname)
    $verbose = ($VerbosePreference -eq "Continue") ; 
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
        <# 8:37 AM 3/11.3.05 PSv3 broke/hid the above object, new object is
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
    * 11:57 AM 1/17/2023 updated output object to be psv2 compat (OrderedDictionary object under v2)
    * 3:46 PM 11/16/2022 added catch blog around start-trans, that traps 'not compatible' errors, distict from generic catch
    * 2:15 PM 2/24/2022 added -TagFirst param (put the ticket/tag at the start of the filenames)
    * 4:23 PM 1/24/2022 added capture of start-trans - or it echos into pipeline
    * 10:46 AM 12/3/2021 added Tag cleanup: Remove-StringDiacritic,  Remove-StringLatinCharacters, Remove-IllegalFileNameChars (adds verb-io & verb-text deps); added requires for the usuals.
    * 9/27/2021 Example3, updated to latest diverting rev
    * 5:06 PM 9/21/2021 rewrote Example3 to handle CurrentUser profile installs (along with AllUsers etc).
    * 8:45 AM 6/16/2021 updated example for redir, to latest/fully-expanded concept code (defers to profile constants); added tricked out example for looping UPN/Ticket combo
    * 2:23 PM 5/6/2021 disabled $Path test, no bene, and AllUsers redir doesn't need a real file, just a path ; add example for detecting & redirecting logging, when psCommandPath points to Allusers profile (installed module function)
    * 2:05 PM 3/30/2021 added example demo'ing detect/divert off of AllUsers-scoped installed scripts
    * 1:46 PM 12/21/2020 added example that builds logfile off of passed in .txt (rather than .ps1 path or pscommandpath)
    * 11:39 AM 11/24/2020 updated examples again
    * 9:18 AM 11/23/2020 updated 2nd example to use splatting
    * 12:35 PM 5/5/2020 added -NotTimeStamp param, and supporting code to return non-timestamped filenames
    * 12:44 PM 4/23/2020 shift $path validation to parent folder - with AllUsers scoped scripts, we need to find paths, and *fake* a path to ensure logs aren't added to AllUsers %progfiles%\wps\scripts\(logs). So the path may not exist, but the parent dir should
    * 3:56 PM 2/18/2020 Start-Log: added $Tag param, to support descriptive string for building $transcript name
    * 11:16 AM 12/29/2019 init version
    .DESCRIPTION
    Start-Log.ps1 - Configure base settings for use of write-Log() logging
    
    Note: To use -TagFirst: set both -TagFirst & -Ticket; the ticket spec will prefix all generated filenames
    
    Usage:
    #-=-=-=-=-=-=-=-=
    $backInclDir = "c:\usr\work\exch\scripts\" ;
    #*======v FUNCTIONS v======
    $tModFile = "verb-logging.ps1" ; $sLoad = (join-path -path $LocalInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {     Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug -OR $verbose) { Write-Verbose -verbose "Post $sLoad" }; } else {     $sLoad = (join-path -path $backInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {         Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug -OR $verbose) { Write-Verbose -verbose "Post $sLoad" };     }     else { Write-Warning ((Get-Date).ToString("HH:mm:ss") + ":MISSING:" + $sLoad + " EXITING...") ; exit; } ; } ;
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
    .PARAMETER NoTimeStamp
    Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]
    .PARAMETER TagFirst
    Flag that leads the returned filename with the Tag parameter value[-TagFirst]
    .PARAMETER ShowDebug
    Switch to display Debugging messages [-ShowDebug]
    .PARAMETER whatIf
    Whatif Flag [-whatIf]
    .EXAMPLE
    $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
    if($PSCommandPath){   $logspec = start-Log -Path $PSCommandPath @pltSL ; 
    } else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL ; } ; 
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        if(Test-TranscriptionSupported){
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
            $startResults = start-transcript -Path $transcript ;
        } ;
    } else {throw "Unable to configure logging!" } ;
    Configure default logging from parent script name
    .EXAMPLE
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -NoTimeStamp ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
        $startResults = start-Transcript -path $transcript ; 
    } else {throw "Unable to configure logging!" } ;
    
    Configure default logging from parent script name, with no Timestamp
    .EXAMPLE
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
    foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
    if(!(get-variable rgxPSAllUsersScope -ea 0)){
        $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
    } ;
    if(!(get-variable rgxPSCurrUserScope -ea 0)){
        $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
    } ;
    $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
    $pltSL.Tag = $ModuleName ; 
    # variant Ticket/TagFirst Tagging:
    # $pltSL.Tag = $Ticket ;
    # $pltSL.TagFirst = $true ;
    if($script:PSCommandPath){
        if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
            $bDivertLog = $true ; 
            switch -regex ($script:PSCommandPath){
                $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                $rgxPSCurrUserScope{$smsg = "CurrentUser"}
            } ;
            $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
            write-verbose $smsg  ;
            if($bDivertLog){
                if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                    # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                } else {
                    # installed allusers|CU script, use the hosting script name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                }
            } ;
        } else {
            $pltSL.Path = $script:PSCommandPath ;
        } ;
    } else {
        if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
             $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
        } elseif(test-path $MyInvocation.MyCommand.Definition) {
            $pltSL.Path = $MyInvocation.MyCommand.Definition ;
        } elseif($cmdletname){
            $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
        } else {
            $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            BREAK ;
        } ; 
    } ;
    write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
    $logspec = start-Log @pltSL ;
    $error.clear() ;
    TRY {
        if($logspec){
            $logging=$logspec.logging ;
            $logfile=$logspec.logfile ;
            $transcript=$logspec.transcript ;
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            $startResults = start-Transcript -path $transcript ;
        } else {throw "Unable to configure logging!" } ;
    } CATCH [System.Management.Automation.PSNotSupportedException]{
        if($host.name -eq 'Windows PowerShell ISE Host'){
            $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
        } else { 
            $smsg = "This host does *not* support native (start-)transcription" ; 
        } ; 
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
        write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
    } ;
    
    Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
    .EXAMPLE
    $iProcd=0 ; $ttl = ($UPNs | Measure-Object).count ; $tickNum = ($tickets | Measure-Object).count
    if ($ttl -ne $tickNum ) {
        write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):ERROR!:You have specified $($ttl) UPNs but only $($tickNum) tickets.`nPlease specified a matching number of both objects." ;
        Break ;
    } ;
    foreach($UPN in $UPNs){
        $iProcd++ ;
        if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
        foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
        if(!(get-variable rgxPSAllUsersScope -ea 0)){
            $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
        } ;
        $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
        if($tickets[$iProcd-1]){$pltSL.Tag = "$($tickets[$iProcd-1])-$($UPN)"} ;
        if($script:PSCommandPath){
            if($script:PSCommandPath -match $rgxPSAllUsersScope){
                write-verbose "AllUsers context script/module, divert logging into [$budrv]:\scripts" ;
                if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                    # function in a module/script installed to allusers 
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                } else { 
                    # installed allusers script
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                }
            }else {
                $pltSL.Path = $script:PSCommandPath ;
            } ;
        } else {
            if($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope){
                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
            } else {
                $pltSL.Path = $MyInvocation.MyCommand.Definition ;
            } ;
        } ;
        write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
        $logspec = start-Log @pltSL ;
        $error.clear() ;
        TRY {
            if($logspec){
                $logging=$logspec.logging ;
                $logfile=$logspec.logfile ;
                $transcript=$logspec.transcript ;
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                $startResults = start-Transcript -path $transcript ;
            } else {throw "Unable to configure logging!" } ;
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
     }  # loop-E $UPN
     
     Looping per-pass Logging (uses $UPN & $Ticket array, in this example). 
    .EXAMPLE
    $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
    if($forceall){$pltSL.Tag = "-ForceAll" }
    else {$pltSL.Tag = "-LASTPASS" } ;
    write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
    $logspec = start-Log -Path c:\scripts\test-script.txt @pltSL ;
    
    Path is normally to the executing .ps1, but *does not have to be*. Anything with a valid path can be specified, including a .txt file. The above generates logging/transcript paths off of specifying a non-existant text file path.
    .LINK
    https://github.com/tostka/verb-logging
    #>
    #Requires -Modules verb-IO, verb-Text
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to target script (defaults to `$PSCommandPath) [-Path .\path-to\script.ps1]")]
        # rem out validation, for module installed in AllUsers etc, we don't want to have to spec a real existing file. No bene to testing
        #[ValidateScript({Test-Path (split-path $_)})] 
        $Path,
        [Parameter(HelpMessage="Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]")]
        [string]$Tag,
        [Parameter(HelpMessage="Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]")]
        [switch] $NoTimeStamp,
        [Parameter(HelpMessage="Flag that leads the returned filename with the Tag parameter value[-TagFirst]")]
        [switch] $TagFirst,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
    if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    #$transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
    if($Tag){
        # clean for fso use
        $Tag = Remove-StringDiacritic -String $Tag ; # verb-text
        $Tag = Remove-StringLatinCharacters -String $Tag ; # verb-text
        $Tag = Remove-InvalidFileNameChars -Name $Tag ; # verb-io, (inbound Path is assumed to be filesystem safe)
        if($TagFirst){
            $smsg = "(-TagFirst:Building filenames with leading -Tag value)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            $transcript = join-path -path $transcript -childpath "$($Tag)-$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
            #$transcript = "$($Tag)-$($transcript)" ; 
        } else { 
            $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
            $transcript += "-$($Tag)" ; 
        } ;
    } else {
        $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
    }; 
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

    # [ordered] not psv2 backward compat - use an orderedDict for psv2
    <#$hshRet= [ordered]@{
        logging=$logging ;
        logfile=$logfile ;
        transcript=$transcript ;
    } ;
    #>
    # refactor back rev support to psv2
    if($host.version.major -ge 3){
        $hshRet=[ordered]@{Dummy = $null ; } ;
    } else {
        # psv2 Ordered obj (can't use with new-object -properites)
        $hshRet = New-Object Collections.Specialized.OrderedDictionary ; 
        # or use an UN-ORDERED psv2 hash: $Hash=@{ Dummy = $null ; } ;
    } ;
    If($hshRet.Contains("Dummy")){$hshRet.remove("Dummy")} ; 
    $hshRet.add('logging',$logging) ;
    $hshRet.add('logfile',$logfile);
    $hshRet.add('transcript',$transcript) ;
    if($showdebug -OR $verbose){
        # retaining historical $showDebug support, even tho' not generally used now.
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
    # 11:02 AM 9/22/2020 updated for psv5 support of transcription
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
    [CmdletBinding()]
    param(
      [parameter(Mandatory=$true,Helpmessage="Transcript location")]
      [ValidateNotNullOrEmpty()]
      [alias("tfile")]
      [string]$Transcript
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    # Have to set relative $scriptDir etc OUTSIDE THE FUNC, build full path to generic core $Transcript vari, and then
    # start-transcript will auto use it (or can manual spec it with -path)

    if( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -lt 5) ){
        write-host "Test-Transcribing:SKIP PS ISE does not support transcription commands [returning $true]";
        return $true ;
    } else { 
        Try {
                if (Test-Transcribing -Verbose:($VerbosePreference -eq 'Continue')) {Stop-Transcript}

                if($showdebug -OR $verbose) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$Transcript: $($Transcript)" -verbose:$Verbose };
                # prevaidate specified logging dir is present
                $TransPath=(Split-Path $Transcript).tostring();
                if($showdebug -OR $verbose) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose };
                if (Test-Path $TransPath ) { } else {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose ; mkdir $TransPath};
                #invoke-pause2
                Start-Transcript -path $Transcript -Verbose:($VerbosePreference -eq 'Continue') ;
                if (Test-Transcribing) {  return $true } else {return $false};
        } CATCH {
            $ErrTrapd=$Error[0] ;
            Start-Sleep -Seconds $RetrySleep ;
            $Exit ++ ;
            $smsg= "Failed to move `n$transcript to `n$archPath"
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            $smsg= "Try #: $($Exit)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            If ($Exit -eq $Retries) {
                $script:PassStatus += ";ERROR";
                $smsg= "Unable to exec cmd!" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            } ;
            Exit ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 

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
    # 3:35 PM 9/14/2021 fixed a pipeline-dump (diverted into wv)
    # 11:03 AM 9/22/2020 updated for psv5 ise transcription support
    # 1:18 PM 1/14/2015 added Lync fs rpt share support; added lab support (lynms650d\d$)
    # 10:11 AM 12/10/2014 tshot stop-transcriptlog archmove, for existing file clashes ; shifted more into the try block
    12:49 PM 12/9/2014 init
    .INPUTS
    leverages the global $transcript variable (must be set in the root script; not functions)
    .OUTPUTS
    Boolean: Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    $xRet = Stop-TranscriptLog -Verbose:($VerbosePreference -eq 'Continue') ;
    Example stopping log with local verbose passed - Be sure to capture output, or it will contaminate the pipeline!
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false,Helpmessage="Transcript location")]
        [alias('tfile','outtransfile')]
        [string]$Transcript
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    #can't define $transcript as a local param/vari, without toasting the main vari!
    if ($showdebug -OR $verbose) {write-verbose "SUB: stop-transcriptlog"}

    if( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -lt 5) ){
        write-host "Stop-Transcribing:SKIP PS ISE $($host.version.major) does not support transcription commands";
        # could stick start-ISETranscript here, but would have to know the transcript file name, the function should be supported in an if/else on $host.name & version
        return $true ;
    } else { 
        Try {
            if(!$Transcript){
                if($outtransfile){$transcript = $outtransfile} ; 
            }
            if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`n`$Transcript:$($Transcript)" ;};
            if (Test-Transcribing -Verbose:($VerbosePreference -eq 'Continue')) {
                # can't move it if it's locked
                Stop-Transcript -Verbose:($VerbosePreference -eq 'Continue')
                if ($showdebug -OR $verbose) {write-host -foregroundcolor green "`$transcript:$transcript"} ;
            } else {
                write-verbose "$((get-date).ToString('HH:mm:ss')):(no running transcript)" ; 
            } ;  # if-E
        } CATCH {
            $ErrTrapd=$Error[0] ;
            Start-Sleep -Seconds $RetrySleep ;
            $Exit ++ ;
            $smsg= "Failed to move `n$transcript to `n$archPath"
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            $smsg= "Try #: $($Exit)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            If ($Exit -eq $Retries) {
                $script:PassStatus += ";ERROR";
                $smsg= "Unable to exec cmd!" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
            } ;
            Exit ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 

        if (!(Test-Transcribing -Verbose:($VerbosePreference -eq 'Continue'))) {  return $true } else {return $false};
    } ;
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
    CreatedDate : 
    FileName    : Test-Transcribing.ps1
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Logging
    REVISIONS   :
    * 8:44 AM 11/23/2020 added verbose supp
    * 10:40 AM 9/22/2020 updated to reflect ISE PSv5's support for transcribing
    * 12:18 PM 5/4/2020 updated CBH
    * 10:13 AM 12/10/2014
    .DESCRIPTION
    Tests for whether transcript (Start-Transcript) is already running
    This function will test to see if the current system is transcribing.
    This leverages $host properties, and is compatible with ISE, to the extent that 
    it accomodates ISE use, and forced-returns $true (assumes ISE 
    stop-TranscriptLog is used to stop & generate a native ISE-based). transcript) 
    .INPUTS
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting transcribe status
    .EXAMPLE
    if (Test-Transcribing) {Stop-Transcript}
    #>
    [CmdletBinding()]
    PARAM() # empty param, min verbose req
    $verbose = ($VerbosePreference -eq "Continue") ; 
    # Psv5 ISE properly supports transcribing: https://www.jonathanmedd.net/2014/09/start-transcript-now-available-in-the-powershell-ise-in-powershell-v5.html
    if( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -lt 5) ){
        write-host "Test-Transcribing:SKIP PS ISE $($host.version.major) does NOT support transcription commands [returning `$true]";
        return $true ;
    } elseif( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -ge 5) ){
        # ISE v5+ can't pass the ExternalHost tests, use test-Transcribing2()
        Test-Transcribing2 -Verbose:($VerbosePreference -eq 'Continue') | write-output ; 
    } else { 
        $ExternalHost = $host.gettype().getproperty("ExternalHost",
            [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
        try {
            if (Test-TranscriptionSupported -Verbose:($VerbosePreference -eq 'Continue')) {
                $ExternalHost.gettype().getproperty("IsTranscribing",
                    [reflection.bindingflags]"NonPublic,Instance").getvalue($ExternalHost, @())
            } else {};  
        } catch {Write-Warning "Tested: This host does not support transcription."} ;
    } ;
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
    * 9:15 AM 2/3/2022 pulled verbose -verbose: echos, only echo on stop/resume, added write-log support. Default only returns $true/$false and echos when it resumes logging. 
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
    $smsg = "(not transcribing)" ; 
    if (!$stopResults) {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    } elseif ($stopResults -and $stopResults -match 'not\sbeen\sstarted"') {
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    } elseif ($stopResults -and $stopResults -match 'Transcript\sstopped,\soutput\sfile\sis'){
        $smsg = "(test-Transcribing2:Running transcript was found ; resuming...)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        Start-Transcript -path $stopResults.Split(" ")[-1] -append  | out-null ; 
        $IsTranscribing = $True ; 
    } ; 
    $smsg = "IsTranscribing:$($IsTranscribing)" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
    $IsTranscribing | write-output ; 
}

#*------^ Test-Transcribing2.ps1 ^------


#*------v Test-TranscriptionSupported.ps1 v------
function Test-TranscriptionSupported {
    <#
    .SYNOPSIS
    Test-TranscriptionSupported -Tests to see if the current host supports transcription.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 
    FileName    : Test-TranscriptionSupported.ps1
    License     : 
    Copyright   : 
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 8:45 AM 11/23/2020 add verbose supp
    # 12:08 PM 9/22/2020 updated to exempt ISE v5 testing - force true, as it fails the test but *does* support transcription ; revised CBH, origin lost to the mists of time, been in use since at least 2009 or so
    .DESCRIPTION
    Test-TranscriptionSupported -Tests to see if the current host supports transcription. Returns a $true if the host supports transcription; $false otherwise
    OUTPUT
    System.Boolean
    .EXAMPLE
    if(Test-TranscriptionSupported){start-transcript xxxx} ; 
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM() # empty param, min verbose req
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if( ( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -ge 5) ) ){
        # ps ise5 doesn't properly pass  ExternalHost test below - always fails, although the host fully supports transcription commands
        $true | Write-Output ; # force it true
    } else { 
        # ps and ps ise -lt 5 work fine with this older test Ise v4 fails, ps v1+ pass
        $ExternalHost = $host.gettype().getproperty("ExternalHost",
            [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
        try {
            # test below does *not* properly detect psv5's support of transcribing - fails, though the host will transcribe
            [Void]$ExternalHost.gettype().getproperty("IsTranscribing",
            [Reflection.BindingFlags]"NonPublic,Instance").getvalue($ExternalHost, @())
            $true | Write-Output
        } catch {$false | Write-Output} 
    } ; 
}

#*------^ Test-TranscriptionSupported.ps1 ^------


#*------v Write-Log.ps1 v------
function Write-Log {
    <#
    .SYNOPSIS
    Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-11
    FileName    : Write-Log.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell,Logging,Output,Echo,Console
    AddedCredit : Jason Wasser
    AddedWebsite:	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
    AddedTwitter:	@wasserja
    REVISIONS
    * 12:07 PM 2/3/2023 updated CBH, spliced over param help for write-hostindent params prev ported over ; 
        added demo of use of flatten and necessity of |out-string).trim() on formattedobject outputs, prior to using as $object with -Indent ; 
        roughed in attempt at -useHostBackgroundmoved, parked ; 
        added pipeline detect write-verbose ; 
        moved split/flatten into process block (should run per inbound string); added pipeline detect w-v
        fixed bug in pltColors add (check keys contains before trying to add, assign if preexisting)
    * 5:54 PM 2/2/2023 add -flatten, to strip empty lines from -indent auto-splits ; fix pltColors key add clash err; cbh updates, expanded info on new -indent support, added -indent demo
    * 4:20 PM 2/1/2023 added full -indent support; updated CBH w related demos; flipped $Object to [System.Object]$Object (was coercing multiline into single text string); 
        ren $Message -> $Object (aliased prior) splice over from w-hi, and is the param used natively by w-h; refactored/simplified logic prep for w-hi support. Working now with the refactor.
    * 4:47 PM 1/30/2023 tweaked color schemes, renamed splat varis to exactly match levels; added -demo; added Level 'H4','H5', and Success (rounds out the set of banrs I setup in psBnr)
    * 11:38 AM 11/16/2022 moved splats to top, added ISE v2 alt-color options (ISE isn't readable on psv2, by default using w-h etc)
    * 9:07 AM 3/21/2022 added -Level verbose & prompt support, flipped all non-usehost options, but verbose, from w-v -> write-host; added level prefix to console echos
    * 3:11 PM 8/17/2021 added verbose suppress to the get-colorcombo calls, clutters the heck out of outputs on verbose, no benef.
    * 10:53 AM 6/16/2021 get-help isn't displaying param details, pulled erroneous semi's from end of CBH definitions
    * 7:59 AM 6/11/2021 added H1|2|3 md-style #|##|## header tags ; added support for get-colorcombo, and enforced bg colors (legible regardless of local color scheme of console); expanded CBH, revised Author - it's diverged so substantially from JW's original concept, it's now "inspired-by", less than a variant of the original.
    * 10:54 AM 5/7/2021 pulled weird choice to set: $VerbosePreference = 'Continue' , that'd reset pref everytime called
    * 8:46 AM 11/23/2020 ext verbose supp
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
    .DESCRIPTION
    Write-Log is intended to provide console write-log echos in addition to commiting text to a log file. 
    
    It was originally based on a concept by Jason Wasser demoed at...
    [](https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0)
    
    ... of course as is typical that link was subsequently broken by MS over time... [facealm]
    
    But since that time I have substantially reimplemented jason's code from 
    scratch to implement my evolving concept for the function

    My variant now includes a wide range of Levels, a -useHost parameter 
    that implements a more useful write-host color coded output for console output 
    (vs use of the native write-error write-warning write-verbose cmdlets that 
    don't permit you to differentiate types of output, beyond those three niche 
    standardized formats)
     
    ### I typically use write-host in the following way:
    
    1. I configure a $logfile variable centrally in the host script/function, pointed at a suitable output file. 
    2. I set a [boolean]$logging variable to indicate if a log file is present, and should be written to via write-log 
		or if a simple native output should be used (I also use this for scripts that can use the block below, without access to my hosting verb-io module's copy of write-log).
	3. I then call write-log from an if/then block to fed the message via an $smsg variable.
	
	```powershell
    $smsg = "" ; 
	if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
	else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
	#Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
    ```
    ### Hn Levels
    
    The H1..H5 Levels are intended to "somewhat" emulate Markdown's Heading Levels 
    (#,##,###...#####) for output. No it's not native Markdown, but it does provide 
    another layer of visible output demarcation for scanning dense blocks of text 
    from process & analysis code. 
   
    ### Indent support

    Now includes -indent parameter support ported over from my verb-io:write-hostIndent cmdlet
    Native indent support relies on setting the $env:HostIndentSpaces to target indent. 
    Also leverages following verb-io funcs: (life cycle: (init indent); (mod indent); (clear indent e-vari))
    (reset-HostIndent), (push-HostIndent,pop-HostIndent,set-HostIndent), (clear-HostIndent),
    
    Note: Psv2 ISE fundementally mangles and fails to shows these colors properly 
    (you can clearly see it running get-Colornames() from verb-io)

    It appears to just not like writing mixed fg & bg color combos quickly.
    Works fine for writing and logging to file, just don't be surprised 
    when the ISE console output looks like technicolor vomit. 
    
    .PARAMETER Object <System.Object>
    Objects to display in the host.
    .PARAMETER Path  
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    .PARAMETER Level  
    Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success)[-level Info]
    .PARAMETER useHost  
    Switch to use write-host rather than write-[verbose|warn|error] (does not apply to H1|H2|H3|DEBUG which alt via uncolored write-host) [-useHost]
    .PARAMETER NoEcho
    Switch to suppress console echos (e.g log to file only [-NoEcho]
    .PARAMETER NoClobber  
    Use NoClobber if you do not wish to overwrite an existing file.
    .PARAMETER BackgroundColor
    Specifies the background color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER ForegroundColor <System.ConsoleColor>
    Specifies the text color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
    The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.
    .PARAMETER Separator <System.Object>
    Specifies a separator string to insert between objects displayed by the host.
    .PARAMETER PadChar
    Character to use for padding (defaults to a space).[-PadChar '-']
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .PARAMETER Indent
    Switch to use write-HostIndent-type code for console echos(see get-help write-HostIndent)[-Indent]
    .PARAMETER Flatten
    Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER demo
	Switch to output a demo display of each Level, and it's configured color scheme (requires specification of a 'dummy' message string to avoid an error).[-Demo]
    .EXAMPLE
        PS>  Write-Log -Message 'Log message'   ;
        Writes the message to default log loc (c:\Logs\PowerShellLog.log, -level defaults to Info).
        .EXAMPLE
        PS> Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log ;
        Writes the content to the specified log file and creates the path and file specified.
        .EXAMPLE
        PS> write-log -level warn "some information" -Path c:\tmp\tmp.txt
        WARNING: 10:17:59: some information
        Demo default use of the native write-warning cmdlet (default behavior when -useHost is not used)
        .EXAMPLE
        write-log -level warn "some information" -Path c:\tmp\tmp.txt -usehost
        10:19:14: WARNING: some information
        Demo use of the "warning" color scheme write-host cmdlet (behavior when -useHost *IS* used)
        .EXAMPLE
        PS> Write-Log -level Prompt -Message "Enter Text:" -Path c:\tmp\tmp.txt -usehost  ; 
        PS> invoke-soundcue -type question ; 
        PS> $enteredText = read-host ;
        Echo's a distinctive Prompt color scheme for the message (vs using read-host native non-color-differentiating -prompt parameter), 
        and writes a 'Prompt'-level entry to the log, uses my verb-io:invoke-soundCue to play a the system question sound; then uses promptless read-host to take typed input. 
        PS> Write-Log -level Prompt -Message "Enter Password:" -Path c:\tmp\tmp.txt -usehost  ; 
        PS> invoke-soundcue -type question ; 
        PS> $SecurePW = read-host -AsSecureString ;        
        Variant that demos collection of a secure password using read-host's native -AsSecureString param.
        .EXAMPLE
        PS>  $smsg = "ENTER CERTIFICATE PFX Password: (use 'dummy' for UserName)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } 
        PS>  else{ write-host -foregroundcolor Blue -backgroundcolor White "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>  $pfxcred=(Get-Credential -credential dummy) ;
        PS>  Export-PfxCertificate -Password $pfxcred.password -Cert= $certpath -FilePath c:\path-to\output.pfx;
        Demo use of write-log -level prompt, leveraging the get-credential popup GUI to collect a secure password (without use of username)
        .EXAMPLE
        PS>  # init content in script context ($MyInvocation is blank in function scope)
        PS>  $logfile = join-path -path $ofile -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-LOG.txt"  ;
        PS>  $logging = $True ;
        PS>  $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
        PS>  $smsg="$($sBnr)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug|H1|H2|H3 
        PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>  Example with conditional write-log (with -useHost switch, to trigger native write-host use), else failthru to write-host output
        PS>  .EXAMPLE
        PS>  $transcript = join-path -path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "logs" ;
        PS>  if(!(test-path -path $transcript)){ "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
        PS>  $transcript=join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))"  ;
        PS>  $transcript+= "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
        PS>  # add log file variant as target of Write-Log:
        PS>  $logfile=$transcript.replace("-Transcript","-LOG").replace("-trans-log","-log")
        PS>  if($whatif){
        PS>      $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
        PS>      $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
        PS>  } else {
        PS>      $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
        PS>      $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
        PS>  } ;
        PS>  if($Ticket){
        PS>      $logfile=$logfile.replace("-BATCH","-$($Ticket)") ;
        PS>      $transcript=$transcript.replace("-BATCH","-$($Ticket)") ;
        PS>  } else {
        PS>      $logfile=$logfile.replace("-BATCH","-nnnnnn") ;
        PS>      $transcript=$transcript.replace("-BATCH","-nnnnnn") ;
        PS>  } ;
        PS>  $logging = $True ;
        PS>  $sBnr="#*======v START PASS:$($ScriptBaseName) v======" ;
        PS>  $smsg= "$($sBnr)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        More complete boilerplate including $whatif & $ticket
        .EXAMPLE
        PS>  $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
        PS>  $pltSL.Tag = "$(split-path -path $CSVPath -leaf)"; # build tag from a variable
        PS>  # construct log name on calling script/function fullname
        PS>  if($PSCommandPath){ $logspec = start-Log -Path $PSCommandPath @pltSL }
        PS>  else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL } ;
        PS>  if($logspec){
        PS>      $logging=$logspec.logging ;
        PS>      $logfile=$logspec.logfile ;
        PS>      $transcript=$logspec.transcript ;
        PS>      $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        PS>      start-Transcript -path $transcript ;
        PS>  } else {throw "Unable to configure logging!" } ;
        PS>  $sBnr="#*======v $(${CmdletName}): v======" ;
        PS>  $smsg = $sBnr ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        Example leveraging splatted start-log(), and either $PSCommandPath or $MyInvocation (support varies by host/psversion) to build the log name. 
        .EXAMPLE
        PS> write-log -demo -message 'Dummy' ; 
        Demo (using required dummy error-suppressing messasge) of sample outputs/color combos for each Level configured).
        .EXAMPLE
        PS>  $smsg = "`n`n===TESTIPAddress: was *validated* as covered by the recursed ipv4 specification:" ; 
        PS>  $smsg += "`n" ; 
        PS>  $smsg += "`n---> This host *should be able to* send email on behalf of the configured SPF domain (at least in terms of SPF checks)" ; 
        PS>  $env:hostindentspaces = 8 ; 
        PS>  $lvl = 'Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success'.split('|') ; 
        PS>  foreach ($l in $lvl){Write-Log -LogContent $smsg -Path $tmpfile -Level $l -useHost -Indent} ; 
        Demo indent function across range of Levels (alt to native -Demo which also supports -indent). 
        .EXAMPLE
        PS>  write-verbose 'set to baseline' ; 
        PS>  reset-HostIndent ; 
        PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        PS>  write-verbose 'write an H1 banner'
        PS>  $sBnr="#*======v  H1 Banner: v======" ;
        PS>  $smsg = $sBnr ;
        PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1;
        PS>  write-verbose 'push indent level+1' ; 
        PS>  push-HostIndent ; 
        PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        PS>  write-verbose 'write an INFO entry with -Indent specified' ; 
        PS>  $smsg = "This is information (indented)" ; 
        PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info -Indent:$true ;
        PS>  write-verbose 'push indent level+2' ; 
        PS>  push-HostIndent ; 
        PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        PS>  write-verbose 'write a PROMPT entry with -Indent specified' ; 
        PS>  $smsg = "This is a subset of information (indented)" ; 
        PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Prompt -Indent:$true ;
        PS>  write-verbose 'pop indent level out one -1' ; 
        PS>  pop-HostIndent ; 
        PS>  write-verbose 'write a Success entry with -Indent specified' ; 
        PS>  $smsg = "This is a Successful information (indented)" ; 
        PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Success -Indent:$true ;
        PS>  write-verbose 'reset to baseline for trailing banner'
        PS>  reset-HostIndent ; 
        PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        PS>  write-verbose 'write the trailing H1 banner'
        PS>  $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1;
        PS>  write-verbose 'clear indent `$env:HostIndentSpaces' ; 
        PS>  clear-HostIndent ; 
        PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        
            $env:HostIndentSpaces:0
            16:16:17: #  #*======v  H1 Banner: v======
            $env:HostIndentSpaces:4
                16:16:17: INFO:  This is information (indented)
            $env:HostIndentSpaces:8
                    16:16:17: PROMPT:  This is a subset of information (indented)
                16:16:17: SUCCESS:  This is a Successful information (indented)
            $env:HostIndentSpaces:0
            16:16:17: #  #*======^  H1 Banner: ^======
            $env:HostIndentSpaces:

        Demo broad process for use of verb-HostIndent funcs and write-log with -indent parameter.
        .EXAMPLE
        PS>  write-host "`n`n" ; 
        PS>  $smsg = "`n`n==ALL Grouped Status.errorCode :`n$(($EVTS.status.errorCode | group| sort count -des | format-table -auto count,name|out-string).trim())" ;
        PS>  $colors = (get-colorcombo -random) ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info -Indent @colors -flatten } 
        PS>  else{ write-host @colors  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>  PS>  write-host "`n`n" ; 
        
        When using -Indent with group'd or other cmd-multiline output, you will want to:
        1. use the... 
            $smsg = $(([results]|out-string).trim())"
            ...structure to pre-clean & convert from [FormatEntryData] to [string] 
            (avoids errors, due to formatteddata *not* having split mehtod)
        2. Use -flatten to avoid empty _colored_ lines between each entry in the output (and sprinkle write-host "`n`n"'s pre/post for separation). 
        These issues only occur under -Indent use, due to the need to `$Object.split to get each line of indented object properly collored and indented.
        .LINK
        https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0  ;
    #>    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, 
            HelpMessage = "Message is the content that you wish to add to the log file")]
            [ValidateNotNullOrEmpty()][Alias("LogContent")]
            [Alias('Message')] # splice over from w-hi, and is the param used natively by w-h
            [System.Object]$Object,
        [Parameter(Mandatory = $false, 
            HelpMessage = "The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.")]
            [Alias('LogPath')]
            [string]$Path = 'C:\Logs\PowerShellLog.log',
        [Parameter(Mandatory = $false, 
            HelpMessage = "Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success)[-level Info]")]
            [ValidateSet('Error','Warn','Info','H1','H2','H3','H4','H5','Debug','Verbose','Prompt','Success')]
            [string]$Level = "Info",
        [Parameter(
            HelpMessage = "Switch to use write-host rather than write-[verbose|warn|error] [-useHost]")]
            [switch] $useHost,
        [Parameter(
            HelpMessage="Specifies the background color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
            [System.ConsoleColor]$BackgroundColor,
        [Parameter(
            HelpMessage="Specifies the text color. There is no default. The acceptable values for this parameter are:
(Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
            [System.ConsoleColor]$ForegroundColor,
        [Parameter(
            HelpMessage="The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
the output strings. No newline is added after the last output string.")]
            [System.Management.Automation.SwitchParameter]$NoNewline,
        # params to support write-HostInden w/in w-l
        [Parameter(
            HelpMessage = "Switch to use write-HostIndent-type code for console echos(see get-help write-HostIndent)[-Indent]")]
            [Alias('in')]
            [switch] $Indent,
        [Parameter(
            HelpMessage = "Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]")]
            #[Alias('flat')]
            [switch] $Flatten,
        [Parameter(
            HelpMessage="Specifies a separator string to insert between objects displayed by the host.")]
        [System.Object]$Separator,
        [Parameter(
            HelpMessage="Character to use for padding (defaults to a space).[-PadChar '-']")]
        [string]$PadChar = ' ',
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrment 8]")]
        [int]$PadIncrment = 4,
        [Parameter(
                HelpMessage = "Switch to suppress console echos (e.g log to file only [-NoEcho]")]
            [switch] $NoEcho,
        [Parameter(Mandatory = $false, 
            HelpMessage = "Use NoClobber if you do not wish to overwrite an existing file.")]
            [switch]$NoClobber,
        [Parameter(
            HelpMessage = "Debugging Flag [-showDebug]")]
            [switch] $showDebug,
        [Parameter(
            HelpMessage = "Switch to output a demo display of each Level, and it's configured color scheme (requires specification of a 'dummy' message string to avoid an error).[-Demo]")]
            [switch] $demo
    )  ;
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;     
        #$VerbosePreference = "SilentlyContinue" ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        $pltWH = @{
            Object = $null ; 
        } ; 
        if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
            $pltWH.add('BackgroundColor',$BackgroundColor) ; 
        } ;
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
            $pltWH.add('ForegroundColor',$ForegroundColor) ; 
        } ;
        if ($PSBoundParameters.ContainsKey('NoNewline')) {
            $pltWH.add('NoNewline',$NoNewline) ; 
        } ;
        
        if($Indent){
        
            if ($PSBoundParameters.ContainsKey('Separator')) {
                $pltWH.add('Separator',$Separator) ; 
            } ;
            write-verbose "$($CmdletName): Using `$PadChar:`'$($PadChar)`'" ; 
            if (-not ([int]$CurrIndent = (Get-Item -Path Env:HostIndentSpaces -erroraction SilentlyContinue).Value ) ){
                [int]$CurrIndent = 0 ; 
            } ; 
            write-verbose "$($CmdletName): Discovered `$env:HostIndentSpaces:$($CurrIndent)" ; 

        } ; 

        if(get-command get-colorcombo -ErrorAction SilentlyContinue){$buseCC=$true} else {$buseCC=$false} ;
        <# attempt at implementing color-match to host bg: nope ISE colors I use aren't standard sys colors

        .PARAMETER useHostBackground
        Switch to use host's detected background color [-useHostBackground]
        [Parameter(
            HelpMessage = "Switch to use host's detected background color [-useHostBackground]")]
            [switch] $useHostBackground,

        If($useHostBackground){
            $hostsettings = get-host ;
            if ($hostsettings.name -eq 'Windows PowerShell ISE Host') {
                #$bgcolordefault = "Black" ;
                #$fgcolordefault = "gray" ;
                # Getting from ISE rgb color to syscolor:
                # sys color has a fromARGB(), but my colors *aren't system colors*, so this is a DOA concept. 
                # [System.Drawing.Color]::FromArgb($psise.Options.ConsolePaneForegroundColor.R,$psise.Options.ConsolePaneForegroundColor.G,$psise.Options.ConsolePaneForegroundColor.B)
                # R             : 245
                # G             : 245
                # B             : 245
                # A             : 255
                # IsKnownColor  : False <==
                # IsEmpty       : False
                # IsNamedColor  : False <==
                # IsSystemColor : False <==
                # Name          : fff5f5f5
                
            }
            else {
                $bgcolordefault = $hostsettings.ui.rawui.BackgroundColor ;
                $fgcolordefault = $hostsettings.ui.rawui.ForegroundColor ;
            } ; 
        } elseif($host.Name -eq 'Windows PowerShell ISE Host' -AND $host.version.major -lt 3){
        #>
        if ($host.Name -eq 'Windows PowerShell ISE Host' -AND $host.version.major -lt 3){
            #write-verbose "(low-contrast/visibility ISE 2 detected: using alt colors)" ; # too NOISEY!
            $pltError=@{foregroundcolor='yellow';backgroundcolor='darkred'};
            $pltWarn=@{foregroundcolor='DarkMagenta';backgroundcolor='yellow'};
            $pltInfo=@{foregroundcolor='gray';backgroundcolor='darkblue'};
            $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};
            $pltH2=@{foregroundcolor='darkblue';backgroundcolor='gray'};
            $pltH3=@{foregroundcolor='black';backgroundcolor='darkgray'};
            $pltH4=@{foregroundcolor='gray';backgroundcolor='DarkCyan'};
            $pltH5=@{foregroundcolor='cyan';backgroundcolor='DarkGreen'};
            $pltDebug=@{foregroundcolor='red';backgroundcolor='black'};
            $pltVerbose=@{foregroundcolor='darkgray';backgroundcolor='black'};
            $pltPrompt=@{foregroundcolor='DarkMagenta';backgroundcolor='darkyellow'};
            $pltSuccess=@{foregroundcolor='Blue';backgroundcolor='green'};
        } else {
            <#
            if($buseCC){$pltErr=get-colorcombo 60 -verbose:$false} else { $pltErr=@{foregroundcolor='yellow';backgroundcolor='red'};};
            if($buseCC){$pltWarn=get-colorcombo 52 -verbose:$false} else { $pltWarn=@{foregroundcolor='yellow';backgroundcolor='red'};};
            if($buseCC){$pltInfo=get-colorcombo 2 -verbose:$false} else { $pltInfo=@{foregroundcolor='yellow';backgroundcolor='red'};};
            if($buseCC){$pltH1=get-colorcombo 22 -verbose:$false } else { $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};};
            if($buseCC){$pltH2=get-colorcombo 25 -verbose:$false } else { $pltH2=@{foregroundcolor='black';backgroundcolor='gray'};};
            if($buseCC){$pltH3=get-colorcombo 30 -verbose:$false } else { $pltH3=@{foregroundcolor='black';backgroundcolor='darkgray'};};
            if($buseCC){$pltDbg=get-colorcombo 4 -verbose:$false } else { $pltDbg=@{foregroundcolor='red';backgroundcolor='black'};};
            if($buseCC){$pltVerb=get-colorcombo 1 -verbose:$false} else { $pltVerb=@{foregroundcolor='yellow';backgroundcolor='red'};};
            if($buseCC){$pltPrmpt=get-colorcombo 15 -verbose:$false} else { $pltPrmpt=@{foregroundcolor='Blue';backgroundcolor='White'};};
            #>
            $pltError=@{foregroundcolor='yellow';backgroundcolor='darkred'};
            $pltWarn=@{foregroundcolor='DarkMagenta';backgroundcolor='yellow'};
            $pltInfo=@{foregroundcolor='gray';backgroundcolor='darkblue'};
            $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};
            $pltH2=@{foregroundcolor='darkblue';backgroundcolor='gray'};
            $pltH3=@{foregroundcolor='black';backgroundcolor='darkgray'};
            $pltH4=@{foregroundcolor='gray';backgroundcolor='DarkCyan'};
            $pltH5=@{foregroundcolor='cyan';backgroundcolor='DarkGreen'};
            $pltDebug=@{foregroundcolor='red';backgroundcolor='black'};
            $pltVerbose=@{foregroundcolor='darkgray';backgroundcolor='black'};
            $pltPrompt=@{foregroundcolor='DarkMagenta';backgroundcolor='darkyellow'};
            $pltSuccess=@{foregroundcolor='Blue';backgroundcolor='green'};
        } ; 

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    }  ;
    PROCESS {

        if($Demo){
            write-host "Running demo of current settings..." @pltH1 
            $combos = "h1m;H1","h2m;H2","h3m;H3","h4m;H4","h5m;H5",
                "whm;INFO","whp;PROMPT","whs;SUCCESS","whw;WARN","wem;ERROR","whv;VERBOSE" ; 
            $h1m =" #*======v STATUSMSG: SBNR v======" ; 
            $h2m = "`n#*------v PROCESSING : sBnrS v------" ; 
            $h3m ="`n#*~~~~~~v SUB-PROCESSING : sBnr3 v~~~~~~" ;
            $h4m="`n#*``````v DETAIL : sBnr4 v``````" ; 
            $h5m="`n#*______v FOCUS : sBnr5 v______" ; 
            $whm = "This is typical output" ; 
            $whp = "What is your quest?" ;
            $whs = "Successful execution!" ;
            $whw = "THIS DIDN'T GO AS PLANNED" ; 
            $wem = "UTTER FAILURE!" ; 
            $whv = "internal comment executed" ; 
            $tmpfile = [System.IO.Path]::GetTempFileName().replace('.tmp','.txt') ; 
            foreach($cmbo in $combos){
                $txt,$name = $cmbo.split(';') ; 
                $Level = $name ; 
                if($Level -eq 'H5'){
                    write-host "Gotcha!"; 
                } ; 
                $whplt = (gv "plt$($name)").value ; 
                $text = (gv $txt).value ; 
                #$smsg="`$plt$($name):($($whplt.foregroundcolor):$($whplt.backgroundcolor)):`n`n$($text)`n`n" ;
                $whsmsg="`$plt$($name):($($whplt.foregroundcolor):$($whplt.backgroundcolor)):`n`n" ; 
                $pltWL=@{
                    message= $text ;
                    Level=$Level ;
                    Path=$tmpfile  ;
                    useHost=$true;
                } ;
                if($Indent){$PltWL.add('Indent',$true)} ; 

                $whsmsg += "write-log w`n$(($pltWL|out-string).trim())`n" ; 
                write-host $whsmsg ; 
                write-log @pltWL ; 
            } ; 
            remove-item -path $tmpfile ; 
            
        } else {
            
            # move split/flatten into per-object level (was up in BEGIN):
            # if $object has multiple lines, split it:
            #$Object = $Object.Split([Environment]::NewLine) ; 
            # have to coerce the system.object to string array, to get access to a .split method (raw object doese't have it)
            # and you have to recast the type to string array (can't assign a string[] to [system.object] type vari
            if($Flatten){
                if($object.gettype().name -eq 'FormatEntryData'){
                    # this converts tostring() as the string: Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData
                    # issue is (group |  ft -a count,name)'s  that aren't put through $((|out-string).trim())
                    write-verbose "skip split/flatten on these (should be pre-out-string'd before write-logging)" ; 
                } else { 
                    [string[]]$Object = [string[]]$Object.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
                } ; 
            } else { 
                [string[]]$Object = [string[]]$Object.ToString().Split([Environment]::NewLine) 
            } ; 

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
            $EchoTime = "$((get-date).ToString('HH:mm:ss')): " ;
            <#
            $pltWH
            #>
        
            $pltWH.Object = $EchoTime ; 
            $pltColors = @{} ; 
            # Write message to error, warning, or verbose pipeline and specify $LevelText
            switch ($Level) {
                'Error' {
                    $LevelText = 'ERROR: ' ; 
                    $pltColors = $pltErr ; 
                    if ($useHost) {} else {if (!$NoEcho) { Write-Error ($smsg + $Object) } } ;
                }
                'Warn' {
                    $LevelText = 'WARNING: ' ; 
                    $pltColors = $pltWarn ; 
                    if ($useHost) {} else {if (!$NoEcho) { Write-Warning ($smsg + $Object) } } ;
                }
                'Info' {
                    $LevelText = 'INFO: ' ; 
                    $pltColors = $pltInfo ; 
                }
                'H1' {
                    $LevelText = '# ' ; 
                    $pltColors = $pltH1 ; 
                }
                'H2' {
                    $LevelText = '## ' ; 
                    $pltColors = $pltH2 ; 
                }
                'H3' {
                    $LevelText = '### ' ; 
                    $pltColors = $pltH3 ; 
                }
                'H4' {
                    $LevelText = '#### ' ; 
                    $pltColors = $pltH4 ; 
                }
                'H5' {
                    $LevelText = '##### ' ; 
                    $pltColors = $pltH5 ; 
                }
                'Debug' {
                    $LevelText = 'DEBUG: ' ; 
                    $pltColors = $pltDebug ; 
                    if ($useHost) {} else {if (!$NoEcho) { Write-Degug $smsg } }  ;                
                }
                'Verbose' {
                    $LevelText = 'VERBOSE: ' ; 
                    $pltColors = $pltVerbose ; 
                    if ($useHost) {}else {if (!$NoEcho) { Write-Verbose ($smsg) } } ;          
                }
                'Prompt' {
                    $LevelText = 'PROMPT: ' ; 
                    $pltColors = $pltPrompt ; 
                }
                'Success' {
                    $LevelText = 'SUCCESS: ' ; 
                    $pltColors = $pltSuccess ; 
                }
            } ;
            # build msg string down here, once, v in ea above
            #$smsg = $EchoTime ;
            # always defer to explicit cmdline colors
            if($pltColors.foregroundcolor){
                if(-not ($pltWH.keys -contains 'foregroundcolor')){
                    $pltWH.add('foregroundcolor',$pltColors.foregroundcolor) ; 
                } elseif($pltWH.foregroundcolor -eq $null){
                    $pltWH.foregroundcolor = $pltColors.foregroundcolor ; 
                } ; 
            } ; 
            if($pltColors.backgroundcolor){
                if(-not ($pltWH.keys -contains 'backgroundcolor')){
                    $pltWH.add('backgroundcolor',$pltColors.backgroundcolor) ; 
                } elseif($pltWH.backgroundcolor -eq $null){
                    $pltWH.backgroundcolor = $pltColors.backgroundcolor ; 
                } ; 
            } ; 
 
            if ($useHost) {
                if(-not $Indent){
                    if($Level -match '(Debug|Verbose)' ){
                        #$pltWH.Object += ($LevelText + '(' + $Object + ')') ; 
                        $pltWH.Object += "$($LevelText) ($($Object))" ;
                    } else { 
                        #$pltWH.Object += $LevelText + $Object ;
                        $pltWH.Object += "$($LevelText) $($Object)" ;
                    } ; 
                    $smsg = "write-host w`n$(($pltWH|out-string).trim())" ; 
                    write-verbose $smsg ; 
                    #write-host @pltErr $smsg ; 
                    write-host @pltwh ; 
                } else { 
                    # indent support
                    foreach ($obj in $object){
                        # here we're looping the object, so completely do the object build in here:
                        $pltWH.Object = $EchoTime ; 
                        # issue: empty lines/elements with the above are gen'ing: 15:31:44: VERBOSE:  ()
                        if($Level -match '(Debug|Verbose)' ){
                            if($obj.length -gt 0){
                                $pltWH.Object += "$($LevelText) ($($obj))" ;
                            } else { 
                                $pltWH.Object += "$($LevelText)" ;
                            } ; 
                        } else { 
                            $pltWH.Object += "$($LevelText) $($obj)" ;
                        } ; 
                        $smsg = "write-host w`n$(($pltWH|out-string).trim())" ; 
                        write-verbose $smsg ; 
                        # write the indent, then writhe the styled obj/msg
                        Write-Host -NoNewline $($PadChar * $CurrIndent)  ; 
                        #write-host @pltWH -object $obj ; 
                        write-host @pltwh ; 
                    } ; 


                } ; 
            } 
            # Write log entry to $Path
            "$FormattedDate $LevelText : $Object" | Out-File -FilePath $Path -Append  ;

        } ;  # if-E -Demo ; 

    }  ; # PROC-E
    End {}  ;
}

#*------^ Write-Log.ps1 ^------


#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function Archive-Log,Cleanup,get-ArchivePath,get-EventsFiltered,get-lastlogon,get-lastevent,get-lastlogon,get-lastshutdown,get-lastsleep,get-lastwake,get-winEventsLoopedIDs,Start-IseTranscript,Start-Log,start-TranscriptLog,Stop-TranscriptLog,Test-Transcribing,test-Transcribing2,Test-TranscriptionSupported,Write-Log -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWBy/ws9Vn3zph968wY0xJduu
# dLagggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQLrElx
# MvBWRq0rjMy8fP+DlCj+TTANBgkqhkiG9w0BAQEFAASBgAVX9A96c9MRyZFczWX0
# k3VHlBWe5TRobjYPbLEEqf4c2yFDQXE4tCkl8ysxWgY3b27W6sjACiEOGccON7vh
# 9VISQd3scP2lfnzJn+O8iv1yXi6wPDHWziiRNVVrtvai2qR2ynQNgEmWjKQFCCqK
# wmdkKI51dr+3DBOu6RWay8cp
# SIG # End signature block
