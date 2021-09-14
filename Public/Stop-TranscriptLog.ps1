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