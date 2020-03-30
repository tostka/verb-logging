#*------v Function Write-Log v------
function Write-Log {
    <#
    .SYNOPSIS
    Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
    .NOTES
    Author: Jason Wasser @wasserja
    Website:	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
    Twitter:	@wasserja
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 3:50 PM 3/29/2020 minor tightening layout
    * 11:34 AM 8/26/2019 fixed missing noecho parameter desig in comment help
    * 9:31 AM 2/15/2019:Write-Log: added Level:Debug support, and broader init
        block example with $whatif & $ticket support, added -NoEcho to suppress console
        echos and just use it for writing logged output
    * 8:57 PM 11/25/2018 Write-Log:shifted copy to verb-transcript, added defer to scope $script versions
    * 2:30 PM 10/18/2018 added -useHost to have it issue color-keyed write-host commands vs write-(warn|error|verbose)
        switched timestamp into the function (as $echotime), rather than redundant code in the $Message contstruction.
    * 10:18 AM 10/18/2018 cleanedup, added to pshelp, put into OTB fmt, added trailing semis, parame HelpMessages, and -showdebug param
    * Code simplification and clarification - thanks to @juneb_get_help  ;
    * Added documentation.
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks  ;
    * Revised the Force switch to work as it should - thanks to @JeffHicks  ;

    To Do:  ;
    * Add error handling if trying to create a log file in a inaccessible location.
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate  ;
        duplicates.
    .DESCRIPTION
    The Write-Log function is designed to add logging capability to other scripts.
    In addition to writing output and/or verbose you can write to a log file for  ;
    later debugging.
    .PARAMETER Message  ;
    Message is the content that you wish to add to the log file.
    .PARAMETER Path  ;
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    .PARAMETER Level  ;
    Specify the criticality of the log information being written to the log defaults Info: (Error|Warn|Info)  ;
    .PARAMETER useHost  ;
    Switch to use write-host rather than write-[verbose|warn|error] [-useHost]
    .PARAMETER NoEcho
    Switch to suppress console echos (e.g log to file only [-NoEcho]
    .PARAMETER NoClobber  ;
    Use NoClobber if you do not wish to overwrite an existing file.
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Writes output to the specified Path.
    .EXAMPLE
    Write-Log -Message 'Log message'   ;
    Writes the message to c:\Logs\PowerShellLog.log.
    .EXAMPLE
    Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
    Writes the content to the specified log file and creates the path and file specified.
    .EXAMPLE
    Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error  ;
    Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
    .EXAMPLE
    # init content in script context ($MyInvocation is blank in function scope)
    $logfile = join-path -path $ofile -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-LOG.txt"  ;
    $logging = $True ;
    # ...
    $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
    $smsg="$($sBnr)" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    Example that uses a variable and the -useHost switch, to trigger write-host use
    .EXAMPLE
    $transcript = join-path -path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "logs" ;
    if(!(test-path -path $transcript)){ "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    $transcript=join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))"  ;
    $transcript+= "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
    # add log file variant as target of Write-Log:
    $logfile=$transcript.replace("-Transcript","-LOG").replace("-trans-log","-log")
    if($whatif){
        $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
        $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
    } else {
        $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
        $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
    } ;
    if($Ticket){
        $logfile=$logfile.replace("-BATCH","-$($Ticket)") ;
        $transcript=$transcript.replace("-BATCH","-$($Ticket)") ;
    } else {
        $logfile=$logfile.replace("-BATCH","-nnnnnn") ;
        $transcript=$transcript.replace("-BATCH","-nnnnnn") ;
    } ;
    $logging = $True ;

    $sBnr="#*======v START PASS:$($ScriptBaseName) v======" ;
    $smsg= "$($sBnr)" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
    More complete boilerplate including $whatif & $ticket
    .LINK
    https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0  ;
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Message is the content that you wish to add to the log file")]
        [ValidateNotNullOrEmpty()][Alias("LogContent")]
        [string]$Message,
        [Parameter(Mandatory = $false, HelpMessage = "The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.")][Alias('LogPath')]
        [string]$Path = 'C:\Logs\PowerShellLog.log',
        [Parameter(Mandatory = $false, HelpMessage = "Specify the criticality of the log information being written to the log defaults Info: (Error|Warn|Info)")][ValidateSet("Error", "Warn", "Info", "Debug")]
        [string]$Level = "Info",
        [Parameter(HelpMessage = "Switch to use write-host rather than write-[verbose|warn|error] [-useHost]")]
        [switch] $useHost,
        [Parameter(HelpMessage = "Switch to suppress console echos (e.g log to file only [-NoEcho]")]
        [switch] $NoEcho,
        [Parameter(Mandatory = $false, HelpMessage = "Use NoClobber if you do not wish to overwrite an existing file.")]
        [switch]$NoClobber,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )  ;

    Begin {$VerbosePreference = 'Continue'  ; }  ;
    Process {
        # If the file already exists and NoClobber was specified, do not write to the log.
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."  ;
            Return  ;
        } elseif (!(Test-Path $Path)) {
            # create the file including the path when missing.
            Write-Verbose "Creating $Path."  ;
            $NewLogFile = New-Item $Path -Force -ItemType File  ;
        } else {
          # Nothing to see here yet.
        }  ;

        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  ;
        $EchoTime = "$((get-date).ToString('HH:mm:ss')):" ;

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                if ($useHost) {write-host -foregroundcolor red ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Error ($EchoTime + $Message) } } ;
                $LevelText = 'ERROR:'  ;
            }
            'Warn' {
                if ($useHost) {write-host -foregroundcolor yellow ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Warning ($EchoTime + $Message) } } ;
                $LevelText = 'WARNING:'  ;
            }
            'Info' {
                if ($useHost) {write-host -foregroundcolor green ($EchoTime + $Message) }
                else {if (!$NoEcho) { Write-Verbose ($EchoTime + $Message) } } ;
                $LevelText = 'INFO:'  ;
            }
            'Debug' {
                if (!$NoEcho) { Write-Debug -Verbose:$true ($EchoTime + $Message) }  ;
                $LevelText = 'DEBUG:'  ;
            }
        } ;

        # Write log entry to $Path
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append  ;
    }  ; # PROC-E
    End {}  ;
} ; #*------^ END Function Write-Log ^------
