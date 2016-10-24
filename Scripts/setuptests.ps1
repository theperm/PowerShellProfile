$xmlDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
# [Console]::OutputEncoding = new-object System.Text.UTF8Encoding
$source =  join-path (Split-Path -Parent -Path $xmlDir) "cmedsource"


function RunNUnit($params, $output) {
    if (test-path $output) { rm $output }
    $fixparams = $params -replace """","`\"""
    $nunit = (join-path $source "packages\NUnit.2.5.10.11092\tools\nunit-console.exe")
    $cmd = "$nunit $fixparams D:\Workspace\source\source\Liquid\Testing\Elysian.Liquid.Testing\Elysian.Liquid.Testing.csproj /xml=$output"

    write-host -ForegroundColor Yellow $cmd
	$csproj = join-path $source "Liquid\Testing\Elysian.Liquid.Testing\Elysian.Liquid.Testing.csproj"
    & $nunit $fixparams $csproj /xml=$output
    # cmd /c /s $cmd
}

function newdb-test { 
    set-testnetworkxml
    . New-Databases2 -Environment Aggregated -DeleteExistingDatabases 
}

function slle-test { 
    set-testnetworkxml
    . Start-LocalLiquidEnvironment -Environment Aggregated -ShadowCopy -Minimised -ShadowCopyFolder "TestShadowCopy"
}

function startDS-Test()
{
    # DataServer
    $dataServer = (Open-EnvironmentConfiguration).AllServers | where { $_.Type -eq "DataServer" } | select -first 1

    # Aggregator
    $aggregator = (Open-EnvironmentConfiguration).AllServers | where { $_.Type -eq "Aggregator" } | select -first 1

    if (($dataServer -ne $null) -and ($aggregator -ne $null))
    {
        Start-LocalLiquidInstance -Instance $dataServer.Instance.Name, $aggregator.Instance.Name -ShadowCopy -Minimised -ShadowCopyFolder "TestShadowCopy"
    }
}

# Client: $Root/System (AdminClient, Aggregator1-Gateway), Test: FailureAcknowledgementTest[InsertTradeableItem], FAILED: Values of [ErrorCode] compared - expected (44088 - UdsMaximumAggregateDeltaExceededForStrategy), actual (44089 - CannotFindSenderComp).

function set-testnetworkxml() {
    $file = (join-path $source "Liquid\Testing\Elysian.Liquid.Testing\UnitTestNetwork.xml")
    Set-DefaultNetworkXml -NetworkXml $file
    Set-DefaultsFromBranch . -NetworkXml $file
}

function SetupTestDb() {
    newdb-test
    write-progress -Activity "Test Setup" -CurrentOperation "Setup Data Server" -PercentComplete 50
    startds-Test
    [System.Threading.Thread]::Sleep(20000);
    Stop-LocalLiquidEnvironment $null "TestShadowCopy"
    startDS-Test
    write-progress -Activity "Test Setup" -CurrentOperation "Running setup fixture" -PercentComplete 75
    [System.Threading.Thread]::Sleep(20000);
    RunNUnit "/run:Elysian.Liquid.Testing.Server.TestFixtures.SetupFixture.Test" "SetupFixtureTestResult.xml"
    return $LastExitCode -eq 0;
}

function Setup-Tests([Parameter(Mandatory=$true)]$branch, [switch]$skipGit) {
    Set-Location $source
    set-testnetworkxml
    cd $source
    write-progress -Activity "Test Setup" -CurrentOperation "Getting latest" -PercentComplete 0
    if (-not $skipGit) {
        git checkout $branch
        git pull --ff-only
        if ($? -eq $false) {
            throw "Problems pulling from git, please sort out manually and try again."
        }
    }
    write-progress -Activity "Test Setup" -CurrentOperation "Building Database" -PercentComplete 25
    Stop-LocalLiquidEnvironment $null "TestShadowCopy"
	$sln = join-path $source "AllElysianProjects.sln"
    msbuild --% /m $sln
    
    if (SetupTestDb) {
        Stop-LocalLiquidEnvironment $null "TestShadowCopy"
        write-progress -Activity "Test Setup" -CurrentOperation "Starting servers" -Complete $true
        
        slle-test
        (get-host).Ui.RawUI.BackgroundColor = "Black"
        write-host "Testing environment ready."
    } else {
        write-host -color Red "Problem with setting up static data."
    }
}
function getTeamCity([Parameter(Mandatory=$true)]$branch) {
    $cs = "Server=SMLDELYSIAN24;Database=TeamCity_Reports;User Id=TeamCity;Password=TeamC1ty!;"
    $c = [System.Data.SqlClient.SqlConnection] $cs
    $c.Open()
    $cmd = new-object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $c
    $cmd.CommandText = "usp_AutomatedServerTestFailures"
    $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
    [void] $cmd.Parameters.AddWithValue("@set", $branch)
    $cmd.ExecuteReader() |% { toObject $_ }
    $c.Close()
}

function toObject([Parameter(Mandatory=$true)]$dr) {
    $result = new-object System.Object
    for ($i = 0; $i -lt $dr.FieldCount; $i++) {
        add-member -InputObject $result -MemberType NoteProperty -Value $dr.GetValue($i) -Name $dr.GetName($i)
    }
    $result
}

function getRegressionTests($branch, [ScriptBlock]$filter = $null) {
    $rawTests = getTeamCity $branch |% { $_.Test }
    if ($filter -ne $null) {
        $rawTests = $rawTests |? $filter
    }
    return $rawTests | sort-object | get-unique
}

function getRegression($branch, [string]$file="Regression.xml", [ScriptBlock]$filter = $null) {
    $tests = getRegressionTests $branch $filter
    $tests = [string]::Join(",", $tests)
    RunNUnit "/run:$tests" $file
}

# ([xml] (gc "Regression.xml")).SelectNodes("//test-case[@success='False']")
function failures($filename) {
    ([xml] (gc $filename)).SelectNodes("//test-case[@success='False']")
}

function testcases($filename) {
write-host -ForegroundColor Red $filename
    ([xml] (gc $filename)).SelectNodes("//test-case")
}

function parseTest($test) {
    $test = $test + "."
    $state = "Start"
    $dot = "."[0]
    $quote = """"[0]
    $bra = "("[0]
    $ket = ")"[0]
    for ($i = 0; $i -lt $test.Length; $i++) {
        $c = $test[$i];
        # echo "State $state Char $c"
        switch ($state) {
            "Start" {
                $start = $i;
                $state = "Identifier";
            }
            "Identifier" {
                switch ($c) {
                    $dot {
                        $test.Substring($start, $i-$start);
                        $state = "Start";
                    }
                    $bra {
                        $state = "Bracket";
                    }
                }
            }
            "Bracket" {
                switch ($c) {
                    $ket {
                        $state = "Identifier";
                    }
                    $quote {
                        $state = "String";
                    }
                }
            }
            "String" {
                switch ($c) {
                    $quote {
                        $state = "Bracket";
                    }
                }
            }
        }        
    }
}

