﻿# verb-logging.Tests.ps1

<#
.SYNOPSIS
verb-logging.ps1 - verb-logging Pester Tests
.NOTES
Version     : 1.0.1
Author      : Todd Kadrie
Website     :	http://www.toddomation.com
Twitter     :	@tostka / http://twitter.com/tostka
CreatedDate : 2020-
FileName    : verb-logging.Tests.ps1
License     : MIT License
Copyright   : (c) 2020 Todd Kadrie
Github      : https://github.com/tostka
Tags        : Powershell,Pester,Testing,Development
REVISIONS
* 7:49 AM 3/4/2020 version debugged to work with Psv5.1/ISE/VSC
.DESCRIPTION
verb-logging.ps1 - verb-logging Pester Tests
Note, two different PSSA settings files are included, edit the $scriptStylePath to suit (and/or edit the files to suit)
.EXAMPLE
cd c:\sc\verb-logging\ ;
.\Tests\verb-logging.Tests.ps1
Run in default config
.EXAMPLE
cd c:\sc\verb-logging\ ;
.\Tests\verb-logging.Tests.ps1 -verbose
Run with Verbose outputs
.LINK
https://github.com/tostka
#>

[CmdletBinding()]
PARAM() ;
$Verbose = ($VerbosePreference -eq 'Continue') ;

# patch in ISE/VSC etc auto-vari support
if ($PSScriptRoot -eq "") {
    if ($psISE){
        $ScriptName = $psISE.CurrentFile.FullPath ; 
    } elseif ($context = $psEditor.GetEditorContext()) {
        $ScriptName = $context.CurrentFile.Path ;  
    } elseif($host.version.major -lt 3){
        $ScriptName = $MyInvocation.MyCommand.Path ; 
        $PSScriptRoot = Split-Path $ScriptName -Parent ;
        $PSCommandPath = $ScriptName ;
    } else {
        if($MyInvocation.MyCommand.Path) {
            $ScriptName = $MyInvocation.MyCommand.Path ; 
            $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
        } else {
            throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" ;
        } ;
    }; 
    $ScriptDir = Split-Path -Parent $ScriptName ; 
    $ScriptBaseName = split-path -leaf $ScriptName ;
    $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
} else {
    $ScriptDir = $PSScriptRoot ;
    if($PSCommandPath){
        $ScriptName = $PSCommandPath ; 
    } else {
        $ScriptName = $myInvocation.ScriptName
        $PSCommandPath = $ScriptName ;
    } ;
    $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ;
    $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
} ; 


