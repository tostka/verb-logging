#*------v Test-TranscriptionSupported.ps1 v------
function Test-TranscriptionSupported {
    <#
    .SYNOPSIS
    Test-TranscriptionSupported -Tests to see if the current host supports transcription.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 
    FileName    : Test-TranscriptionSupported.ps1
    License     : 
    Copyright   : 
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 8:45 AM 11/23/2020 add verbose supp
    # 12:08 PM 9/22/2020 updated to exempt ISE v5 testing - force true, as it fails the test but *does* support transcription ; revised CBH, origin lost to the mists of time, been in use since at least 2009 or so
    .DESCRIPTION
    Test-TranscriptionSupported -Tests to see if the current host supports transcription. Returns a $true if the host supports transcription; $false otherwise
    OUTPUT
    System.Boolean
    .EXAMPLE
    if(Test-TranscriptionSupported){start-transcript xxxx} ; 
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM() # empty param, min verbose req
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if( ( ($host.Name -eq "Windows PowerShell ISE Host") -AND ($host.version.major -ge 5) ) ){
        # ps ise5 doesn't properly pass  ExternalHost test below - always fails, although the host fully supports transcription commands
        $true | Write-Output ; # force it true
    } else { 
        # ps and ps ise -lt 5 work fine with this older test Ise v4 fails, ps v1+ pass
        $ExternalHost = $host.gettype().getproperty("ExternalHost",
            [reflection.bindingflags]"NonPublic,Instance").getvalue($host, @())
        try {
            # test below does *not* properly detect psv5's support of transcribing - fails, though the host will transcribe
            [Void]$ExternalHost.gettype().getproperty("IsTranscribing",
            [Reflection.BindingFlags]"NonPublic,Instance").getvalue($ExternalHost, @())
            $true | Write-Output
        } catch {$false | Write-Output} 
    } ; 
} ;
#*------^ Test-TranscriptionSupported.ps1 ^------