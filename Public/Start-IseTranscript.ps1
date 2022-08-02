#*------v Start-IseTranscript.ps1 v------
Function Start-IseTranscript {
    <#
    .SYNOPSIS
    This captures output from a script to a created text file
    .NOTES
    NAME:  Start-iseTranscript
    EDITED BY: Todd Kadrie
    AUTHOR: ed wilson, msft
    REVISIONS:
    * 8:38 AM 7/29/2022 updated CBH example, to preclear consolet text, ahead of use (at the normal start-transcript loc); also added example code to defer to new start-transcript support on ISE for Psv5+ 
    * 12:05 PM 3/1/2020 rewrote header to loosely emulate most of psv5.1 stock transcirpt header
    * 8:40 AM 3/11/2015 revised to support PSv3's break of the $psise.CurrentPowerShellTab.consolePane.text object
        and replacement with the new...
            $psise.CurrentPowerShellTab.consolePane.text
        (L13 FEs are PSv4, lyn650 is PSv2)
    * 9:22 AM 3/5/2015 tweaked, added autologname generation (from script loc & name)
    * 09/10/2010 17:27:22 - original
    KEYWORDS: Transcript, Logging, ISE, Debugging
    HSG: WES-09-25-10
    .DESCRIPTION
    use if($host.Name -eq "Windows PowerShell ISE Host"){ } to detect and fire this only when in ISE
    .PARAMETER Logname
    the name and path of the log file.
    .INPUTS
    [string]/fso file object
    .OUTPUTS
    [io.file]
    .EXAMPLE
    PS> #region  ; #*------v GENERIC PATH DETECTION/TRANSCRIPT CODE v------
    PS> # switch path detection depending on if in func or in script
    PS> switch($pscmdlet.myinvocation.mycommand.CommandType){
    PS>     'Function' {
    PS>         $smsg = "(CommandType:Function:interpolating Context Path values from other configured sources)" ;
    PS>         write-verbose $smsg ;
    PS>         Try {$ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop }
    PS>         Catch {$ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path } ;
    PS>         $ScriptDir= $ScriptRoot ;
    PS>         $ScriptBaseName = $pscmdlet.myinvocation.mycommand.Name ;
    PS>         $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($pscmdlet.myinvocation.mycommand.Name ) ;
    PS>         $smsg += "`n--Legacy Path resolutions:" ;
    PS>         $smsg += "`n`$ScriptDir (fr `$PSScriptRoot):`t$($ScriptDir)" ;
    PS>         $smsg += "`n`$ScriptBaseName (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptBaseName)" ;
    PS>         $smsg += "`n`$ScriptNameNoExt (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptNameNoExt)" ;
    PS>     }
    PS>     'ExternalScript' {
    PS>         $smsg = "CommandType:ExternalScript:.ps1:Determining values from legacy sources)" ;
    PS>         write-verbose $smsg ;
    PS>         TRY{
    PS>             $ScriptDir=((Split-Path -parent $MyInvocation.MyCommand.Definition -ErrorAction STOP) + "\");
    PS>             $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ;
    PS>             $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
    PS>             $smsg += "`n--Legacy Path resolutions:" ;
    PS>             $smsg += "`n`$ScriptDir (fr `$MyInvocation):`t$($ScriptDir)" ;
    PS>             $smsg += "`n`$ScriptBaseName (fr &{$myInvocation}).ScriptName):`t$($ScriptBaseName)" ;
    PS>             $smsg += "`n`$ScriptNameNoExt (fr `$MyInvocation.InvocationName):`t$($ScriptNameNoExt)" ;
    PS>             $smsg += "`n`$MyInvocation.MyCommand.Path:`t$((Split-Path -parent $MyInvocation.MyCommand.Path))" ;
    PS>         } CATCH {
    PS>             $smsg = "Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ;
    PS>             $smsg += "(interpolating values from other configured sources)" ;
    PS>         } ;
    PS>     }
    PS>     default {
    PS>         write-warning "Unrecognized `$pscmdlet.myinvocation.mycommand.CommandType:$($pscmdlet.myinvocation.mycommand.CommandType)!" ;
    PS>     } ;
    PS> } ; 
    PS> write-verbose $smsg ; 
    PS> $transcript = join-path -path $ScriptDir -childpath 'Logs' ; 
    PS> if(!(test-path $transcript)){ mkdir $transcript -verbose } ; 
    PS> $transcript = join-path $transcript -childpath "$($ScriptNameNoExt)" ; 
    PS> # $transcript += "-TAG" ; 
    PS> if($whatif){$transcript += "-WHATIF" } ELSE { $transcript += "-EXEC" } ; 
    PS> $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')" ; 
    PS> $transcript += "-trans-log.txt" ; 
    PS> $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
    PS> TRY {
    PS>     if($psise -and ($host.version.major -lt 5)){
    PS>         Write-host -foregroundcolor white "Start-Transcript *is not* supported under PS$($host.version.major): (pre-clearing console for trailing start-ISETranscript use)" ;
    PS>         if ($host.version.major -lt 3) {$psISE.CurrentPowerShellTab.Output.Clear()}
    PS>         else {$psise.CurrentPowerShellTab.consolePane.Clear()} ;
    PS>     } else {
    PS>         $startResults = Start-transcript -path $transcript -ErrorAction stop;
    PS>         write-host $startResults ;
    PS>     } ;
    PS> } CATCH {
    PS>     Break ;
    PS> } ;    
    PS> #endregion  ; #*------^ END GENERIC TRANSCRIPT W PATH DETECTION ^------
    PS> #region  ; #*------v START-ISETRANSCRIPT WRAPPER BLOCK v------    
    PS> write-verbose "2. Call from Cleanup() (or script-end, only populated post-exec, not realtime)" ; 
    PS> if($psise -and ($host.version.major -lt 5)){
    PS>     if(-not $transcript){
    PS>         if($scriptNameNoExt){
    PS>             $transcript= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
    PS>         } else {
    PS>             $smsg = "unable to find/construct a $transcript!" ; 
    PS>             write-warning $smsg ; 
    PS>             throw $smsg ; 
    PS>             Break ; 
    PS>         } ;  
    PS>     } ;    
    PS>     write-host "`$Transcript: $transcript";
    PS>     Start-iseTranscript -logname $transcript ;
    PS>     # optional, normally wouldn't archive ISE debugging passes
    PS>     #Archive-Log $Logname ;
    PS> } else {
    PS>     $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
    PS>     write-host $stopResults ; 
    PS>     #Archive-Log $transcript ;
    PS> } ; 
    PS> #endregion  ; #*------^ END START-ISETRANSCRIPT WRAPPER BLOCK ^------  
    Demo full set of wrapper calls covering path detection, transcript path construction, and calls to Start-ISETranscript
    .Link
    Http://www.ScriptingGuys.com
    #Requires -Version 2.0
    #>
    [CmdletBinding()]
    Param([string]$Logname)
    $verbose = ($VerbosePreference -eq "Continue") ; 
    if (!($Logname)) {
        # build from script if nothing passed in
        if (!($scriptDir) -OR !($scriptNameNoExt)) {
            throw "`$scriptDir & `$scriptNameNoExt are REQUIRED values from the main script SUBMAIN. ABORTING!"
            # can't interpolate from here, because the script because the invokation is the function, rather than the script
        } ;
        # 1:06 PM 4/26/2017 flip log ext to .txt - so OL can preview it properly for fast review
        $Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + $timeStampNow + "-ISEtrans-log.txt")) ;
        write-host "ISE Trans `$Logname: $Logname";
    };
    <# original header: Pre-PSv5
    $TranscriptHeader = @"
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date)
UserName: $env:username
UserDomain: $env:USERDNSDOMAIN
ComputerName: $env:COMPUTERNAME
Windows version: $((Get-WmiObject win32_operatingsystem).version)
**************************************
Transcript started. Output file is $Logname
"@
#>
    # header (updated to emulate most of Psv5.1 header)
    $OS = Get-WmiObject win32_operatingsystem ; 
    $TranscriptHeader = @"
