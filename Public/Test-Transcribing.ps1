#*----------------v Function Test-Transcribing v----------------
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
} #*----------------^ END Function Test-Transcribing ^----------------