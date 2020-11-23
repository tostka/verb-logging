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
    * 12:05 PM 3/1/2020 rewrote header to loosely emulate most of psv5.1 stock transcirpt header
    * 8:40 AM 3/11/2015 revised to support PSv3's break of the $psise.CurrentPowerShellTab.consolePane.text object
        and replacement with the new...
            $psise.CurrentPowerShellTab.consolePane.text
        (L13 FEs are PSv4, lyn650 is PSv2)
    * 9:22 AM 3/5/2015 tweaked, added autologname generation (from script loc & name)
    * 09/10/2010 17:27:22 - original
    TYPICAL USAGE:
        Call from Cleanup() (or script-end, only populated post-exec, not realtime)
        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        if($host.Name -eq "Windows PowerShell ISE Host"){
                # 8:46 AM 3/11/2015 shift the logfilename gen out here, so that we can arch it
                $Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
                write-host "`$Logname: $Logname";
                Start-iseTranscript -logname $Logname ;
                # optional, normally wouldn't archive ISE debugging passes
                #Archive-Log $Logname ;
            } else {
                if($showdebug -OR $verbose){ write-host -ForegroundColor Yellow "$((get-date).ToString('HH:mm:ss')):Stop Transcript" };
                Stop-TranscriptLog ;
                if($showdebug -OR $verbose){ write-host -ForegroundColor Yellow "$((get-date).ToString('HH:mm:ss')):Archive Transcript" };
                Archive-Log $transcript ;
            } # if-E
        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
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
    Archive-Log $Logname ;
    Archives specified file to Archive
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