**************************************
Windows PowerShell ISE Transcript Start
Start Time: $(get-date -format 'yyyyMMddHHmmss')
UserName: $env:userdomain\$env:username
RunAs User: $env:userdomain\$env:username
Configuration Name: 
Machine: $env:COMPUTERNAME ($($os.caption.tostring()) $($os.version.tostring())) 
Windows version: $((Get-WmiObject win32_operatingsystem).version)
Host Application: $((resolve-path $env:windir\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe).path)
PSVersion: $($host.version.tostring())
PSEdition: Desktop
PSCompatibleVersions: 
Platform: $($os.CreationClassName.split('_')[0])NT
BuildVersion: 
CLRVersion: 
WSManStackVersion: 
OS: $($os.caption.tostring()) $($os.version.tostring())
PSRemotingProtocolVersion: 
SerializationVersion: 
**************************************
Transcript started. Output file is $Logname
"@
        $TranscriptHeader | out-file $Logname -append

        #$psISE.CurrentPowerShellTab.Output.Text >> $Logname
        <# 8:37 AM 3/11/2015 PSv3 broke/hid the above object, new object is
        $psISE.CurrentPowerShellTab.ConsolePane.text
        Note, it's reportedly not realtime, as the Psv2 .type param was
        #>
        if (($host.version) -lt "3.0") {
            # use legacy obj
            $psISE.CurrentPowerShellTab.Output.Text | out-file $Logname -append
        } else {
            # use the new object
            $psISE.CurrentPowerShellTab.ConsolePane.text | out-file $Logname -append
        } # if-E

}

#*------^ Start-IseTranscript.ps1 ^------