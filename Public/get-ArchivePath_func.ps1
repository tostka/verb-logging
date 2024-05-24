#*------v get-ArchivePath.ps1 v------
function get-ArchivePath {
    <#.SYNOPSIS
    ARCHIVES a designated file (if no archive needed, just use the stock Stop-Transcript cmdlet). Tests and fails back through restricted subnets to find a working archive locally
    .NOTES
    #Author: Todd Kadrie
    #Website:	http://toddomation.com
    #Twitter:	http://twitter.com/tostka
    Requires test-transcribing() function
    REVISIONS   :
    # 5:14 PM 5/24/2024 sketched in initial CMW support
    # 8:38 AM 11/23/2020 extend verbose supp
    # 3:48 PM 9/22/2020 cleanedup CBH, examples
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
    .PARAMETER TenOrg
    Tenant Tag (3-letter abbrebiation)[-TenOrg 'XYZ']
    .INPUTS
    leverages the global $transcript variable (must be set in the root script; not functions)
    .OUTPUTS
    Outputs $TRUE/FALSE reflecting successful archive attempt status
    .EXAMPLE
    $archPath = get-ArchivePath ;
    Retrieve the functional Archivepath into a variable.
    .EXAMPLE
    $archPath = get-ArchivePath ;
    if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
        $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
        write-host "`$Logname: $Logname";
        Start-iseTranscript -logname $Logname ;
        Archive-Log $Logname ;
        $transcript = $Logname ; 
        if($host.version.Major -ge 5){ stop-transcript } ;
    } else {
        Stop-TranscriptLog ;
        Archive-Log $transcript ;
    } # if-E
    Full stack use of the functions
    .LINK
    https://www.toddomation.com
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$FALSE,HelpMessage="TenantTag value, indicating Tenants to connect to[-TenOrg 'TOL']")]
            [ValidateNotNullOrEmpty()]
            #[ValidatePattern("^\w{3}$")]
            [string]$TenOrg = $global:o365_TenOrgDefault
    ) ;

    $verbose = ($VerbosePreference -eq "Continue") ; 
    Write-verbose -verbose:$verbose "$((get-date).ToString('HH:mm:ss')):MSG" ;
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

    if($TORMETA.ArchPathProd){$ArchPathTTC = $tormeta.ArchPathProd}
    elseif($ArchPathProd){$ArchPathTTC = $ArchPathProd}
    else {$ArchPathTTC = 'XFxseW5tc3YxMC5nbG9iYWwuYWQudG9yby5jb21cTHluY19GU1xzY3JpcHRzXHJwdHNc' | convertFrom-Base64String } ; 
    if($CMWMETA.ArchPathProd){$ArchPathCMW = $CMWMETA.ArchPathProd}
    #elseif($ArchPathProd){$ArchPathCMW = $ArchPathProd}
    else {$ArchPathCMW = 'XFxDVVJMWUhPV0FSRC5jbXcuaW50ZXJuYWxcYyRcc2NyaXB0c1xycHRzXA==' | convertFrom-Base64String } ; 

    #if(-not $TORMETA.OP_ExOrgDN){$OrgNameTTC = ('VG9ybw==' | convertFrom-Base64String) } else { $OrgNameTTC = $TORMETA.OP_ExOrgDN.split(',')[0].replace('CN=','') } ; 
    #if(-not $CMWMETA.OP_ExOrgDN){$OrgNameCMW = ('RGl0Y2hXaXRjaA==' | convertFrom-Base64String) } else { $OrgNameCMW = $CMWMETA.OP_ExOrgDN.split(',')[0].replace('CN=','') } ; 
    if(-not $CMWMeta.o365_Prefix){$OrgNameCMW = ('Q01X==' | convertFrom-Base64String) } else { $OrgNameCMW = $TORMETA.OP_ExOrgDN.split(',')[0].replace('CN=','') } ; 
    if(-not $TORMETA.o365_Prefix){$OrgNameTTC = ('VG9ybw==' | convertFrom-Base64String) } else { $OrgNameTTC = $TORMETA.OP_ExOrgDN.split(',')[0].replace('CN=','') } ; 

    if ($showdebug -OR $verbose) { write-verbose "$((get-date).ToString('HH:mm:ss')) Start get-ArchivePath" -Verbose:$verbose}

    #switch($ExchangeEnvironment.OrganizationName){
    switch($TenOrg){
        #$OrgNameCMW{
        $OrgNameCMW {
            $ArchPath = $ArchPathCMW ; 
        }
        #$OrgNameTTC {
        $TORMETA.o365_Prefix {
            $ArchPath = $ArchPathTTC ; 
        } 
        default {
            $smsg = "UNABLE TO RESOLVE GET-ORGANIZATIONCONFIG.NAME TO A PRECONFIGURED `$ArchPath!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            throw $smsg ; 
            break ; 
        } ; 
    } ; 

    # if blocked for SMB use custom arch server for reporting
    $IPs=get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property IPAddress ;
    $IPs | ForEach-Object {
        <# add CMW dmz subnet egress IP 205.142.232.90
        IPv4 Address. . . . . . . . . . . : 205.142.232.90(Preferred)
        Subnet Mask . . . . . . . . . . . : 255.255.255.240
        ^(170\.92\.9|10\.92\.9|205\.142\.232)\.\d{1,3}$
        #>
        if ($_.ipaddress -match $rgxRestrictedNetwork){
            # server with blocks to SMB to archserver
            if ($showdebug -OR $verbose) {write-host -foregroundcolor yellow  "$((get-date).ToString('HH:mm:ss')):Restricted Subnet Detected. Using Lync ArchPath";};

            if($env:USERDOMAIN -eq $domLab){
                if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLabLync"};
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
                if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):LAB Server Detected. Using Lync ArchPathLab"};
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
    if ($showdebug -OR $verbose) {write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):`$ArchiveLocation:$ArchiveLocation"};

    Try {
        # validate the archpath
        if (!(Test-Path $ArchiveLocation)) {
            # gui prompt
            $ArchiveLocation = [Microsoft.VisualBasic.Interaction]::InputBox("Input ArchPath[UNCPath]", "Archpath", "") ;
        }
        if($showdebug -OR $verbose){Write-Verbose "$((get-date).ToString('HH:mm:ss'))End get-ArchivePath" -Verbose:$verbose} ;
        # 2:21 PM 4/24/2015 try flattening in here.
        if($ArchiveLocation -is [system.array]){
            write-verbose "Flattening in get-ArchivePath" -verbose:$verbose ;
            $ArchiveLocation = $ArchiveLocation[0]
        } # if-E
        Return $ArchiveLocation

    } # TRY-E
    Catch {
        $ErrTrapd=$Error[0] ;
        Start-Sleep -Seconds $RetrySleep ;
        $Exit ++ ;
        $smsg= "Failed to exec cmd because: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error} ; #Error|Warn
        Exit ;#Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ;

}

#*------^ get-ArchivePath.ps1 ^------