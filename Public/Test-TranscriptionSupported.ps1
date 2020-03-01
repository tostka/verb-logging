#*----------------v Function Test-TranscriptionSupported v----------------
function Test-TranscriptionSupported {
    <#
    .SYNOPSIS
    Tests to see if the current host supports transcription.
    .DESCRIPTION
    Powershell.exe supports transcription, WinRM and ISE do not.
    .Example
    #inside powershell.exe
    Test-Transcription
    #returns true
    Description
    -----------
    Returns a $true if the host supports transcription; $false otherwise
    #>
    $ExternalHost = $host.gettype().getproperty("ExternalHost",
    [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
    try {
      [Void]$ExternalHost.gettype().getproperty("IsTranscribing",
      [Reflection.BindingFlags]"NonPublic,Instance").getvalue($ExternalHost, @())
      $true
    } catch {
      $false
    } # try-E
}#*----------------^ END Function Test-TranscriptionSupported ^----------------