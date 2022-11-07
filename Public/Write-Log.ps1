#*------v Write-Log.ps1 v------
function Write-Log {
    <#
    .SYNOPSIS
    Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-11
    FileName    : Write-Log.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-logging
    Tags        : Powershell,Logging,Output,Echo,Console
    AddedCredit : Jason Wasser
    AddedWebsite:	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
    AddedTwitter:	@wasserja
    REVISIONS
    * 9:07 AM 3/21/2022 added -Level verbose & prompt support, flipped all non-usehost options, but verbose, from w-v -> write-host; added level prefix to console echos
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
    Reimplementation of original concept by Jason Wasser.
    .PARAMETER Message  
    Message is the content that you wish to add to the log file.
    .PARAMETER Path  
    The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
    .PARAMETER Level  
    Specify the criticality of the log information being written to the log (defaults Info): (Info|Warn|Verbose|Error|Debug|H1|H2|H3)[-level Info]
    .PARAMETER useHost  
    Switch to use write-host rather than write-[verbose|warn|error] (does not apply to H1|H2|H3|DEBUG which alt via uncolored write-host) [-useHost]
    .PARAMETER NoEcho
    Switch to suppress console echos (e.g log to file only [-NoEcho]
    .PARAMETER NoClobber  
    Use NoClobber if you do not wish to overwrite an existing file.
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .EXAMPLE
        PS>  Write-Log -Message 'Log message'   ;
        Writes the message to default log loc (c:\Logs\PowerShellLog.log, -level defaults to Info).
        .EXAMPLE
        PS> Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log ;
        Writes the content to the specified log file and creates the path and file specified.
        .EXAMPLE
        PS> write-log -level warn "some information" -Path c:\tmp\tmp.txt
        WARNING: 10:17:59: some information
        Demo default use of the native write-warning cmdlet (default behavior when -useHost is not used)
        .EXAMPLE
        write-log -level warn "some information" -Path c:\tmp\tmp.txt -usehost
        10:19:14: WARNING: some information
        Demo use of the "warning" color scheme write-host cmdlet (behavior when -useHost *IS* used)
        .EXAMPLE
        PS> Write-Log -level Prompt -Message "Enter Text:" -Path c:\tmp\tmp.txt -usehost  ; 
        PS> invoke-soundcue -type question ; 
        PS> $enteredText = read-host ;
        Echo's a distinctive Prompt color scheme for the message (vs using read-host native non-color-differentiating -prompt parameter), 
        and writes a 'Prompt'-level entry to the log, uses my verb-io:invoke-soundCue to play a the system question sound; then uses promptless read-host to take typed input. 
        PS> Write-Log -level Prompt -Message "Enter Password:" -Path c:\tmp\tmp.txt -usehost  ; 
        PS> invoke-soundcue -type question ; 
        PS> $SecurePW = read-host -AsSecureString ;        
        Variant that demos collection of a secure password using read-host's native -AsSecureString param.
        .EXAMPLE
        PS>  $smsg = "ENTER CERTIFICATE PFX Password: (use 'dummy' for UserName)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } 
        PS>  else{ write-host -foregroundcolor Blue -backgroundcolor White "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>  $pfxcred=(Get-Credential -credential dummy) ;
        PS>  Export-PfxCertificate -Password $pfxcred.password -Cert= $certpath -FilePath c:\path-to\output.pfx;
        Demo use of write-log -level prompt, leveraging the get-credential popup GUI to collect a secure password (without use of username)
        .EXAMPLE
        PS>  # init content in script context ($MyInvocation is blank in function scope)
        PS>  $logfile = join-path -path $ofile -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-LOG.txt"  ;
        PS>  $logging = $True ;
        PS>  $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
        PS>  $smsg="$($sBnr)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug|H1|H2|H3 
        PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>  Example with conditional write-log (with -useHost switch, to trigger native write-host use), else failthru to write-host output
        PS>  .EXAMPLE
        PS>  $transcript = join-path -path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "logs" ;
        PS>  if(!(test-path -path $transcript)){ "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
        PS>  $transcript=join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))"  ;
        PS>  $transcript+= "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
        PS>  # add log file variant as target of Write-Log:
        PS>  $logfile=$transcript.replace("-Transcript","-LOG").replace("-trans-log","-log")
        PS>  if($whatif){
        PS>      $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
        PS>      $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
        PS>  } else {
        PS>      $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
        PS>      $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
        PS>  } ;
        PS>  if($Ticket){
        PS>      $logfile=$logfile.replace("-BATCH","-$($Ticket)") ;
        PS>      $transcript=$transcript.replace("-BATCH","-$($Ticket)") ;
        PS>  } else {
        PS>      $logfile=$logfile.replace("-BATCH","-nnnnnn") ;
        PS>      $transcript=$transcript.replace("-BATCH","-nnnnnn") ;
        PS>  } ;
        PS>  $logging = $True ;
        PS>  $sBnr="#*======v START PASS:$($ScriptBaseName) v======" ;
        PS>  $smsg= "$($sBnr)" ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        More complete boilerplate including $whatif & $ticket
        .EXAMPLE
        PS>  $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
        PS>  $pltSL.Tag = "$(split-path -path $CSVPath -leaf)"; # build tag from a variable
        PS>  # construct log name on calling script/function fullname
        PS>  if($PSCommandPath){ $logspec = start-Log -Path $PSCommandPath @pltSL }
        PS>  else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL } ;
        PS>  if($logspec){
        PS>      $logging=$logspec.logging ;
        PS>      $logfile=$logspec.logfile ;
        PS>      $transcript=$logspec.transcript ;
        PS>      $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        PS>      start-Transcript -path $transcript ;
        PS>  } else {throw "Unable to configure logging!" } ;
        PS>  $sBnr="#*======v $(${CmdletName}): v======" ;
        PS>  $smsg = $sBnr ;
        PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
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
        [ValidateSet('Error','Warn','Info','H1','H2','H3','Debug','Verbose','Prompt')]
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
                $LevelText = 'ERROR: ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 60 -verbose:$false} else { $plt=@{foregroundcolor='yellow';backgroundcolor='red'};};
                    write-host @plt $smsg
                } else {if (!$NoEcho) { Write-Error ($smsg + $Message) } } ;
            }
            'Warn' {
                $LevelText = 'WARNING: ' ; $smsg = $EchoTime ;
                if ($useHost) {
                        $smsg += $LevelText + $Message ; 
                        if($buseCC){$plt=get-colorcombo 52 -verbose:$false} else { $plt=@{foregroundcolor='black';backgroundcolor='yellow'};};
                        write-host @plt $smsg ; 
                } else {if (!$NoEcho) { Write-Warning ($smsg + $Message) } } ;
            }
            'Info' {
                $LevelText = 'INFO: ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 2 -verbose:$false} else { $plt=@{foregroundcolor='green';backgroundcolor='black'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Host ($smsg + $Message) } } ;                
            }
            'H1' {
                $LevelText = '# ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 22 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='darkyellow'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Host ($smsg + $Message) } } ;
            }
            'H2' {
                $LevelText = '## ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 25 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='gray'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Host ($smsg + $Message) } } ;
            }
            'H3' {
                $LevelText = '### ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 30 -verbose:$false } else { $plt=@{foregroundcolor='black';backgroundcolor='darkgray'};};
                    write-host @plt $smsg 
                }else {if (!$NoEcho) { Write-Host ($smsg + $Message) } } ;
            }
            'Debug' {
                # use of 'real' write-debug has too many dependancies, to function ; over-complicates the concept, just use a pale echo in parenthesis
                $LevelText = 'DEBUG: ' ; $smsg = ($EchoTime + $LevelText + '(' + $Message + ')') ;
                $smsg += $LevelText + $Message ; 
                if($buseCC){$plt=get-colorcombo 4 -verbose:$false } else { $plt=@{foregroundcolor='red';backgroundcolor='black'};};
                write-host @plt $smsg ;
                if (!$NoEcho) { Write-Host $smsg }  ;                
            }
            'Verbose' {
                $LevelText = 'VERBOSE: ' ; $smsg = ($EchoTime + $LevelText + '(' + $Message + ')') ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 1 -verbose:$false } else { $plt=@{foregroundcolor='Gray';backgroundcolor='black'};};
                    write-host @plt $smsg ;
                }else {if (!$NoEcho) { Write-Verbose ($smsg + $Message) } } ;          
            }
            'Prompt' {
                # display/log input prompts with distinctive tag, and display them Blue on White, for attention-grabbing
                $LevelText = 'PROMPT: ' ; $smsg = $EchoTime ;
                if ($useHost) {
                    $smsg += $LevelText + $Message ; 
                    if($buseCC){$plt=get-colorcombo 15 -verbose:$false} else { $plt=@{foregroundcolor='Blue';backgroundcolor='White'};};
                    write-host @plt $smsg ;
                } else {if (!$NoEcho) { Write-Host ($smsg + $Message) } } ;                       
            }
        } ;
        # Write log entry to $Path
        "$FormattedDate $LevelText : $Message" | Out-File -FilePath $Path -Append  ;
    }  ; # PROC-E
    End {}  ;
}

#*------^ Write-Log.ps1 ^------
