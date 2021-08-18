#*------v Write-Log.ps1 v------
function Write-Log {
    <#
    .SYNOPSIS
    Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka, http://twitter.com/tostka
    Additional Credits: Based on original concept by Jason Wasser
    Website     :	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
    Twitter     :	@wasserja
    CreatedDate : 2021-06-11
    FileName    : Write-Log.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell,Logging,Output,Echo
    REVISIONS   :
    * 3:11 PM 8/17/2021 added verbose suppress to the get-colorcombo calls, clutters the heck out of outputs on verbose, no benef.
    * 10:53 AM 6/16/2021 get-help isn't displaying param details, pulled erroneous semi's from end of CBH definitions
    * 7:59 AM 6/11/2021 added H1|2|3 md-style #|##|## header tags ; added support for get-colorcombo, and enforced bg colors (legible regardless of local color scheme of console); expanded CBH, revised Author - it's diverged so substantially from JW's original concept, it's now "inspired-by", less than a variant of the original.
    * 10:54 AM 5/7/2021 pulled weird choice to set: $VerbosePreference = 'Continue' , that'd reset pref everytime called
    * 8:46 AM 11/23/2020 ext verbose supp
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
    .DESCRIPTION
    The Write-Log function is designed to add logging capability to other scripts.
    In addition to writing output and/or verbose you can write to a log file for  ;
    later debugging.
    .PARAMETER Message  
    Message is the content that you wish to add to the log file.
    .PARAMETER Path  
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    .PARAMETER Level  
    Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|Debug)[-level Info]
    .PARAMETER useHost  
    Switch to use write-host rather than write-[verbose|warn|error] [-useHost]
    .PARAMETER NoEcho
    Switch to suppress console echos (e.g log to file only [-NoEcho]
    .PARAMETER NoClobber  
    Use NoClobber if you do not wish to overwrite an existing file.
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Writes output to the specified Path.
    .EXAMPLE
    Write-Log -Message 'Log message'   ;
    Writes the message to default log loc (c:\Logs\PowerShellLog.log, -level defaults to Info).
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
    $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
    $smsg="$($sBnr)" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug|H1|H2|H3 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    Example with conditional write-log (with -useHost switch, to trigger native write-host use), else failthru to write-host output
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
    .EXAMPLE
    $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
    $pltSL.Tag = "$(split-path -path $CSVPath -leaf)"; # build tag from a variable
    # construct log name on calling script/function fullname
    if($PSCommandPath){ $logspec = start-Log -Path $PSCommandPath @pltSL }
    else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL } ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        start-Transcript -path $transcript ;
    } else {throw "Unable to configure logging!" } ;
    $sBnr="#*======v $(${CmdletName}): v======" ;
    $smsg = $sBnr ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    Example leveraging splatted start-log(), and either $PSCommandPath or $MyInvocation (support varies by host/psversion) to build the log name. 
    .LINK
    https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0  ;
    #>
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Message is the content that you wish to add to the log file")]
        [ValidateNotNullOrEmpty()][Alias("LogContent")]
        [string]$Message,
        [Parameter(Mandatory = $false, HelpMessage = "The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.")]
        [Alias('LogPath')]
        [string]$Path = 'C:\Logs\PowerShellLog.log',
        [Parameter(Mandatory = $false, HelpMessage = "Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|Debug)[-level Info]")]
        [ValidateSet('Error','Warn','Info','H1','H2','H3','Debug')]
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
    Begin {
        $verbose = ($VerbosePreference -eq "Continue") ;  
        if(get-command get-colorcombo -ErrorAction SilentlyContinue){$buseCC=$true} else {$buseCC=$false} ;
    }  ;
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
        $EchoTime = "$((get-date).ToString('HH:mm:ss')): " ;

        # Write message to error, warning, or verbose pipeline and specify $LevelText
        switch ($Level) {
            'Error' {
                $LevelText = 'ERROR: ' ; $smsg = ($EchoTime + $Message) ;
                if ($useHost) {
                    if($buseCC){$plt=get-colorcombo 60 -verbose:$false} else { $plt=@{foregroundcolor='yellow';backgroundcolor='red'};};
                    write-host @plt $smsg
                } else {if (!$NoEcho) { Write-Error $smsg } } ;
            }
            'Warn' {
                $LevelText = 'WARNING: ' ; $smsg = ($EchoTime + $Message) ;
                if ($useHost) {
                        if($buseCC){$plt=get-colorcombo 52 -verbose:$false} else { $plt=@{foregroundcolor='black';backgroundcolor='yellow'};};
                        write-host @plt $smsg ; 
                } else {if (!$NoEcho) { Write-Warning $smsg } } ;
            }
            'Info' {
                $LevelText = 'INFO: ' ; $smsg = ($EchoTime + $Message) ;
                if ($useHost) {
                    if($buseCC){$plt=get-colorcombo 2 -verbose:$false} else { $plt=@{foregroundcolor='green';backgroundcolor='black'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Verbose $smsg } } ;                
            }
            'H1' {
                $LevelText = '# ' ; $smsg = ($EchoTime + $LevelText + $Message) ;
                if ($useHost) {
                    if($buseCC){$plt=get-colorcombo 22 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='darkyellow'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Verbose $smsg } } ;
            }
            'H2' {
                $LevelText = '## ' ; $smsg = ($EchoTime + $LevelText + $Message) ;
                if ($useHost) {
                    if($buseCC){$plt=get-colorcombo 25 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='gray'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Verbose $smsg } } ;
            }
            'H3' {
                $LevelText = '### ' ; $smsg = ($EchoTime + $LevelText + $Message) ;
                if ($useHost) {
                    if($buseCC){$plt=get-colorcombo 30 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='darkgray'};};
                    write-host @plt $smsg 
                }else {if (!$NoEcho) { Write-Verbose $smsg } } ;
            }
            'Debug' {
                # use of 'real' write-debug has too many dependancies, to function ; over-complicates the concept, just use a pale echo in parenthesis
                $LevelText = 'DEBUG: ' ; $smsg = ($EchoTime + $LevelText + '(' + $Message + ')') ;
                if($buseCC){$plt=get-colorcombo 4 -verbose:$false } else { $plt=@{foregroundcolor='red';backgroundcolor='black'};};
                write-host @plt $smsg ;
                if (!$NoEcho) { write-verbose $smsg }  ;                
            }
        } ;
        # Write log entry to $Path
        "$FormattedDate $LevelText : $Message" | Out-File -FilePath $Path -Append  ;
    }  ; # PROC-E
    End {}  ;
}

#*------^ Write-Log.ps1 ^------