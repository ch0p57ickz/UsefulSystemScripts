param(
    $profilePath = "C:\Source\UsefulSystemScripts\PowerShellProfile.ps1"
)

if (-not (Test-Path $profilePath))
{
    "Hey! You haven't cloned your UsefulSystemScripts repo on this machine yet. You'll need to do that to get all you custom stuff working."
    ""
    "Minimal Setup Steps"
    "1. (In Admin Mode) Run Set-ExecutionPolicy -Unrestricted"
    "2. Install GitHub for Windows" 
    "3. Launch GitHub Shell (this installs the Git Posh stuff)"
    "4. Clone your ch0p57ickz\UsefulSystemScripts repro into C:\Source" 
    ""
    return
}

. $profilePath