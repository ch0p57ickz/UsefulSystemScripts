param(
    $Certificate = (Get-Item Cert:\CurrentUser\My\B831688A0548243560527E7284B18AA1E8D241AE),
    $SubscriptionId = "b538190b-a51d-4c88-b13e-dde7899be912",
    $CloudServiceName = "icehealthmon-loadperftest",
    [ValidateSet("production", "staging")]
    $DeploymentSlot = "production",
    $ContainerUri = "https://icehealthmonloadperf.blob.core.windows.net/test"
)

$ServiceUrl = "https://management.core.windows.net/$($SubscriptionId)/services/hostedservices/$CloudServiceName/deploymentslots/$DeploymentSlot/package"
$ServiceUrl += "?containerUri=$ContainerUri"

$Headers = @{
    "x-ms-version" = "2014-10-01"
}

$ServiceUrl

Invoke-WebRequest -Uri $ServiceUrl -Headers $Headers -Certificate $Certificate -Method Post