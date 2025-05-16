
#region START_LOG ; #*------v Start-Log v------
#if(-not(gi function:start-log -ea 0)){
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
        * 4:03 PM 5/15/2025 removed rem's
        * 9:07 AM 4/30/2025 make Tag cleanup conditional on avail of the target vtxt\funcs
        * 11:57 AM 1/17/2023 updated output object to be psv2 compat (OrderedDictionary object under v2)
        * 3:46 PM 11/16/2022 added catch blog around start-trans, that traps 'not compatible' errors, distict from generic catch
        * 2:15 PM 2/24/2022 added -TagFirst param (put the ticket/tag at the start of the filenames)
        * 4:23 PM 1/24/2022 added capture of start-trans - or it echos into pipeline
        * 10:46 AM 12/3/2021 added Tag cleanup: Remove-StringDiacritic,  Remove-StringLatinCharacters, Remove-IllegalFileNameChars (adds verb-io & verb-text deps); added requires for the usuals.
        * 9/27/2021 Example3, updated to latest diverting rev
        * 5:06 PM 9/21/2021 rewrote Example3 to handle CurrentUser profile installs (along with AllUsers etc).
        * 8:45 AM 6/16/2021 updated example for redir, to latest/fully-expanded concept code (defers to profile constants); added tricked out example for looping UPN/Ticket combo
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
        
        Note: To use -TagFirst: set both -TagFirst & -Ticket; the ticket spec will prefix all generated filenames
        
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
        .PARAMETER NoTimeStamp
        Flag that suppresses the trailing timestamp value from the generated filenames[-NoTimestamp]
        .PARAMETER TagFirst
        Flag that leads the returned filename with the Tag parameter value[-TagFirst]
        .PARAMETER ShowDebug
        Switch to display Debugging messages [-ShowDebug]
        .PARAMETER whatIf
        Whatif Flag [-whatIf]
        .EXAMPLE
        $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
        if($PSCommandPath){   $logspec = start-Log -Path $PSCommandPath @pltSL ; 
        } else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL ; } ; 
        if($logspec){
            $logging=$logspec.logging ;
            $logfile=$logspec.logfile ;
            $transcript=$logspec.transcript ;
            if(Test-TranscriptionSupported){
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ; 
                $startResults = start-transcript -Path $transcript ;
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
            $startResults = start-Transcript -path $transcript ; 
        } else {throw "Unable to configure logging!" } ;
        
        Configure default logging from parent script name, with no Timestamp
        .EXAMPLE
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
        foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
        if(!(get-variable rgxPSAllUsersScope -ea 0)){
            $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
        } ;
        if(!(get-variable rgxPSCurrUserScope -ea 0)){
            $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
        } ;
        $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
        $pltSL.Tag = $ModuleName ; 
        # variant Ticket/TagFirst Tagging:
        # $pltSL.Tag = $Ticket ;
        # $pltSL.TagFirst = $true ;
        if($script:PSCommandPath){
            if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
                $bDivertLog = $true ; 
                switch -regex ($script:PSCommandPath){
                    $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                    $rgxPSCurrUserScope{$smsg = "CurrentUser"}
                } ;
                $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
                write-verbose $smsg  ;
                if($bDivertLog){
                    if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                        # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                    } else {
                        # installed allusers|CU script, use the hosting script name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                    }
                } ;
            } else {
                $pltSL.Path = $script:PSCommandPath ;
            } ;
        } else {
            if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
            } elseif(test-path $MyInvocation.MyCommand.Definition) {
                $pltSL.Path = $MyInvocation.MyCommand.Definition ;
            } elseif($cmdletname){
                $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
            } else {
                $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                BREAK ;
            } ; 
        } ;
        write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
        $logspec = start-Log @pltSL ;
        $error.clear() ;
        TRY {
            if($logspec){
                $logging=$logspec.logging ;
                $logfile=$logspec.logfile ;
                $transcript=$logspec.transcript ;
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                $startResults = start-Transcript -path $transcript ;
            } else {throw "Unable to configure logging!" } ;
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } ;
        
        Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
        .EXAMPLE
        $iProcd=0 ; $ttl = ($UPNs | Measure-Object).count ; $tickNum = ($tickets | Measure-Object).count
        if ($ttl -ne $tickNum ) {
            write-host -foregroundcolor RED "$((get-date).ToString('HH:mm:ss')):ERROR!:You have specified $($ttl) UPNs but only $($tickNum) tickets.`nPlease specified a matching number of both objects." ;
            Break ;
        } ;
        foreach($UPN in $UPNs){
            $iProcd++ ;
            if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
            foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
            if(!(get-variable rgxPSAllUsersScope -ea 0)){
                $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
            } ;
            $pltSL=@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;TagFirst=$null; showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
            if($tickets[$iProcd-1]){$pltSL.Tag = "$($tickets[$iProcd-1])-$($UPN)"} ;
            if($script:PSCommandPath){
                if($script:PSCommandPath -match $rgxPSAllUsersScope){
                    write-verbose "AllUsers context script/module, divert logging into [$budrv]:\scripts" ;
                    if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                        # function in a module/script installed to allusers 
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                    } else { 
                        # installed allusers script
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                    }
                }else {
                    $pltSL.Path = $script:PSCommandPath ;
                } ;
            } else {
                if($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope){
                     $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                } else {
                    $pltSL.Path = $MyInvocation.MyCommand.Definition ;
                } ;
            } ;
            write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
            $logspec = start-Log @pltSL ;
            $error.clear() ;
            TRY {
                if($logspec){
                    $logging=$logspec.logging ;
                    $logfile=$logspec.logfile ;
                    $transcript=$logspec.transcript ;
                    $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                    $startResults = start-Transcript -path $transcript ;
                } else {throw "Unable to configure logging!" } ;
            } CATCH [System.Management.Automation.PSNotSupportedException]{
                if($host.name -eq 'Windows PowerShell ISE Host'){
                    $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
                } else { 
                    $smsg = "This host does *not* support native (start-)transcription" ; 
                } ; 
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
         }  # loop-E $UPN
         
         Looping per-pass Logging (uses $UPN & $Ticket array, in this example). 
        .EXAMPLE
        $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
        if($forceall){$pltSL.Tag = "-ForceAll" }
        else {$pltSL.Tag = "-LASTPASS" } ;
        write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
        $logspec = start-Log -Path c:\scripts\test-script.txt @pltSL ;
        
        Path is normally to the executing .ps1, but *does not have to be*. Anything with a valid path can be specified, including a .txt file. The above generates logging/transcript paths off of specifying a non-existant text file path.
        .LINK
        https://github.com/tostka/verb-logging
        #>
        #Requires -Modules verb-IO, verb-Text
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
            [Parameter(HelpMessage="Flag that leads the returned filename with the Tag parameter value[-TagFirst]")]
            [switch] $TagFirst,
            [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
            [switch] $showDebug,
            [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
            [switch] $whatIf=$true
        ) ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        $transcript = join-path -path (Split-Path -parent $Path) -ChildPath "logs" ;
        if (!(test-path -path $transcript)) { "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
        if($Tag){
            if((gci function:Remove-StringDiacritic -ea 0)){$Tag = Remove-StringDiacritic -String $Tag } else {write-host "(missing:verb-text\Remove-StringDiacritic, skipping)";}  # verb-text ; 
            if((gci function:Remove-StringLatinCharacters -ea 0)){$Tag = Remove-StringLatinCharacters -String $Tag } else {write-host "(missing:verb-textRemove-StringLatinCharacters, skipping)";} # verb-text
            if((gci function:Remove-InvalidFileNameChars -ea 0)){$Tag = Remove-InvalidFileNameChars -Name $Tag } else {write-host "(missing:verb-textRemove-InvalidFileNameChars, skipping)";}; # verb-io, (inbound Path is assumed to be filesystem safe)
            if($TagFirst){
                $smsg = "(-TagFirst:Building filenames with leading -Tag value)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                $transcript = join-path -path $transcript -childpath "$($Tag)-$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
                #$transcript = "$($Tag)-$($transcript)" ; 
            } else { 
                $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
                $transcript += "-$($Tag)" ; 
            } ;
        } else {
            $transcript = join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($Path))" ; 
        }; 
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

        if($host.version.major -ge 3){
            $hshRet=[ordered]@{Dummy = $null ; } ;
        } else {
            # psv2 Ordered obj (can't use with new-object -properites)
            $hshRet = New-Object Collections.Specialized.OrderedDictionary ; 
            # or use an UN-ORDERED psv2 hash: $Hash=@{ Dummy = $null ; } ;
        } ;
        If($hshRet.Contains("Dummy")){$hshRet.remove("Dummy")} ; 
        $hshRet.add('logging',$logging) ;
        $hshRet.add('logfile',$logfile);
        $hshRet.add('transcript',$transcript) ;
        if($showdebug -OR $verbose){
            # retaining historical $showDebug support, even tho' not generally used now.
            write-verbose -verbose:$true "$(($hshRet|out-string).trim())" ;  ;
        } ;
        Write-Output $hshRet ;
    }
#} ; 
#endregion START_LOG ; #*------^ END start-log ^------