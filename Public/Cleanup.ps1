#-------v Function Cleanup v-------
# 8:13 AM 10/2/2018 Cleanup():make it defer to existing script-copy
if(test-path function:Cleanup){
    "(deferring to `$script:cleanup())" ;
} else {
    "(using default verb-logging:cleanup())" ;
    function Cleanup {
        <#
        .SYNOPSIS
        Cleanup.ps1 - Cleanup, close logging & email reports template funcotin
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-
        FileName    : 
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka/verb-XXX
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite:	URL
        AddedTwitter:	URL
        REVISIONS
        * 2:51 PM 9/22/2020 updated to cover ISE v5 transcription support
        .DESCRIPTION
        Cleanup.ps1 - Cleanup, close logging & email reports template funcotin
        .EXAMPLE
        .\Cleanup.ps1
        .EXAMPLE
        if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
            # STATIC transcript paths
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + $timeStampNow + "-ISEtrans.log")) ;
            # 2:02 PM 9/21/2018 missing $timestampnow, hardcode
            #$Logname=(join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-" + (get-date -format 'yyyyMMdd-HHmmtt') + "-ISEtrans.log")) ;
            # RENAME and use the pre-generated transcript
            $Logname=$transcript.replace('-trans-log.txt','-ISEtrans-log.txt') ; 
            write-host "`$Logname: $Logname";
            Start-iseTranscript -logname $Logname ;
            #Archive-Log $Logname ; 
            $transcript = $Logname ; 
            if($host.version.Major -ge 5){ stop-transcript } ;
        } else {
            if($showdebug){ write-debug "$((get-date).ToString('HH:mm:ss')):Stop Transcript" };
            Stop-TranscriptLog ;
            #Archive-Log $transcript ;
        } # if-E
        .LINK
        https://github.com/tostka/verb-XXX
        #>
        # clear all objects and exit
        # Clear-item doesn't seem to work as a variable release
        # 3:18 PM 2/13/2019 Cleanup: add in the smtp mailer and Change/Error report mailing code from maintain-exombxretentionpolicies.ps1
        # 8:15 AM 10/2/2018 Cleanup:make it defer to $script:cleanup() (needs to be preloaded before verb-transcript call in script), added missing semis, replaced all $bDebug -> $showDebug
        # 2:02 PM 9/21/2018 missing $timestampnow, hardcode
        # 8:45 AM 10/13/2015 reset $DebugPreference to default SilentlyContinue, if on
        # # 8:46 AM 3/11/2015 at some time from then to 1:06 PM 3/26/2015 added ISE Transcript
        # 8:39 AM 12/10/2014 shifted to stop-transcriptLog function
        # 7:43 AM 1/24/2014 always stop the running transcript before exiting
        if ($showdebug) {"CLEANUP"} ;
        #stop-transcript ;
        if($host.Name -eq "Windows PowerShell ISE Host" -and $host.version.major -lt 5){
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -uformat "%Y%m%d-%H%M" ) + "-ISEtrans.log")) ;
            #$Logname= (join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + $timeStampNow + "-ISEtrans.log")) ;
            $Logname=(join-path -path (join-path -path $scriptDir -childpath "logs") -childpath ($scriptNameNoExt + "-BATCH" + (get-date -format 'yyyyMMdd-HHmmtt') + "-ISEtrans.log")) ;
            $smsg= "`$Logname: $Logname";
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

            Start-iseTranscript -logname $Logname ;
            #Archive-Log $Logname ;
            $transcript = $Logname ;
        } else {
            if($showdebug){ write-debug "$(get-timestamp):Stop Transcript" };
            Stop-TranscriptLog ;
            #if($showdebug){ write-debug "$(get-timestamp):Archive Transcript" };
            #Archive-Log $transcript ;
        } # if-E
        if($whatif){
            $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
            $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
            $Logname=$Logname.replace("-BATCH","-BATCH-WHATIF") ;

        } else {
            $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
            $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
            $Logname=$Logname.replace("-BATCH","-BATCH-EXEC") ;
        } ;

        # 12:09 PM 4/26/2017 need to email transcript before archiving it
        if($showdebug){
            $smsg= "Mailing Report"
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        };

        #$smtpSubj= "Proc Rpt:$($ScriptBaseName):$(get-date -format 'yyyyMMdd-HHmmtt')"   ;
        #Load as an attachment into the body text:
        #$body = (Get-Content "path-to-file\file.html" ) | converto-html ;
        #$SmtpBody += ("Pass Completed "+ [System.DateTime]::Now + "`nResults Attached: " +$transcript) ;
        # 4:07 PM 10/11/2018 giant transcript, no send
        #$SmtpBody += "Pass Completed $([System.DateTime]::Now)`nResults Attached:($transcript)" ;
        $SmtpBody += "Pass Completed $([System.DateTime]::Now)`nTranscript:($transcript)" ;
        # 12:55 PM 2/13/2019 append the $PassStatus in for reference
        if($PassStatus ){
            $SmtpBody += "`n`$PassStatus triggers:: $($PassStatus)`n" ;
        } ;
        $SmtpBody += "`n$('-'*50)" ;
        #$SmtpBody += (gc $outtransfile | ConvertTo-Html) ;
        # name $attachment for the actual $SmtpAttachment expected by Send-EmailNotif
        #$SmtpAttachment=$transcript ;
        # 1:33 PM 4/28/2017 test for ERROR|CHANGE - actually non-blank, only gets appended to with one or the other
        if($PassStatus ){
            Send-EmailNotif ;
        } else {
            $smsg= "No Email Report: `$Passstatus is $null" ;
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        } ;

        #11:10 AM 4/2/2015 add an exit comment
        $smsg= "END $BARSD4 $scriptBaseName $BARSD4"  ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        $smsg= "$BARSD40" ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
        # finally restore the DebugPref if set
        if ($ShowDebug -OR ($DebugPreference = "Continue")) {
            $smsg= "Resetting `$DebugPreference from 'Continue' back to default 'SilentlyContinue'" ;
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
            #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

            $showdebug=$false ;
            # 8:41 AM 10/13/2015 also need to enable write-debug output (and turn this off at end of script, it's a global, normally SilentlyContinue)
            $DebugPreference = "SilentlyContinue" ;
        } # if-E

        $smsg= "#*======^ END PASS:$($ScriptBaseName) ^======" ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg))" ;
        #if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn

        EXIT ;
    } ;
} ; #*------^ END Function Cleanup ^------
