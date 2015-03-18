#set env vars
<#
set-variable -name RDPFormat -value "prompt for credentials:i:1`nfull address:s:{0}`nusername:s:{1}`nuse multimon:i:0`ndesktopwidth:i:1680`ndesktopheight:i:1050`nwinposstr:s:0,1,1530,0,2594,738" -scope global
#>



#internal functions

function info
{
    ("Today is: " + [DateTime]::Now.ToString("f"))
    "You are logged into {0}" -f $env:computername
    "Uptime: {0}" -f (uptime).ToString()
}

function uptime
{
    $upTime = [DateTime]::Parse(
        (gwmi win32_operatingSystem).ConvertToDateTime((gwmi win32_operatingSystem).LastBootUpTime))
    [DateTime]::Now - $upTime
}

function edit-profile
{
    ise $profile
}

function reload
{
    . $PROFILE
}

function iexplore
{
    $address = [String]::Join(" ", $args)
    $address = (Get-ChildItem $address).FullName
    $expression = ("& 'C:\Program Files (x86)\Internet Explorer\iexplore.exe' {0}" -f $address)
    invoke-expression $expression
}

function Is-Admin
{
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $prp.IsInRole($adm)
}

function Send-PathToClipboard
{
param(
$file
)
    if($file)
    {
        if(-not (Test-Path $file))
        {
            throw "$file does not exist"
        }

        (Get-Item $file).FullName | Clip
    }
    else
    {
        $PWD | Clip
    }
}

function start.
{
    start .
}

function Elevate
{
    
}

function Get-AzureConnectionString
{
[CmdLetBinding(DefaultParameterSetName="AzurePrimary")]
param(
[Parameter(Mandatory=$true)]
[String]
$AccountName,

[Parameter(Mandatory=$True,
ParameterSetName="Manual")]
[String]
$AccountKey,

[Parameter(Mandatory=$False,
ParameterSetName="AzurePrimary")]
[Parameter(Mandatory=$False,
ParameterSetName="AzureSecondary")]
[Guid]
$SubscriptionId = $env:AzureSubscription,

[Parameter(Mandatory=$False,
ParameterSetName="AzurePrimary")]
[Parameter(Mandatory=$False,
ParameterSetName="AzureSecondary")]
[System.Security.Cryptography.X509Certificates.X509Certificate2]
$Certificate = (get-item Cert:\CurrentUser\My\$env:AzureCert),

[Parameter(Mandatory=$True,
ParameterSetName="AzureSecondary")]
[Switch]
$Secondary=$false,

[Parameter(Mandatory=$false)]
[Switch]
$Https=$true
)

if([String]::IsNullOrEmpty($AccountKey))
{
    $storageKeys = Get-StorageKeys -ServiceName $AccountName -Certificate $Certificate -SubscriptionId $SubscriptionId
    if($Primary)
    {
        $AccountKey = $storageKeys.Primary
    }
    else
    {
        $AccountKey = $storageKeys.Secondary
    }
}

$endpoint = "http"
if($Https)
{
    $endpoint += "s"
}

return ("DefaultEndpointsProtocol={0};AccountName={1};AccountKey={2}" -f $endpoint,$AccountName,$AccountKey)

}

#aliases


#prompt
function prompt
{
    #Puts a smiley or sad face depending on the success of the last command
    if($?) #this needs to be first!
    {
        $smiley1 = [char]0x263A #white shows up better in the title bar
        $smiley2 = [char]0x263B #black shows up better in the console
    }
    else
    {
        $smiley1 = [char]0x2639 #sadface
        $smiley2 = "!" #sadface doesn't show up in console (shows up as ?) :(
    }
    
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
    
    #put it all together
    $host.ui.RawUI.WindowTitle = ("{0} {1}P> {2}" -f $smiley1,$adminTitle,(get-location))
    Write-Host ("[{0} {1}{2}]`n{3}{4}>" -f ([DateTime]::Now).ToLongTimeString(),(pwd),$stack,$smiley2,$arrowChar) -nonewline
    return "`a "
}

