#*----------------v Function test-Transcribing2 v----------------
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
} ; #*----------------^ END Function test-Transcribing2 ^----------------