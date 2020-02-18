#*----------------v Function Archive-Log v----------------
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
}#*----------------^ END Function Archive-Log ^----------------
