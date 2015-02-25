#region Useful Functions
function Set-Path
{
param($path)

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

#endregion

#region script local variables
$gitHubPath = Join-Path $env:LOCALAPPDATA "GitHub"

$poshGitRoot = Get-ChildItem -Path $gitHubPath -Filter "Posh*"
$portableGitRoot = Get-ChildItem -Path $gitHubPath -Filter "PortableGit*"
$gitPad = (Join-Path $env:APPDATA "GitPad")

$rubyFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Ruby*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1
$pythonFolder = Get-ChildItem -Path "$env:SystemDrive\" -Filter "Python*" | Sort-Object -Property "Name" -Descending | Select-Object -First 1
#endregion

Set-Path (Join-Path ($rubyFolder.FullName) "bin")
Set-Path $pythonFolder.FullName
Set-Path (Join-Path ($portableGitRoot.FullName) "bin")
Set-Path $gitPad

Push-Location $poshGitRoot.FullName

# Load posh-git module from current directory
Import-Module .\posh-git

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-git

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

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    
    #put it all together
    $host.ui.RawUI.WindowTitle = ("{0} {1}P> {2}" -f $smileyTitle,$adminTitle,(get-location))

    Write-Host ("[{0} {1}{2}]`n{3}{4}" -f ([DateTime]::Now).ToLongTimeString(),(pwd),$stack,$smileyPrompt,$arrowChar) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return ">`a "
}

#region 'migrated' from posh git
Enable-GitColors

Pop-Location

Start-SshAgent -Quiet
#endregion