function toTable($branch, $filter, $instances) {
    $tests = getRegressionTests $branch $filter
    # $instances = (0,1,2)
    $results = new-object System.Collections.HashTable
    $instances |% { $results[$_] = (testcases "Regression$_.xml") }
    @"
<style>
  th { text-align : left }
  th.run { text-align : center; }
  td { background-color : Yellow }
  th, td { padding : 2px; }
  td.Failure { background-color : #fdd }
  td.Success { background-color : #dfd }
  table { border-collapse : collapse }
  tbody th { font-weight : normal }
</style>
"@
    "<table>"
    "<thead><tr><th>Namespace</th><th>Fixture</th><th>Test</th>"
    $instances |% { "<th class='run'>$_</th>" }
    "</tr></thead>"
    "<tbody>"
    foreach ($t in $tests) {
        $parsed = parseTest $t
        $ns = $parsed | select -first ($parsed.Length - 2)
        "<tr><th>"
        [string]::Join(".", $ns)
        "</th><th>"
        $parsed[$parsed.Length - 2]
        "</th><th>"
        $parsed[$parsed.Length - 1]
        "</th>"
        foreach ($run in $instances) {
            $r = $results[$run] |? { $_.name -eq $t } |% { $_.result }
            "<td class='$r'>$r</td>"
        }
        "</tr>"
    }
    "</tbody></table>"
}

function runTestsMultipleTimes($branch, [ScriptBlock]$filter, $instances) {
    $colours = "DarkMagenta","DarkCyan","DarkYellow","DarkGreen"
    foreach ($i in $instances) {
        (get-host).Ui.RawUI.BackgroundColor = $colours[$i % $colours.Length]
        getRegression $branch "Regression$i.xml" $filter 
    }
    (get-host).Ui.RawUI.BackgroundColor = "Black"
}

function showTestResults($branch, [ScriptBlock]$filter=$null, $instances=(0,1,2)) {
    toTable $branch $filter $instances | out-file x.html; ii x.html
}

function runtests($branch, [ScriptBlock]$filter, $instances=(0,1,2)) {
    runTestsMultipleTimes $branch $filter $instances
    showTestResults $branch $filter $instances
}

function runit($branch, [ScriptBlock]$filter) {
    (get-host).Ui.RawUI.BackgroundColor = "Black"
    Setup-Tests $branch
    runtests $branch, $filter
    (get-host).Ui.RawUI.BackgroundColor = "Black"
}

# toTable "release/v8.7" | out-file x.html; ii x.html

# git rebase feature/crossing2 feature/CDA-3140
# git checkout feature/crossing2
# git merge feature/CDA-3140