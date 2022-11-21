param (
    [string] $task = "",
    [string] $os = "",
    [string] $output = ""
)

# Setup

$scriptPath = $MyInvocation.MyCommand.Path
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($output -eq "") {
    $output = "${dir}\build"
}

$win_rids = @("win-x64", "win-x86")
$lin_rids = @("linux-x64", "linux-musl-x64", "linux-arm", "linux-arm64")
$mac_rids = @("osx-x64", "osx.11.0-arm64", "osx.12-arm64")

# Functions

function GetOsRids() {
    $rids = @()
    if ($os -eq "win") {
        $rids = $win_rids
    }
    elseif ($os -eq "lin") {
        $rids = $lin_rids
    }
    elseif ($os -eq "mac") {
        $rids = $mac_rids
    }
    else {
        echo "ERROR: ``os`` param should be win, lin, or mac."
    }
    $rids
}

function BuildBinary() {
    $rids = GetOsRids
    foreach ($rid in $rids) {
        $o = "$output\bin\$rid"
        Remove-Item -LiteralPath $o -Force -Recurse -ErrorAction Ignore

        echo "### Building binary for $rid to $o"
        dotnet publish -c Release -o $o -r $rid `
            -p:PublishReadyToRun=true -p:PublishSingleFile=true `
            -p:DebugType=None -p:DebugSymbols=false -p:PublishTrimmed=true `
            --self-contained true -p:IncludeNativeLibrariesForSelfExtract=true
    }
}

function Clean() {
    Remove-Item -LiteralPath $output -Force -Recurse -ErrorAction Ignore
}

# Execute

echo "## Building Handlebars.conf ($task)"

if ($task -eq "binary") {
    BuildBinary
}
elseif ($task -eq "clean") {
    Clean
}
else {
    echo "ERROR: ``task`` param should be binary or clean."
}