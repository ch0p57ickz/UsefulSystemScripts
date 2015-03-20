[CmdletBinding(ConfirmImpact="High", SupportsShouldProcess=$true)]
param(
    #[Parameter(Mandatory)]
    [regex]$filter = ""
)

#
# Clean Registry
#
$activity = "Scanning Registry"
Write-Progress -Activity $activity
$allKeys = Get-ChildItem 'HKCU:\' -Recurse -ErrorAction SilentlyContinue
$keyCount = $allKeys.Count
Write-Progress -Activity $activity -Completed

$activity = "Looking for matches"
Write-Progress -Activity $activity
for($i = 0; $i -lt $keyCount; $i++)
{   
    $removed = $false
    $key = $allKeys[$i]
    $key | Get-ItemProperty | where { $_ -match $filter } | foreach {
        
        "Item Found"
        $key

        $itemProperty = $_

        $itemProperty.PSObject.Properties | foreach {
            if ($_.Value -match $filter)
            {
                $specificItemProperty = "$($itemProperty.PSPath):$($_.Name)"
                if($PSCmdlet.ShouldProcess($specificItemProperty, "Delete Item Property"))
                {
                    Remove-ItemProperty -Path $itemProperty.PSPath -Name $_.Name

                    "$specificItemProperty Removed"
                    $removed = $true
                }
            }
        }

        if((-not $removed) -and $PSCmdlet.ShouldProcess($key.Name, "Delete Key"))
        {
            Remove-Item -Recurse -Path $key.PSPath

            "$($key.PSPath) Removed"
        }
    }
}
Write-Progress -Activity $activity -Completed

$activity = "Scanning file system"
Write-Progress -Activity $activity

$sh = New-Object -COM WScript.Shell

function DeleteRecentLinks
{
param($rootPath)

    Get-ChildItem -Recurse -Path $rootPath -Filter "*.lnk" | foreach {
        $targetPath = $sh.CreateShortcut($_.FullName).TargetPath
        if($targetPath -match $filter)
        {
            $_.FullName
            if($PSCmdlet.ShouldProcess($_.FullName, "Delete Link Item"))
            {
                Remove-Item -Path $_.FullName

                "$($_.FullName) Deleted"
                
            }
        }
    }
}

#DeleteRecentLinks "$($env:USERPROFILE)\Recent"
DeleteRecentLinks "$($env:APPDATA)\Microsoft\Windows\Recent"