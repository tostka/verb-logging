#*----------------v Function Test-Transcribing v----------------
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
} #*----------------^ END Function Test-Transcribing ^----------------