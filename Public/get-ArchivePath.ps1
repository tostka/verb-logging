#*----------------v Function get-ArchivePath v----------------
function get-ArchivePath {
    <#.SYNOPSIS
    ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .NOTES
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() function
    REVISIONS   :
    # 8:33 AM 2/18/2020 get-ArchivePath: shifted paths into global varis in profile
    # 8:52 AM 4/24/2015 shifted internal func vari name from $archPath to $ArchiveLocation, to avoid overlap clash/confusion ; shifted archpath detection code out of send-mailmessage and archive-log, into get-ArchivePath()
    # 2:49 PM 4/23/2015 recast $ArchPath as $archPath script scope
    # 9:39 AM 4/13/2015 tightened up formatting, crushed lines ; update-RetiringConfRmWindows-prod-tests-20150413-0917AM.ps1 version
    # 7:30 AM 1/28/2015 in use in LineURI script
    # 10:37 AM 1/21/2015 moved out of the if\else
    # 1:44 PM 1/16/2015 repurposed from Stop-TranscriptLog, focused this on just moving to archive location
    # 1:18 PM 1/14/2015 added Lync fs rpt share support ; adde Lync FS support ; added lab support ; added lab support for archpath
    # 10:11 AM 12/10/2014 tshot get-ArchivePath archmove, for existing file clashes ; shifted more into the try block
    #12:49 PM 12/9/2014 init
    .INPUTS
    leverages the global $transcript variable (must be set in the root script; not functions)
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    $archPath = get-ArchivePath ;
    Retrieve the functional Archivepath into a variable.
    #>

    # 11:57 AM 4/24/2015update, no params, this returns a value, but needs nothing
    #   [parameter(Mandatory=$true)]$FilePath

    Param() ;

        # moved to globals in profile
        $gVaris = "ArchPathProd","ArchPathLync","ArchPathLab","ArchPathLabLync","rgxRestrictedNetwork" ;
        foreach($gVari in $gVaris){
            if(-not(get-variable $gVari -scope Global)){
                $smsg = "Undefined `$global:$($gvari) variable!. ABORTING!" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Exit ;
            } ;
        } ;

        if ($showdebug) { write-verbose "$((get-date).ToString('HH:mm:ss')) Start get-ArchivePath" -Verbose:$verbose}

        # if blocked for SMB use custom arch server for reporting
        $IPs=get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress ;
        $IPs | ForEach-Object {
            if ($_.ipaddress -match $rgxRestrictedNetwork){
                # server with blocks to SMB to archserver
                if ($showdebug) {write-host -foregroundcolor yellow  "$((get-date).ToString('HH:mm:ss')):Restricted Subnet Detected. Using Lync ArchPath";};

                if($env:USERDOMAIN -eq $domLab){
                    if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLabLync"};
                    # lync Edge or FE server
                    if(test-path $ArchPathLabLync) {
                        $ArchiveLocation = $ArchPathLabLync;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lab Lync `$ArchiveLocation. Exiting.";
                        exit
                    };  # if-E
                } else {
                    # non-lab prod Lync
                    if(test-path $ArchPathLync) {
                        $ArchiveLocation =$ArchPathLync;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lync `$ArchiveLocation. Exiting.";
                        exit
                    }; # if-E non-lab
                }; # lync lab or prod
            } else {
                # non-Lync/restricted subnet
                if($env:USERDOMAIN -eq $domLab){
                    if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLab"};
                    # lync Edge or FE server
                    if(test-path $ArchPathLab) {
                        $ArchiveLocation = $ArchPathLab;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Lab `$ArchiveLocation. Exiting.";
                        #Cleanup; # nope, cleanup normally CALLS STOP-TRANSLOG
                        exit
                    };  # if-E
                    } else {
                    # non-lab prod
                    if(test-path $ArchPathProd) {
                        $ArchiveLocation =$ArchPathProd;
                    } else {
                        write-error "$((get-date).ToString('HH:mm:ss')):FAILED TO LOCATE Prod `$ArchiveLocation. Exiting.";
                        exit
                    };  # if-E
                }; # if-E non-lab
            }; # if-E restricted subnet test
        };  # loop-E $IPs
        if ($showdebug) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`$ArchiveLocation:$ArchiveLocation"};

        Try {
            # validate the archpath
            if (!(Test-Path $ArchiveLocation)) {
                # gui prompt
                $ArchiveLocation = [Microsoft.VisualBasic.Interaction]::InputBox("Input ArchPath[UNCPath]", "Archpath", "") ;
            }
            if($showdebug){Write-Verbose "$((get-date).ToString('HH:mm:ss'))End get-ArchivePath" -Verbose:$verbose} ;
            # 2:21 PM 4/24/2015 try flattening in here.
            if($ArchiveLocation -is [system.array]){
                write-verbose "Flattening in get-ArchivePath" -verbose:$verbose ;
                $ArchiveLocation = $ArchiveLocation[0]
            } # if-E
            Return $ArchiveLocation

        } # TRY-E
        Catch {
                Write-Error "$((get-date).ToString('HH:mm:ss')): Failed to move `n$FilePath to `n$ArchiveLocation"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error in $($_.InvocationInfo.ScriptName)."
                Write-Error "$((get-date).ToString('HH:mm:ss')): -- Error information"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line Number: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Offset: $($_.InvocationInfo.OffsetInLine)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Command: $($_.InvocationInfo.MyCommand)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Line: $($_.InvocationInfo.Line)"
                Write-Error "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
        } ;

}#*----------------^ END Function get-ArchivePath ^----------------