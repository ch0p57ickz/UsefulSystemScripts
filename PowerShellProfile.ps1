$gitHubPath = Join-Path $env:LOCALAPPDATA "GitHub"

$poshGitRoot = Get-ChildItem -Path $gitHubPath -Filter "Posh*"
$portableGitRoot = Get-ChildItem -Path $gitHubPath -Filter "PortableGit*"

$rubyFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Ruby*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1
$pythonFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Python*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1

function Set-Path
{
param($path)

    if(($env:Path -split ';') -inotcontains $path)
    {
        $env:Path = "$($env:Path.TrimEnd(';'));$path"
    }
}

Set-Path (Join-Path ($rubyFolder.FullName) "bin")
Set-Path $pythonFolder.FullName
Set-Path (Join-Path ($portableGitRoot.FullName) "bin")

Push-Location $poshGitRoot.FullName

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Enable-GitColors

Pop-Location

Start-SshAgent -Quiet
