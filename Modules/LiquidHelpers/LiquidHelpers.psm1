Import-Module C:\workspace\source\PowerShell\Elysian.psd1 -Force -Global 

set-alias -Name ele -value Stop-LocalLiquidEnvironment

function slef { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALFULL }
function sled { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALDATASERVER }
function sleb { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALBME }
function sleg { Start-LocalLiquidEnvironment -ShadowCopy -Environment 90_LOCALGLOBEX }
function sle  { Start-LocalLiquidEnvironment -ShadowCopy }

function slid { Start-LocalLiquidInstance -ShadowCopyPerServer -Instance CMED_DataServer }
function slia { Start-LocalLiquidInstance -ShadowCopyPerServer -Instance Aggregator1 }
function slids { slid; Start-Sleep -s 3; slia; }

#set-alias -Name sle -value sle_

go cmed

function sdnt { Set-DefaultsFromBranch -NetworkXml .\Liquid\Testing\Elysian.Liquid.Testing\UnitTestNetwork.xml .}
function sdn1 { Set-DefaultNetworkXml -NetworkXml c:\Workspace\90AdminNetwork.xml }

#sdnt
#Get-DefaultNetworkXml

function Get-MSBuildCmd
{
        process
        {

             $path =  Get-ChildItem "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\" | 
                                   Sort-Object {[double]$_.PSChildName} -Descending | 
                                   Select-Object -First 1 | 
                                   Get-ItemProperty -Name MSBuildToolsPath |
                                   Select -ExpandProperty MSBuildToolsPath
        
            $path = (Join-Path -Path $path -ChildPath 'msbuild.exe')

        return Get-Item $path
    }
} 

function Build-Solution([switch]$Release, [Parameter(Mandatory = $false)][string] $MsBuildOptions, [Parameter(Mandatory = $false)][string] $Target = "Build")
{
       $allElysianProjectsSln = Get-BranchPath "AllElysianProjects.sln"
       
       if($Release)
       {
              $configuration = "Release"
       }
       else
       {
              $configuration = "Debug"
       }

       &(Get-MSBuildCmd) $allElysianProjectsSln /t:$Target "/p:Configuration=$configuration;Platform=Any CPU" /maxcpucount:8 $msbuildOptions
} 


Export-ModuleMember -Function * -Variable * -Alias * 