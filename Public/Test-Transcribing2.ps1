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