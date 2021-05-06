﻿#*------v Start-Log.ps1 v------
function Start-Log {
    <#
    .SYNOPSIS
    Start-Log.ps1 - Configure base settings for use of write-Log() logging
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 12/29/2019
    FileName    : Start-Log.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
    * 2:23 PM 5/6/2021 disabled $Path test, no bene, and AllUsers redir doesn't need a real file, just a path ; add example for detecting & redirecting logging, when psCommandPath points to Allusers profile (installed module function)
    * 2:05 PM 3/30/2021 added example demo'ing detect/divert off of AllUsers-scoped installed scripts
    * 1:46 PM 12/21/2020 added example that builds logfile off of passed in .txt (rather than .ps1 path or pscommandpath)
    * 11:39 AM 11/24/2020 updated examples again
    * 9:18 AM 11/23/2020 updated 2nd example to use splatting
    * 12:35 PM 5/5/2020 added -NotTimeStamp param, and supporting code to return non-timestamped filenames
    * 12:44 PM 4/23/2020 shift $path validation to parent folder - with AllUsers scoped scripts, we need to find paths, and *fake* a path to ensure logs aren't added to AllUsers %progfiles%\wps\scripts\(logs). So the path may not exist, but the parent dir should
    * 3:56 PM 2/18/2020 Start-Log: added $Tag param, to support descriptive string for building $transcript name
    * 11:16 AM 12/29/2019 init version
    .DESCRIPTION
    Start-Log.ps1 - Configure base settings for use of write-Log() logging
    Usage:
    #-=-=-=-=-=-=-=-=
    $backInclDir = "c:\usr\work\exch\scripts\" ;
    #*======v FUNCTIONS v======
    $tModFile = "verb-logging.ps1" ; $sLoad = (join-path -path $LocalInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {     Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug -OR $verbose) { Write-Verbose -verbose "Post $sLoad" }; } else {     $sLoad = (join-path -path $backInclDir -childpath $tModFile) ; if (Test-Path $sLoad) {         Write-Verbose -verbose ((Get-Date).ToString("HH:mm:ss") + "LOADING:" + $sLoad) ; . $sLoad ; if ($showdebug -OR $verbose) { Write-Verbose -verbose "Post $sLoad" };     }     else { Write-Warning ((Get-Date).ToString("HH:mm:ss") + ":MISSING:" + $sLoad + " EXITING...") ; exit; } ; } ;
    #*======^ END FUNCTIONS ^======
    #*======v SUB MAIN v======
    [array]$reqMods = $null ; # force array, otherwise single first makes it a [string]
    $reqMods += "Write-Log;Start-Log".split(";") ;
    $reqMods = $reqMods | Select-Object -Unique ;
    if ( !(check-ReqMods $reqMods) ) { write-error "$((get-date).ToString("yyyyMMdd HH:mm:ss")):Missing function. EXITING." ; throw "FAILURE" ; }  ;
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -showdebug:$($showdebug) -whatif:$($whatif) ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
    } else {throw "Unable to configure logging!" } ;
    #-=-=-=-=-=-=-=-=
    .PARAMETER  Path
    Path to target script (defaults to $PSCommandPath)
    .PARAMETER Tag
    Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .EXAMPLE
    $pltSL=@{ NoTimeStamp=$true ; Tag="($TenOrg)-LASTPASS" ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ; 
    if($PSCommandPath){   $logspec = start-Log -Path $PSCommandPath @pltSL ; 
    } else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL ; } ; 
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        if(Test-TranscriptionSupported){
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
            start-transcript -Path $transcript ;
        } ;
    } else {throw "Unable to configure logging!" } ;
    Configure default logging from parent script name
    .EXAMPLE
    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) -NoTimeStamp ;
    if($logspec){
        $logging=$logspec.logging ;
        $logfile=$logspec.logfile ;
        $transcript=$logspec.transcript ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
        start-Transcript -path $transcript ; 
    } else {throw "Unable to configure logging!" } ;
    Configure default logging from parent script name, with no Timestamp
    .EXAMPLE
    $dPref = 'd','c' ; foreach($budrv in $dpref){ if(test-path -path "$($budrv):\scripts" -ea 0 ){ break ;  } ;  } ;
    [regex]$rgxScriptsModsAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)" ;
    [regex]$rgxScriptsModsCurrUserScope="^$([regex]::escape([environment]::getfolderpath('Mydocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)" ;
    if($PSCommandPath){
        if(($PSCommandPath -match $rgxScriptsModsAllUsersScope) -OR ($PSCommandPath -match $rgxScriptsModsCurrUserScope) ){
            # AllUsers or CU installed script/MOD, divert into [$budrv]:\scripts (don't write logs into allusers context folder)
            $logspec = start-Log -Path (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $PSCommandPath -leaf)) -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ;
        }else {
            $logspec = start-Log -Path $PSCommandPath -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ;
        } ;
    } else {
        if($MyInvocation.MyCommand.Definition -match $rgxScriptsAllUsersScope){
            $logspec = start-Log -Path (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $PSCommandPath -leaf)) -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ;
        } else {
            $logspec = start-Log -Path $MyInvocation.MyCommand.Definition -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ;
        } ;
    } ;
    Detect profile installs (installed mod or script), and redir to stock location, with hunting path
    .EXAMPLE
    $pltSL=@{ NoTimeStamp=$true ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
    if($forceall){$pltSL.Tag = "$($TenOrg)-ForceAll" }
    else {$pltSL.Tag = "($TenOrg)-LASTPASS" } ;
    if($PSCommandPath){   $logspec = start-Log -Path $PSCommandPath @pltSL }
    else {    $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL ;  } ;
    Simpler splatted example with conditional Tag
    .EXAMPLE
    $dPref = 'd','c' ; 
    foreach($budrv in $dpref){
        if(test-path -path "$($budrv):\scripts" -ea 0 ){
            break ;
        } ;
    } ;
     [regex]$rgxScriptsAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\Scripts" ;
    if($PSCommandPath){
        if($PSCommandPath -match $rgxScriptsAllUsersScope){
            # AllUsers installed script, divert into [$budrv]:\scripts (don't write logs into allusers context folder)
            $logspec = start-Log -Path (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $PSCommandPath -leaf)) -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ; 
        }else {
            $logspec = start-Log -Path $PSCommandPath -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ; 
        } ; 
    } else {
        if($MyInvocation.MyCommand.Definition -match $rgxScriptsAllUsersScope){
            $logspec = start-Log -Path (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $PSCommandPath -leaf)) -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ; 
        } else { 
            $logspec = start-Log -Path $MyInvocation.MyCommand.Definition -NoTimeStamp -Tag "($TenOrg)-LASTPASS" -showdebug:$($showdebug) -whatif:$($whatif) ; 
        } ;    
    } ;    
    Example that accomodates detect/redirect from AllUsers scope'd installed scripts, and hunts a sereis of drive letters to find an alternate logging dir
    .EXAMPLE
    $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
    if($forceall){$pltSL.Tag = "-ForceAll" }
    else {$pltSL.Tag = "-LASTPASS" } ;
    $logspec = start-Log -Path c:\scripts\test-script.txt @pltSL ;
    Path is normally to the executing .ps1, but *does not have to be*. Anything with a valid path can be specified, including a .txt file. The above generates logging/transcript paths off of specifying a non-existant text file path.
    .LINK
    https://github.com/tostka/verb-logging
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to target script (defaults to `$PSCommandPath) [-Path .\path-to\script.ps1]")]
        # rem out validation, for module installed in AllUsers etc, we don't want to have to spec a real existing file. No bene to testing
        #[ValidateScript({Test-Path (split-path $_)})] 
        $Path,
        [Parameter(HelpMessage="Tag string to be used with -Path filename spec, to construct log file name [-tag 'ticket-123456]")]
        [string]$Tag,
        [Parameter(HelpMessage="Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]")]
        [switch] $NoTimeStamp,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
    if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
    $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
    if($Tag){
        $transcript += "-$($Tag)" ; 
    } ; 
    $transcript += "-Transcript-BATCH"
    if(!$NoTimeStamp){ $transcript += "-$(get-date -format 'yyyyMMdd-HHmmtt')" } ; 
    $transcript += "-trans-log.txt"  ;
    # add log file variant as target of Write-Log:
    $logfile = $transcript.replace("-Transcript", "-LOG").replace("-trans-log", "-log")
    if ($whatif) {
        $logfile = $logfile.replace("-BATCH", "-BATCH-WHATIF") ;
        $transcript = $transcript.replace("-BATCH", "-BATCH-WHATIF") ;
    }
    else {
        $logfile = $logfile.replace("-BATCH", "-BATCH-EXEC") ;
        $transcript = $transcript.replace("-BATCH", "-BATCH-EXEC") ;
    } ;
    $logging = $True ;

    $hshRet= [ordered]@{
        logging=$logging ;
        logfile=$logfile ;
        transcript=$transcript ;
    } ;
    if($showdebug -OR $verbose){
        write-verbose -verbose:$true "$(($hshRet|out-string).trim())" ;  ;
    } ;
    Write-Output $hshRet ;
}

#*------^ Start-Log.ps1 ^------