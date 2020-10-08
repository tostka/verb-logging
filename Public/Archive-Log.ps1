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
    # 3:04 PM 10/8/2020 add force, to overwrite on conflict
    # 3:37 PM 9/22/2020 added looping/mult $filepath added code to validate $filepath, and force $archpath if not already set
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
    .DESCRIPTION
    Archive-Log - ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .PARAMETER  FilePath
    array of paths to log files to be archived[-FilePath 'c:\pathto\file1.txt','c:\pathto\file2.txt']
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
        Archive-Log $transcript ;
    } # if-E
    Full stack use of get-ArchivePath(), Start-iseTranscript(), Stop-TranscriptLog(), & Archive-Log()
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM(
        [parameter(Mandatory=$true,HelpMessage="Array of paths to log files to be archived[-FilePath 'c:\pathto\file1.txt','c:\pathto\file2.txt']")] 
        [ValidateScript({Test-Path $_})]
        [array]$FilePath,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    if ($showdebug) {"Archive-Log"}
    if( (!$archpath) -OR (-not(Test-Path $archPath -ea 0 )) ){
            $archPath = get-ArchivePath ;
    } ; 

    # valid filepath passed in
    $error.clear
    foreach($fpath in $FilePath){
        Try {
            write-verbose "$((get-date).ToString('HH:mm:ss')):`$archPath:$archPath `n`$FilePath:$FilePath"
        
            if ((Test-Path $fpath)) {
                write-host  ("$((get-date).ToString('HH:mm:ss')):Moving `n$fpath `n to:" + $archPath)

                # 9:59 AM 12/10/2014 pretest for clash

                $ArchTarg = (Join-Path $archPath (Split-Path $fpath -leaf));
                if ($showdebug) {write-host -foregroundcolor green "`$ArchTarg:$ArchTarg"}
                if (Test-Path $ArchTarg) {
                    $FilePathObj = Get-ChildItem $fpath;
                    $ArchTarg = (Join-Path $archPath ($FilePathObj.BaseName + "-B" + $FilePathObj.Extension))
                    if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):CLASH DETECTED, RENAMING ON MOVE: `n`$ArchTarg:$ArchTarg"};
                    # 3:04 PM 10/8/2020 add force, to overwrite on conflict
                    Move-Item -path $fpath -dest $ArchTarg -Force
                } else {
                    # 8:41 AM 12/10/2014 add error checking
                    $error.Clear()
                    Move-Item -path $fpath -dest $archPath -Force
                } # if-E
            } else {
            if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):NO TRANSCRIPT FILE FOUND! SKIPPING MOVE"}
            }  # if-E

        } # TRY-E
        Catch {
            $ErrTrapd=$Error[0] ;
            $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            CONTINUE ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ;
    } ;  # loop-E
    if (!(Test-Transcribing)) {  return $true } else {return $false};
}

#*------^ Archive-Log.ps1 ^------