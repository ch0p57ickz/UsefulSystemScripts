param(
[Parameter(Mandatory)]
    $Assembly
)
$debugAttr = [System.Reflection.Assembly]::LoadFile($Assembly).GetCustomAttributes([System.Diagnostics.DebuggableAttribute], $false) | select-object -first 1

$buildType = "Release"
if ($debugAttr)
{
    $debug = ([System.Diagnostics.DebuggableAttribute]$debugAttr)
    $hasDebuggableAttribute = $true
    $isJitOptimized = ($debug.IsJITTrackingEnabled)

    if ($isJitOptimized)
    {
        $buildType = "Debug"
    }

    $debugModes = [System.Diagnostics.DebuggableAttribute+DebuggingModes]
    $DebugOutput = "pdb-only"
    if (($debug.DebuggingFlags -band $debugModes::Default) -ne [int]$debugModes::None)
    {
        $DebugOutput = "Full"
    }
    
}
else
{
    $isJitOptimized = $true
}


$isJitOptimized,$buildType,$DebugOutput