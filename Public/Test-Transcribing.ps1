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
    #if($host.Name -ne "Windows PowerShell ISE Host"){
    # actually Psv5 ISE properly supports transcribing: https://www.jonathanmedd.net/2014/09/start-transcript-now-available-in-the-powershell-ise-in-powershell-v5.html
    if( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -lt 5) ){
        write-host "Test-Transcribing:SKIP PS ISE $($host.version.major) does NOT support transcription commands [returning `$true]";
        return $true ;
    } elseif( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -ge 5) ){
        # ISE v5+ can't pass the ExternalHost tests, use test-Transcribing2()
        Test-Transcribing2 | write-output ; 
    } else { 
        $ExternalHost = $host.gettype().getproperty("ExternalHost",
            [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
        try {
            if (Test-TranscriptionSupported) {
                $ExternalHost.gettype().getproperty("IsTranscribing",
                    [reflection.bindingflags]"NonPublic,Instance").getvalue($ExternalHost, @())
            } else {};  
        } catch {Write-Warning "Tested: This host does not support transcription."} ;
    } ;
} ;
#*------^ Test-Transcribing.ps1 ^------