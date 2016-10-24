write-host -ForegroundColor green "Importing Elysian Powershell Commands"


$xmlDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$parent = (Split-Path -Parent -Path $xmlDir)
$location =  join-path $parent "cmedsource"

Import-Module (join-path $parent "powershell\Elysian.psd1") -Force -ArgumentList $false

Set-Location $location

function open-jira() {
  get-branch |? { $_ -match "(CDA-\d+)" } |% { $cda = $matches[1]; [System.Diagnostics.Process]::Start("http://elysianjira:8080/browse/$cda") }
}

function rebuild-all() {
    .NuGet\NuGet.exe restore AllElysianProjects.sln
    msbuild --% /m AllElysianProjects.sln
}

function StartRav()
{
    $networkXml = (get-expectednetworkxml)
    $exe = Get-ShadowCopy "$location\Liquid\Testing\Elysian.Liquid.Testing.Simulation.RAV\bin\Debug\Elysian.Liquid.Testing.Simulation.Rav.exe"
    echo $exe
	& "$exe" "/N:$networkXml" "/E:QAF"
	# & ".\Elysian.Liquid.Testing.Simulation.Rav.exe" "/N:$networkXml" "/E:QAF"
}


Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module from current directory
# Import-Module d:\workspace\posh-git
# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git

# Set up a simple prompt, adding the git prompt parts inside git repos
#function global:prompt {
#    $realLASTEXITCODE = $LASTEXITCODE

#    $path = ($pwd.ProviderPath) -replace $location, '';
    
#    Write-Host -ForegroundColor Yellow $path -nonewline

#    $global:LASTEXITCODE = $realLASTEXITCODE
#    $prompt = ([string][char]0x03BB)
#    Write-Host -ForegroundColor Cyan $prompt -nonewline
#    return " "
#}

function client() {
    start-localclient -username acobdenB -password "password1!" -connection "Local-QAF-Aggregator1" -shadowCopy
}

function admin() {
    start-localadmin -username Admin -password "password1!" -connection "QAF-Aggregator1" -shadowCopy
}

function query-buildcontainscommit($build, $commit) {
    git merge-base --is-ancestor $commit $build
    if ($?) {
        write-host -foregroundcolor Green "The commit is in the build."
    } else {
        write-host -foregroundcolor Red "The commit is NOT in the build."
    }
}

function patch-heartbeat() {
    git update-index --assume-unchanged Net/Elysian.Net/IO/MessageServiceConfig.cs
}

# Enable-GitColors

Pop-Location

# Start-SshAgent -Quiet

function cs-entities () {
   & "c:\Program Files (x86)\CodeSmith\v7.0\cs.exe" (join-path $location '\Liquid\Schema\Elysian.Liquid.DomainObjects\Entity\PROJECT ALL.csp')
   gc 'D:\Workspace\source\source\Liquid\Schema\Elysian.Liquid.DomainObjects\Entity\log\AllEntities.log'
}

function cs-settings () {
    & "c:\Program Files (x86)\CodeSmith\v7.0\cs.exe" (join-path $location 'Liquid\Schema\Elysian.Liquid.DomainObjects\Settings\PROJECT ALL.csp')
    gc 'D:\Workspace\source\source\Liquid\Schema\Elysian.Liquid.DomainObjects\Settings\log\AllSettings.log'
}

function cs-viewmodels () {
   & "c:\Program Files (x86)\CodeSmith\v7.0\cs.exe" (join-path $location 'Liquid\Client\Elysian.Liquid.Client.ViewModel\ViewModels\ViewModels.csp')
   # gc 'D:\Workspace\source\source\Liquid\Schema\Elysian.Liquid.DomainObjects\Entity\log\AllEntities.log'
}

function cs-mdcache () {
    & "c:\Program Files (x86)\CodeSmith\v7.0\cs.exe" (join-path $location 'Liquid\Schema\Elysian.Liquid.DomainObjects\Tag Message Objects\PROJECT ALL.csp')
    & "c:\Program Files (x86)\CodeSmith\v7.0\cs.exe" (join-path $location 'Liquid\Schema\Elysian.Liquid.DomainObjects\Tag Message Objects\PROJECT ALL FAST.csp')
}

function unzip() {
    & "C:\Program Files\7-Zip\7z.exe" @args
}

function bdl($directory) {
    $command = join-path $location "Liquid\Data\Elysian.Liquid.Data\bin\Debug\BulkDataLoader.exe"
    & $command import /Username:Admin /Password:password1! "/TargetDir:`"$directory`"" /Server:localhost /Port:31401
}

function ascii() {
  [Console]::OutputEncoding = [System.Text.Encoding]::ASCII
}

. "$xmlDir\improvedslle.ps1"
. "$xmlDir\setuptests.ps1"
ascii
# $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
# Write-VcsStatus

function Start-MDSimulator 
{ 
    Set-Location (Get-BranchPath "\Liquid\Testing\Elysian.Liquid.Testing.Simulation.Globex\bin\Debug\") 
    #&".\Elysian.Liquid.Testing.Simulation.Globex.exe" ("/NetworkXml:"+(Get-DefaultNetworkXml))  ("/Environment:"+(Open-NetworkXml).AllEnvironments[0].Name) /DisableOECache  

    &".\Elysian.Liquid.Testing.Simulation.Globex.exe" ("/NetworkXml:"+(Get-DefaultNetworkXml))  ("/Environment:"+(Open-NetworkXml).AllEnvironments[0].Name)

} 

function Start-MDSimulator-Release 
{ 
    Set-Location (Get-BranchPath "\Liquid\Testing\Elysian.Liquid.Testing.Simulation.Globex\bin\Release\") 
    #&".\Elysian.Liquid.Testing.Simulation.Globex.exe" ("/NetworkXml:"+(Get-DefaultNetworkXml))  ("/Environment:"+(Open-NetworkXml).AllEnvironments[0].Name) /DisableOECache

    &".\Elysian.Liquid.Testing.Simulation.Globex.exe" ("/NetworkXml:"+(Get-DefaultNetworkXml))  ("/Environment:"+(Open-NetworkXml).AllEnvironments[0].Name)

}

