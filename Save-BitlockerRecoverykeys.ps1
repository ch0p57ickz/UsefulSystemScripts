param(
    [Parameter()]
    [String[]]
    $Computers = (
        "japrom-alkari",
        "japrom-beast"
        )
)

$code = {

$possiblePaths = @("C:\Users\japrom\SkyDrive Pro\BitLockerKeys", "C:\Users\japrom\OneDrive for Business\BitLockerKeys")

$DestinationRoot = $null
foreach($path in $possiblePaths)
{
    if (Test-Path $path)
    {
        $DestinationRoot = $path
        break
    }
}

Import-Module Bitlocker -erroraction SilentlyContinue
(Get-BitLockerVolume).KeyProtector | `
    Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" } | `
    foreach {
        $keyProtector = $_.KeyProtectorId.Trim("{", "}")
        echo ("{0} {1} ({2})" -f $keyProtector,$_.RecoveryPassword,$env:COMPUTERNAME)
        $filePath = Join-Path $DestinationRoot ("{0} ({1}).txt" -f $keyProtector,$env:COMPUTERNAME)
        # echo $filePath
        Set-Content -Path $filePath -Value $_.RecoveryPassword
    }
