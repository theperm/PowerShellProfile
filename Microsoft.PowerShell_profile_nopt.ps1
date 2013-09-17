# http://stackoverflow.com/questions/1011243/where-to-put-powershell-scripts
# http://stackoverflow.com/questions/801967/how-can-i-find-the-source-path-of-an-executing-script/6985381#6985381

$ProfilePath = $script:MyInvocation.MyCommand.Path
$ProfileRoot  = Split-Path -Parent $ProfilePath

$scripts = "$(split-path $profile)\Scripts"
$modules = "$(split-path $profile)\Modules"
$docs    =  $(resolve-path "$Env:userprofile\documents")
$desktop =  $(resolve-path "$Env:userprofile\desktop")

$env:path += ";$ProfileRoot;$scripts"
$env:Path += ";C:\Program Files\7-Zip"


import-module PsGet
install-module PsUrl
install-module Find-String

<############### Start of PowerTab Initialization Code ########################
    Added to profile by PowerTab setup for loading of custom tab expansion.
    Import other modules after this, they may contain PowerTab integration.
#>

#Import-Module "PowerTab" -ArgumentList "C:\Users\E20157\Documents\CodeOwlsLLC.StudioShell\PowerTabConfig.xml"
################ End of PowerTab Initialization Code ##########################


# http://jamesone111.wordpress.com/2012/01/28/adding-persistent-history-to-powershell/
$MaximumHistoryCount = 2048
$Global:logfile = "$env:USERPROFILE\Documents\windowsPowershell\log.csv" 
$truncateLogLines = 100
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
  if ($hid -gt 1) {get-history ($myinvocation.historyID -1 ) | 
                      convertto-csv | Select -last 1 >> $logfile
  }
  $(if (test-path variable:/PSDebugContext) { '[DBG]: ' } else { '' }) + 
    "#$([math]::abs($hid)) PS$($PSVersionTable.psversion.major) " + $(Get-Location) + 
    $(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

# Aliases and functions to make it useful

New-Alias -Name i -Value Invoke-History -Description "Invoke history alias"

Rename-Item Alias:\h original_h -Force

function h { Get-History -c  $MaximumHistoryCount }

function hf($arg) { Get-History -c $MaximumHistoryCount | out-string -stream | select-string $arg }


# Posh-Hg and Posh-git prompt
. $ProfileRoot\Modules\posh-svn\profile.example.ps1
. $ProfileRoot\Modules\posh-hg\profile.example.ps1
. $ProfileRoot\Modules\posh-git\profile.example.ps1
