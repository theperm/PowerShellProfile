$xmlDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

write-host -ForegroundColor green $xmlDir
# [Console]::OutputEncoding = new-object System.Text.UTF8Encoding
$source =  join-path (Split-Path -Parent -Path $xmlDir) "cmedsource"

function Stop-LocalLiquidEnvironment($onlyServer, $folder) {
    get-process `
        |? { $_.ProcessName -match "Elysian[.]Server[.]Console" -and $_.Path -match ("\\" + $folder + "\\") } `
        |? { ($onlyServer -eq $null) -or ($onlyServer -eq $_.MainWindowTitle) } `
        |% { stop-process $_ }
}

function startDS()
{
    # DataServer
    Set-NetworkXml
    Stop-LocalLiquidEnvironment "ShadowCopy"
    $dataServer = (Open-EnvironmentConfiguration).AllServers | where { $_.Type -eq "DataServer" } | select -first 1

    # Aggregator
    $aggregator = (Open-EnvironmentConfiguration).AllServers | where { $_.Type -eq "Aggregator" } | select -first 1

    if (($dataServer -ne $null) -and ($aggregator -ne $null))
    {
        Start-LocalLiquidInstance -Instance $dataServer.Instance.Name, $aggregator.Instance.Name -ShadowCopy -Minimised;
    }
}

function get-branch() {
    $encoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = new-object System.Text.UTF8Encoding
    $result = git rev-parse --abbrev-ref HEAD
    [Console]::OutputEncoding = $encoding
    if ($result -eq $null) {
        throw "Couldn't find a branch.  Are you sure you're in the source directory?";
    }
    return $result;
}

function prefix-for-branch($branch) {
    $result = (import-csv "$xmlDir\branches.csv" |? { $_.branch -eq $branch; } | select -first 1)
    if ($result -eq $null) {
        throw "Unrecognized branch $branch";
    }
    return $result.dbprefix;
}

function Get-ExpectedNetworkXml() {
    $branch = (get-branch)
    $name = $branch -replace "/", "_"
    return "$xmlDir\$name.xml"
}

function Set-NetworkXml() {
    $xml = new-object System.Xml.XmlDocument;
    $xml.PreserveWhitespace = $true;
    $xml.Load((join-path $source "Liquid\Testing\Elysian.Liquid.Testing\QAFNetwork.xml"))
    $branch = (get-branch)
    $prefix = prefix-for-branch $branch
    $xml.SelectNodes("//Database") |% { 
        $x = get-db-name $_ $prefix;
        $_.DatabaseName =  $x;
    }
    $file = (get-expectednetworkxml)
    $xml.Save($file)
    Set-DefaultsFromBranch . -NetworkXml $file
    Set-DefaultNetworkXml -NetworkXml $file
    write-host -ForegroundColor Green "Set network xml to $file"
}

function get-db-name($db, $prefix) {
    # echo "DB TYPE " $db.Type
    # echo "DB TYPE " ($db.Type -eq "GlobexConnector")
    if ($db.Type -eq "GlobexConnector") {
        return $prefix + "_GC_Transactional";
    } elseif ($db.Name -eq "Transactional") {
        return $prefix + '_${instanceName}_Transactional';
    } elseif ($db.Name -eq "Ema") {
        return $db.DatabaseName;
        # Ignore EMA
    } elseif (($db.Name -eq "Static") -or ($db.Name -eq "Common")) {
        return $prefix + "_CMED_STATIC";
    } else {
        write-error "Unrecognized database $db $db.Name"
        return $db.DatabaseName;
    }
}

<#
.SYNOPSIS
    Starts the liquid environment
.PARAMETER LoadClearportStatic
    Whether to start CMED_DataServer-StaticFeed and QAFOECacheRequest.  Defaults to false.
.PARAMETER preserveNetworkXml
    If true, do not regenerate the Network.xml
#>
function slle([switch]$LoadClearportStatic, [switch]$LoadBME, [switch]$LoadMarketActivityServer, [switch]$LoadAnalyticsServer, [string]$networkXml) { 
# Do something about excluding CMED_DataServer-StaticFeed
    if (($networkXml -eq $null) -or ($networkXml -eq "")) {
        Set-NetworkXml
    } else {
        Set-DefaultsFromBranch . -NetworkXml $networkXml
        Set-DefaultNetworkXml -NetworkXml $networkXml
    }
    stop-LocalLiquidEnvironment $null "ShadowCopy"
    $Exclude = $null

    if (!$LoadClearportStatic) {
        $Exclude += "CMED_DataServer-StaticFeed","QAFOECacheRequest"
    }
    if (!$LoadBME) {
        $Exclude += "CMED_BME1-AppServer","CMED_BME1-Implicator","CMED_BME1-TradeFeed"
    }
    if (!$LoadMarketActivityServer) {
        $Exclude += "CMED_MarketActivityServer"
    }
    if (!$LoadAnalyticsServer) {
        $Exclude += "AnalyticsServer"
    }
    . Start-LocalLiquidEnvironment -ShadowCopy -Minimised -ExcludeServerNames $Exclude
    $d = ([System.DateTime]::Now.ToString("d MMMM yyyy HH:mm:ss"))
    write-host -foregroundcolor cyan "Started local environment at $d"
}

function reboot($serverName) {
    Stop-LocalLiquidEnvironment $serverName
    $onlyServerNames = ,$serverName
    . Start-LocalLiquidEnvironment -ShadowCopyPerServer -Minimised -OnlyServerNames $onlyServerNames
    $d = ([System.DateTime]::Now.ToString("d MMMM yyyy HH:mm:ss"))
    write-host -foregroundcolor cyan "Rebooted $serverName at $d"
}

$branch = (get-branch)
write-host -foregroundcolor Green "Branch:  $branch"
Set-NetworkXml
git status -s