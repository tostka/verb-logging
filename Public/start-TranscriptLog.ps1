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