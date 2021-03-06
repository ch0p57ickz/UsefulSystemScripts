﻿#region Useful Functions
function Set-Path
{
param($path)
    if ((-not $path) -or (-not (Test-Path $path)))
    {
        return
    }

    if(($env:Path -split ';') -inotcontains $path)
    {
        $env:Path = "$($env:Path.TrimEnd(';'));$path"
    }
}

function Is-Admin
{
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $prp.IsInRole($adm)
}

function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = ConvertPSObjectToHashtable $property.Value
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}

#endregion

$persistentStore = @{}
$persistentStorePath = Join-Path $env:USERPROFILE "powerShellPersistentStore"
if (Test-Path $persistentStorePath)
{
    $persistentStore = (Get-Content $persistentStorePath -raw) | ConvertFrom-Json | ConvertPSObjectToHashtable
}

#region script local variables
$gitHubPath = Join-Path $env:LOCALAPPDATA "GitHub"

$poshGitRoot = Get-ChildItem -Path $gitHubPath -Filter "Posh*"
$portableGitRoot = Get-ChildItem -Path $gitHubPath -Filter "PortableGit*"
$gitPad = (Join-Path $env:APPDATA "GitPad")
$github = Split-Path (Get-ChildItem -Path $env:LOCALAPPDATA -Recurse -Filter "github.exe" | Select-Object -First 1).FullName
$gitForWindows = Join-Path $env:ProgramFiles "Git\Bin"

$rubyFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Ruby2*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1
$pythonFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Python*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1

#endregion

if ($rubyFolder)
{
    Set-Path (Join-Path ($rubyFolder.FullName) "bin")
}

if ($pythonFolder)
{
    Set-Path $pythonFolder.FullName
}

if (Test-Path $gitForWindows)
{
    Set-Path $gitForWindows
}
else
{
    Set-Path (Join-Path ($portableGitRoot.FullName) "bin")
    Set-Path (Join-Path ($portableGitRoot.FullName) "usr\bin")
    Set-Path (Join-Path ($portableGitRoot.FullName) "cmd")
}

Set-Path $gitPad
Set-Path $github
Set-Path "$env:LOCALAPPDATA\Android\sdk\platform-tools"
Set-Path "C:\Program Files\MongoDB\Server\3.0\bin"

$env:PSModulePath -split ';' | where {-not (Test-Path $_) } | foreach {
    Write-Warning "PSModulePath `"$_`" does not exist"
}

Push-Location $poshGitRoot.FullName

if (Get-Module -ListAvailable -Name Posh-Git)
{
    # If module is installed in a default location ($env:PSModulePath),
    # use this instead (see about_Modules for more information):
    Import-Module posh-git
}
else
{
    if (-not (Test-Path ".\posh-git.psm1"))
    {
        Write-Error "Posh Git is not installed and not found in GitHub folder"
    }
    else
    {
        # Load posh-git module from current directory
        Import-Module .\posh-git.psm1
    }
}


function Start-Start
{
    & "start" .
}

Set-Alias -Name "start." -Value "Start-Start"

function Set-MuteBell {
    $global:MuteBell = $true
}

function Set-UnMuteBell {
    $Global:MuteBell = $null
}

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    #Puts a smiley or sad face depending on the success of the last command
    if($?) #this needs to be first!
    {
        $smileyTitle = [char]0x263A #white shows up better in the title bar
        $smileyPrompt = [char]0x263B #black shows up better in the console
    }
    else
    {
        $smileyTitle = [char]0x2639 #sadface
        $smileyPrompt = "!" #sadface doesn't show up in console (shows up as ?) :(
    }

    $realLASTEXITCODE = $LASTEXITCODE

    #add the cool little stack counters (for no real reason)
    $stackCount = (Get-Location -Stack).Count
    $stack = ""
    for($i = 0; $i -lt $stackCount; $i++)
    {
        if([String]::IsNullOrEmpty($stack))
        {
            $stack = " "
        }
        $stack += "+"
    }

    # Is admin?
    $arrowChar = ""
    $adminTitle = ""
    if(Is-Admin)
    {
        $arrowChar = [char]8593
        $adminTitle = "Administrator "
    }

    if ($GitPromptSettings)
    {
        # Reset color, which can be messed up by Enable-GitColors
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }

    #put it all together
    $host.ui.RawUI.WindowTitle = ("{0} {1}P> {2}" -f $smileyTitle,$adminTitle,(get-location))

    Write-Host ("[{0} {1}{2}]`n{3}{4}" -f ([DateTime]::Now).ToLongTimeString(),(pwd),$stack,$smileyPrompt,$arrowChar) -nonewline

    if (Test-Path function:\Write-VcsStatus)
    {
        Write-VcsStatus
    }

    $bell = "`a"
    if($global:MuteBell)
    {
        $bell = $null
    }

    $global:LASTEXITCODE = $realLASTEXITCODE
    return ">$bell "
}

if(Test-Path function:\Enable-Gitcolors)
{
    #region 'migrated' from posh git
    # Enable-GitColors obsolete

    #Start-SshAgent -Quiet
    #endregion
}

#region Import Modules from folder
Push-Location $PSScriptRoot

Import-Module ".\NodeJsFunctions.psm1"

Pop-Location

#endregion

Pop-Location

$persistentStore | ConvertTo-Json | Out-File $persistentStorePath