$ModuleName = Split-Path (Resolve-Path "$ScriptDir\..\" ) -Leaf ; 
$ModuleManifest = (Resolve-Path "$ScriptDir\..\$ModuleName\$ModuleName.psd1").path ; 
$ProjectRoot = (Resolve-path "$ScriptDir\..\").path ; 
if(!(test-path $ProjectRoot\README.md)){
    throw "Unable to resolve ProjectRoot!" ;
}
$moduleComponents = Get-ChildItem $ProjectRoot  -Include *.psd1, *.psm1, *.ps1 -Exclude *.tests.ps1,PPoShScriptingStyle.psd1 -Recurse
$projectScripts = $moduleComponents | ?{$_.extension -eq '.ps1'} | sort name ;
$projectModules = $moduleComponents | ?{$_.extension -eq '.psm1'} | sort name ;
$projectDatafiles = $moduleComponents | ?{$_.extension -eq '.psd1'} | sort name ;
# enable to suit pref
#$scriptStylePath = (Resolve-Path "$ProjectRoot\Tests\PPoShScriptingStyle.psd1").path ;
$scriptStylePath = (Resolve-Path "$ProjectRoot\Tests\ToddomationScriptingStyle-medium.psd1").path ;

$smsg=@"

    ==Current Config:
    `$ModuleName:$ModuleName
    `$ProjectRoot :$ProjectRoot
    `$ModuleManifest:$ModuleManifest
    `$scriptStylePath:$scriptStylePath

    `$moduleComponents:
    $(($moduleComponents.fullname|ft -a | out-string).trim())" ;

    `$projectScripts:
    $(($projectScripts.fullname|ft -a | out-string).trim())" ;

    `$projectModules:
    $(($projectModules.fullname|ft -a | out-string).trim())" ;

    `$projectDatafiles:
    $(($projectDatafiles.fullname|ft -a | out-string).trim())" ;

"@ ;
write-verbose -verbose:$verbose $smsg ;

Get-Module $ModuleName | Remove-Module
Import-Module $ModuleManifest -Force

Describe 'Module Information' -Tags 'Command'{
    Context 'Manifest Testing' {
        It 'Valid Module Manifest' {
            {
                $Script:Manifest = Test-ModuleManifest -Path $ModuleManifest -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should Not Throw
        }
        It 'Valid Manifest Name' {
            $Script:Manifest.Name | Should -Be $ModuleName
        }
        It 'Generic Version Check' {
            $Script:Manifest.Version -as [Version] | Should -Not -BeNullOrEmpty
        }
        It 'Valid Manifest Description' {
            $Script:Manifest.Description | Should -Not -BeNullOrEmpty
        }
        It 'Valid Manifest Root Module' {
            $Script:Manifest.RootModule | Should -Be "$ModuleName.psm1"
        }
        It 'Valid Manifest GUID' {
            $Script:Manifest.Guid | Should -Be "b9637e55-12be-4916-8000-a949f9426fa3"
        }
    }

    Context 'Exported Functions' {
        It 'Proper Number of Functions Exported' {
            $Exported = Get-Command -Module $ModuleName ;
            $ExportedCount = $Exported | Measure-Object | Select-Object -ExpandProperty Count

            $Files = Get-ChildItem -Path "$ProjectRoot\Public" -Filter *.ps1 -Recurse
            $FileCount = $Files | Measure-Object | Select-Object -ExpandProperty Count

            $smsg=@"

    ==Exported Details:
    `$ExportedCount:$ExportedCount
    $($Exported|out-string)
    `$FileCount:$FileCount
    $($Files|out-string)


"@ ;
            write-verbose -verbose:$verbose $smsg ;

            $ExportedCount | Should be $FileCount
        }
    }


}

Describe 'General - Testing all scripts and modules against the Script Analyzer Rules' {
    Context "Checking files to test exist and Invoke-ScriptAnalyzer cmdLet is available" {
        It "Checking files exist to test." {
            $moduleComponents.count | Should Not Be 0
        }
        It "Checking Invoke-ScriptAnalyzer exists." {
            { Get-Command Invoke-ScriptAnalyzer -ErrorAction Stop } | Should Not Throw
        }
    }
} 

#region PSSA Testing

<# Calling PS Script analyzer with Pester : PowerShell - https://www.reddit.com/r/PowerShell/comments/6tmprp/calling_ps_script_analyzer_with_pester/
Shepherd_Ra, 2018
above extended with updated rule skip logic - shows *all* rules, marks skips
#>
Describe -Tags 'PSSA' -Name 'Testing against PSScriptAnalyzer rules' {
    Context 'PSSA Standard Rules' {
        #$ScriptAnalyzerSettings = Get-Content -Path $scriptStylePath | Out-String | Invoke-Expression
        # avoiding use invoke-expr (which is a pssa violation), leveraging Import-PowerShellDataFile instead
        $ScriptAnalyzerSettings = Import-PowerShellDataFile -path $scriptStylePath 
        #$AnalyzerIssues = Invoke-ScriptAnalyzer -Path "$PSScriptRoot\..\MyScript.ps1" -Settings "$PSScriptRoot\..\ScriptAnalyzerSettings.psd1"
        $AnalyzerIssues = Invoke-ScriptAnalyzer -Path $ProjectRoot -Recurse -Settings $scriptStylePath
        # $moduleComponents
        #$AnalyzerIssues = Invoke-ScriptAnalyzer -Path $moduleComponents -Settings $scriptStylePath
        $ScriptAnalyzerRuleNames = Get-ScriptAnalyzerRule | Select-Object -ExpandProperty RuleName
        forEach ($Rule in $ScriptAnalyzerRuleNames) {
            $Skip = $false ; 
            if($ScriptAnalyzerSettings.IncludeRules -contains $Rule){$skip=$false } ; 
            if($ScriptAnalyzerSettings.ExcludeRules -contains $Rule){$Skip = $true } ;
            <#$Skip = $ScriptAnalyzerSettings.IncludeRules -notcontains $Rule
            $Skip = $ScriptAnalyzerSettings.ExcludeRules -contains $Rule
            #>
            It "Should pass $Rule" -Skip:$Skip {
                $Failures = $AnalyzerIssues | Where-Object -Property RuleName -EQ -Value $rule
                ($Failures | Measure-Object).Count | Should Be 0
            }
        }
    }
}


<# report profiling
$report = import-clixml -path $path ; 
write-verbose -verbose:$verbose "`n`$Report | group severity" 
"$(($report | group severity | sort count | ft -auto count,name|out-string).trim())`n" ;

write-verbose -verbose:$verbose "`n`$Report | group rulename"
"$(($report | group rulename | sort count | ft -auto count,name|out-string).trim())`n" ;

write-verbose -verbose:$verbose "`n`$Report | group scriptname"
"$(($report | group scriptpath | sort -desc count | ft -auto count,name|out-string).trim())`n" ;

write-verbose -verbose:$verbose "`n Detailed per script report:" ;
foreach ($scriptrpt in $scriptreported ) {
    $sBnrS = "`n#*------v $($scriptrpt): v------" ;
    "$($sBnrS)" ;
    "$(($report |?{$_.scriptname -eq $scriptrpt} | sort rulename,message | ft -auto Severity,Line,RuleName,Message|out-string).trim())`n" ;
    "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
} ;
#>

$ofile = join-path -path (split-path $scriptStylePath) -child "ScriptAnalyzer-Results-$(get-date -format 'yyyyMMdd-HHmmtt').xml" ;
$Report | export-clixml -path $ofile
write-verbose -verbose:$verbose  "ScriptAnalyzer Report written to:`n$($ofile)" ;

#endregion
     


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY7KFh2rhjh7DtMmroKvcgpuK
# xY+gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRj4Jhw
# KZhlJlsgPt5n0udU10y3mTANBgkqhkiG9w0BAQEFAASBgDhLvRK+WEXSvG7SyPYk
# Yiiy5dRxn0Y9TAGEHX/LQ5RLK/VcjCTgdETOOigUPqVOVojeeGn+R4DkyweeOFki
# Y6/74Ntv5l+BUk3hD2CuiMYLn8HN1GaLmJH9/uYbNv4pruhLT1SYrOz0JN/8L4sH
# wvNB1DEjlLEczZUCroeoQfh8
# SIG # End signature block