<#
$azureModule = "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"
if(Test-Path $azureModule)
{
    Import-Module $azureModule
}

$publishSettings = "C:\Users\japrom\SkyDrive\Tools\Azpad031ZQN1934-ArmadaTest-ArmadaGPU-ArmadaRelease-ArmadaDev-12-4-2012-credentials.publishsettings"
if(Test-Path $publishSettings)
{
    try
    {
    	Import-AzurePublishSettingsFile $publishSettings | Out-Null

    	Set-AzureSubscription -DefaultSubscription ArmadaTest
    }
    catch
    { } # Ignore errors.. 
}
#>
## Azure 2
function Azure
{
Import-Module Azure
$CertPath = "Cert:\\CurrentUser\My\1E81909535C2D2E5F039FD7208B91B228BA24861"
if(-not (Test-Path $CertPath))
{
    throw "Cannot find RASE Azure Management certificate. Make sure it is imported (in CX RASE Sharepoint)"
}
$RASEAzureManagementCert = (Get-Item Cert:\\CurrentUser\My\1E81909535C2D2E5F039FD7208B91B228BA24861)

$AzureSubscriptions = @{
AgeDev="0678fe4c-c4b1-4a5a-8acb-5428702083f9";
AgeTest="7e370f62-8323-4f07-8dad-0908a6dcae5f";
AgeRelease="37de9e80-05be-4678-aad1-7c6f4c4bb33a";
ArmadaDev="e5888caa-ccd7-4452-b1d8-a04fd2a347fa";
ArmadaGPU="a8e8dae4-a140-4cfd-a4cf-62cb7192562a";
ArmadaRelease="0dd7511a0-6b2c-4401-b330-33d601805773";
ArmadaTest="348f5753-7143-43f7-aaf1-c7a76151ac89";
AzPad="22e72131-01c1-4269-b2fa-ec3ac8c676f5";
RASE="4bcca9e1-d0fd-4fdb-bf31-b25d20a18651";
Bingo="62b0a8d5-001e-4865-808d-9c5870aac99b"
}

if((Get-AzureSubscription).Count -ne $AzureSubscriptions.Count)
{
    foreach($name in $AzureSubscriptions.Keys)
    {
        $subscriptionId = $AzureSubscriptions[$name]
        Set-AzureSubscription -SubscriptionId $subscriptionId -SubScriptionName $name -Certificate $RASEAzureManagementCert
    }
    Set-AzureSubscription -Default "RASE"
}
"Current Azure Subscription: " + (Get-AzureSubscription -Current).SubscriptionName
}

function Get-CastlesTestRigState
{
    $castlesUsername = "CastlesTest"
    $castlesPassword = ConvertTo-SecureString -AsPlainText -Force "Castles!"

    $castlesCredential = New-Object System.Management.Automation.PSCredential ($castlesUsername, $castlesPassword)

    $sessionOption = New-PSSessionOption -SkipCACheck
    $rig1Job = Invoke-Command -UseSSL -SessionOption $sessionOption -ComputerName "castlesperftestrig1.cloudapp.net" -Credential $castlesCredential -ScriptBlock { qwinsta } -AsJob
    $rig2Job = Invoke-Command -UseSSL -SessionOption $sessionOption -ComputerName "castlesperftestrig2.cloudapp.net" -Credential $castlesCredential -ScriptBlock { qwinsta } -AsJob

    while($rig1Job -or $rig2Job)
    {
        if($rig1Job -and (Get-Job -Id $rig1Job.Id).State -ne "Running")
        {
            "TestRig1"
            Receive-Job -Job $rig1Job
            $rig1Job = $null
        }

        if($rig2Job -and (Get-Job -Id $rig2Job.Id).State -ne "Running")
        {
            "TestRig2"
            Receive-Job -Job $rig2Job
            $rig2Job = $null
        }
    }
}


. ([Environment]::GetFolderPath([Environment+SpecialFolder]::Personal) + "\WindowsPowerShell\Unix.ps1")

#actions
