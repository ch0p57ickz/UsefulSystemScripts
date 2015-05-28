param(
    $ProfileFile = "Microsoft.PowerShell_profile.ps1"
)

function WarnIfRunningInISE
{
    if($psISE)
    {
        # TODO: Replace with Confirm
        Write-Warning "You are running in the ISE host. This well set the ISE profile file in $profile. If you want to continue, press enter (or Ctrl+C to quit)"
        Read-Host
    }
}

function ResolveProfileFile
{
    if (Test-Path $ProfileFile)
    {
        return
    }

    $fullPath = Join-Path $PSScriptRoot $ProfileFile
    $ProfileFile = Resolve-Path $fullPath
}

function EnsureProfileRootExists
{
    $rootFolder = Split-Path $profile

    if (-not (Test-Path $rootFolder))
    {
        New-Item -Force -ItemType Directory $rootFolder
    }
}

function CurrentProfileExists
{
    Test-Path $profile
}

function IsProfileChanged
{
    $existingHash = Get-FileHash -Path $profile -Algorithm MD5
    $profileHash = Get-FileHash -Path $ProfileFile -Algorithm MD5

    $existingHash.Hash -ne $profileHash.Hash
}

function CreateBackupOfProfile
{
    $backupProfile = [IO.Path]::ChangeExtension($profile, [DateTime]::Now.Ticks)
    Copy-Item $profile $backupProfile
}

function CopyProfileFileToProfile
{
    Copy-Item -Path $ProfileFile -Destination $profile -Force
}

function IsChocoInstalled
{
    $choco = Get-Command choco -ErrorAction SilentlyContinue
    if($choco)
    {
        $true
    }
    else
    {
        $false
    }
}

function InstallChocolatey
{
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

function IsPsGetInstalled
{
    Test-Path function:\\Install-Module
}

function InstallPsGet
{
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
}

function IsPoshGitInstalled
{
    $poshgit = Get-Module -ListAvailable posh-git
    if(-not $poshgit)
    {
        $poshgit = Get-Module posh-git
    }

    if($poshgit)
    {
        $true
    }
    else
    {
        $false
    }
}

function InstallPoshGit
{
    # Installed some weird C:\tools\poshgit\dahlbyk-posh-git-2490619
    #choco install poshgit
    Install-Module posh-git
}

if(-not (IsChocoInstalled))
{
    InstallChocolatey
}

if(-not (IsPsGetInstalled))
{
    InstallPsGet
}

if(-not (IsPoshGitInstalled))
{
    InstallPoshGit
}

WarnIfRunningInISE
ResolveProfileFile
EnsureProfileRootExists
if(CurrentProfileExists -and IsProfileChanged)
{
    CreateBackupOfProfile
}

CopyProfileFileToProfile