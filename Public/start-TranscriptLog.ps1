#*----------------v Function Start-TranscriptLog v----------------
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

    param(
      [parameter(Mandatory=$true,Helpmessage="Transcript location")]
      [ValidateNotNullOrEmpty()]
      [alias("tfile")]
      [string]$Transcript
    )

    # Have to set relative $scriptDir etc OUTSIDE THE FUNC, build full path to generic core $Transcript vari, and then
    # start-transcript will auto use it (or can manual spec it with -path)

    if($host.Name -NE "Windows PowerShell ISE Host"){
        Try {
                if (Test-Transcribing) {Stop-Transcript}

                if($showdebug) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$Transcript: $($Transcript)" -verbose:$Verbose };
                # prevaidate specified logging dir is present
                $TransPath=(Split-Path $Transcript).tostring();
                if($showdebug) {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose };
                if (Test-Path $TransPath ) { } else {write-Verbose "$((get-date).ToString('HH:mm:ss')): `$TransPath: $($TransPath)" -verbose:$Verbose ; mkdir $TransPath};
                #invoke-pause2
                Start-Transcript -path $Transcript
                if (Test-Transcribing) {  return $true } else {return $false};
            } Catch {
                Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to create $TransPath"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
                Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
            }  # try-E;

    } else {
        write-host "Test-Transcribing:SKIP PS ISE does not support transcription commands [returning $true]";
        return $true ;
    };  # if-E
}#*----------------^ END Function Start-TranscriptLog ^----------------