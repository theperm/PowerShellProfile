# http://stackoverflow.com/questions/1011243/where-to-put-powershell-scripts
# http://stackoverflow.com/questions/801967/how-can-i-find-the-source-path-of-an-executing-script/6985381#6985381

$ProfilePath = $script:MyInvocation.MyCommand.Path
$ProfileRoot  = [System.IO.Path]::GetDirectoryName($profile) #Split-Path -Parent $ProfilePath

$scripts = "$(split-path $profile)\Scripts"
$modules = "$(split-path $profile)\Modules"
$docs    =  $(resolve-path "$Env:userprofile\documents")
$desktop =  $(resolve-path "$Env:userprofile\desktop")

if($ProfilePath)
{
  $env:path += ";$ProfileRoot;$scripts"
  $env:Path += ";${env:ProgramFiles}\7-Zip"
  $env:Path += ";${env:ProgramFiles(x86)}\SysInternals Suite\"
}

import-module PsGet
install-module go
install-module PsUrl
#install-module Posh-Git
#install-module Posh-GitDir
#install-module Find-String

<############### Start of PowerTab Initialization Code ########################
    Added to profile by PowerTab setup for loading of custom tab expansion.
    Import other modules after this, they may contain PowerTab integration.
#>

if (!$NoPowertab)
{
  Import-Module "PowerTab" -ArgumentList ($HOME + "\Documents\WindowsPowerShell\Modules\PowerTab\PowerTabConfig.xml")
}
################ End of PowerTab Initialization Code ##########################

if($ProfilePath)
{
  #$env:path += ";${env:ProgramFiles(x86)}\Git\bin"
}
# Posh-Hg and Posh-git prompt
. $ProfileRoot\Modules\posh-svn\profile.example.ps1
. $ProfileRoot\Modules\posh-hg\profile.example.ps1
. $ProfileRoot\Modules\posh-git\profile.example.ps1

#ipmo posh-gitdir

# customize prompt display settings
$global:GitPromptSettings.BeforeText = '[git:'
$global:HgPromptSettings.BeforeText = '[hg:'
$global:SvnPromptSettings.BeforeText = '[svn:'

# http://jamesone111.wordpress.com/2012/01/28/adding-persistent-history-to-powershell/
$MaximumHistoryCount = 4096
$Global:logfile = "$env:USERPROFILE\Documents\windowsPowershell\history.csv" 
$truncateLogLines = 5000
$History = @()
$History += '#TYPE Microsoft.PowerShell.Commands.HistoryInfo'
$History += '"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"'
if (Test-Path $logfile) {$history += (get-content $LogFile)[-$truncateLogLines..-1] | where {$_ -match '^"\d+"'} }
$history > $logfile
$History | select -Unique  |
           Convertfrom-csv -errorAction SilentlyContinue |
           Add-History -errorAction SilentlyContinue


Function HowLong {
   <# .Synopsis Returns the time taken to run a command 
      .Description By default returns the time taken to run the last command 
      .Parameter ID The history ID of an earlier item. 
   #>
   param  ( [Parameter(ValueFromPipeLine=$true)]
            $id = ($MyInvocation.HistoryId -1)
          )
  process {  foreach ($i in $id) { 
                 (get-history $i).endexecutiontime.subtract(
                                  (get-history ($i)).startexecutiontime).totalseconds
            }
          } 
}

Function prompt {
  $hid = $myinvocation.historyID
  if ($hid -gt 1) {
    get-history ($myinvocation.historyID -1 ) | 
                      convertto-csv | Select -last 1 >> $logfile
  }

  $realLASTEXITCODE = $LASTEXITCODE

  # Reset color, which can be messed up by Enable-GitColors
  $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

  Write-Host(
    $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 
      "#$([math]::abs($hid)) PS$($PSVersionTable.psversion.major) " 
      #+ $(Get-Location) 
      ) -nonewline
    
    Write-Host($pwd.ProviderPath +' ') -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE

    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '

    Write-Host
}

# Aliases and functions to make it useful

New-Alias -Name i -Value Invoke-History -Description "Invoke history alias" -Force

Rename-Item Alias:\h original_h -Force

function h($count = 50) { Get-History -c  $count}
function hu($count = 50) { Get-History -c  $count | select -Unique}
function hf($arg, $count = 10) { Get-History -c $MaximumHistoryCount | out-string -stream | select-string $arg | select -Unique -last $count }

. $ProfileRoot\Scripts\MiscFunctions.ps1

Remove-Item Alias:\ls

function lsa { gci -Force | fw -a}

function gpst ($count = 20) { gps  | sort cpu -Descending | select -First $count }

function gpsm ($count = 20){ gps | sort pm -Descending | select -f $count }

set-alias -Name z7 -Value 'C:\Program Files\7-Zip\7z.exe'


function gitk { sh -c gitk }
set-alias gitx -value "C:\Program Files (x86)\GitExtensions\GitExtensions.exe"
set-alias -Name got -Value git -Description "Git alias" -Force
set-alias -Name get -Value git -Description "Git alias" -Force
set-alias -Name git -Value "C:\Program Files\Git\cmd\git.exe" -Description "Git alias" -Force

function find-replace ($file, $find, $replace) { ls $file -rec | %{ $f=$_; (gc $f.PSPath) | %{ $_ -replace $find, $replace } | sc $f.PSPath } }

function ipmoliquid { Import-Module LiquidHelpers -Force }

#ipmoliquid