function Get-EstimatedTimeCompleted
{
param(
    [Parameter(ParameterSetName = "Time")]
    [int]$Hours = 0,
    [Parameter(ParameterSetName = "Time")]
    [int]$Minutes = 0,
    [Parameter(Mandatory, ParameterSetName = "Percent", Position = 0)]
    [DateTime]$StartTime,
    [Parameter(ParameterSetName = "Percent", Position = 1)]
    [double]$Percent,
    [Parameter(ParameterSetName = "Percent")]
    [switch]$Base1 = $false
)
    switch($PSCmdlet.ParameterSetName)
    {
        "Time" {
            (Get-CurrentTime).Add([TimeSpan]::FromHours($Hours)).Add([TimeSpan]::FromMinutes($Minutes))
        }
        "Percent" {
            $timeSinceStarted = (Get-CurrentTime) - $StartTime
            $totalTimeTicksFromPercent = $timeSinceStarted.Ticks / $Percent
            if (-not $Base1)
            {
                $totalTimeTicksFromPercent *= 100
            }
            $totalTimeFromStart = [TimeSpan]::FromTicks($totalTimeTicksFromPercent)

            $StartTime + $totalTimeFromStart
        }
    }
}

function Get-StartTime
{
param(
    [Parameter(Mandatory)]
    [DateTime]$EstimatedTimeCompleted,
    [int]$Hours = 0,
    [int]$Minutes = 0
)
    $EstimatedTimeCompleted.Add([TimeSpan]::FromHours($Hours * -1)).Add([TimeSpan]::FromMinutes($Minutes * -1))
}

function Set-PercentTime
{
param(
    [Parameter(Mandatory)]
    [double]$Percent,
    [Switch]$Base1 = $false
)
    $wasPreviouslyMarked = $false
    $lastTime = $null
    if ($Global:LastPercentTime)
    {
        $lastTime = $Global:LastPercentTime
        $lastPercentage = $Global:LastPercentage
        $wasPreviouslyMarked = $true
    }

    #Set-PercentTimeOverride -Percent $Percent -StartTime (Get-CurrentTime)
    $Global:LastPercentage = $Percent
    $Global:LastPercentTime = Get-CurrentTime

    if($base1)
    {
        $Global:LastPercentage *= 100
    }

    if(-not $wasPreviouslyMarked)
    {
        return
    }

    $timeBetweenMarks = $Global:LastPercentTime - $lastTime
    $percentageDifference = $Global:LastPercentage - $lastPercentage

    $remainingPercent = 100 - $Global:LastPercentage

    $remainingTicks = $remainingPercent / $percentageDifference * $timeBetweenMarks.Ticks
    (Get-CurrentTime) + ([TimeSpan]::FromTicks($remainingTicks))
}

function Set-PercentTimeOverride
{
param(
    $Percent,
    $StartTime
)
    $Global:LastPercentage = $Percent
    $Global:LastPercentTime = $StartTime
}

function Reset-PercentTime
{
    if ($Global:TimerJobStartTime)
    {
        throw "Call Stop-TimerJob first"
    }
    
    Remove-Variable -Name LastPercentTime -Scope Global -ErrorAction SilentlyContinue
    Remove-Variable -Name LastPercentage -Scope Global -ErrorAction SilentlyContinue
}

function Start-TimerJob
{
param(
    [DateTime]$StartTime = [DateTime]::Now
)
    Reset-PercentTime
    $Global:TimerJobStartTime = $StartTime
    Set-PercentTimeOverride -Percent 0 -StartTime $StartTime
}

function Set-TimerJob
{
param(
    [double]$Percent,
    [Switch]$Base1 = $false
)
    if (-not $Global:TimerJobStartTime)
    {
        throw "Call Start-TimerJob first"
    }

    $overall = Get-EstimatedTimeCompleted -StartTime $Global:TimerJobStartTime -Percent $Percent -Base1:$Base1
    $currentRate = Set-PercentTime $Percent -Base1:$Base1

    New-Object psobject -Property @{"OverallBased"=$overall; "CurrentRate"=$currentRate}
}

function Stop-TimerJob
{
    Remove-Variable -Name TimerJobStartTime -Scope Global -ErrorAction SilentlyContinue
}

function Get-CurrentTime
{
    [DateTime]::Now
}

Export-ModuleMember -Function Get-EstimatedTimeCompleted
Export-ModuleMember -Function Get-StartTime
Export-ModuleMember -Function Set-PercentTime
Export-ModuleMember -Function Reset-PercentTime
Export-ModuleMember -Function Start-TimerJob
Export-ModuleMember -Function Set-TimerJob
Export-ModuleMember -Function Stop-TimerJob