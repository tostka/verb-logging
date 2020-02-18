#*----------------v Function Stop-TranscriptLog v----------------
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
}#*----------------^ END Function Stop-TranscriptLog ^----------------