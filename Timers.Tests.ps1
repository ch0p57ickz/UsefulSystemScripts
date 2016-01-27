$SUT = ".\Timers.psm1"

pushd $PSScriptRoot
try
{
    Import-Module $SUT

    Describe "Get-EstimatedTimeCompleted" {
        Mock Get-CurrentTime -ModuleName Timers { [DateTime]"1/7/1987 12:00am" }

        It "Adds Hours And Minutes Correctly" {
            Get-EstimatedTimeCompleted -Hours 1 -Minutes 23 | Should Be ([DateTime]"1/7/1987 1:23am")
            }
        It "Can Calculate From Percent" {
            Get-EstimatedTimeCompleted -StartTime ([DateTime]"1/6/1987 12:00am") -Percent 50 | Should Be ([DateTime]"1/8/1987 12:00am")
            Get-EstimatedTimeCompleted -StartTime ([DateTime]"1/6/1987 12:00am") -Percent .25 -Base1 | Should Be ([DateTime]"1/10/1987 12:00am")
            Get-EstimatedTimeCompleted ([DateTime]"1/6/1987 12:00am") 10 | Should Be ([DateTime]"1/16/1987 12:00am")
        }
    }
    Describe "Get-StartTime" {
        It "Figure out start time from finish time" {
            Get-StartTime -EstimatedTimeCompleted "1/7/1987 4:56am" -Hours 4 -Minutes 56 | Should Be ([DateTime]"1/7/1987 12:00am")
        }
    }

    Describe "Set-PercentTime" {
        Mock Get-CurrentTime -ModuleName Timers { 
            if ($Global:LastPercentage) 
            {
                [DateTime]"1/7/1987 1:00am"
            }
            else
            {
                [DateTime]"1/7/1987 12:00am"   
            }
        }
        It "Can figure out remaining time from percent" {
            Stop-TimerJob
            Reset-PercentTime
            Set-PercentTime 0 | Should BeNullOrEmpty
            Set-PercentTime 50 | Should Be ([DateTime]"1/7/1987 2:00am") 
        }
    }

    Describe "TimerJob" {
        Mock Get-CurrentTime -ModuleName Timers { [DateTime]"1/7/1987 12:00am" }
        It "Can print both overall and current rate -based time remaining" {
            Stop-TimerJob
            Start-TimerJob -StartTime ([DateTime]"1/6/1987 12:00am")
            $results = Set-TimerJob -Percent 50
            $results.OverallBased | Should Be ([DateTime]"1/8/1987 12:00am")
            $results.CurrentRate | Should Be ([DateTime]"1/8/1987 12:00am")
            Stop-TimerJob
        }
    }
}
finally
{
    Remove-Module ([IO.Path]::GetFileNameWithoutExtension($SUT))
    popd

}