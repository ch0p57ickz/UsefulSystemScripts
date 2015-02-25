Function Decrypt($EncryptedString, $thumb)
{    
    $cert = get-item cert:\CurrentUser\My\$thumb    
    [System.Reflection.Assembly]::LoadWithPartialName("System.Security") | out-null
    $encodedBytes = [Convert]::Frombase64String($EncryptedString)
    $env = New-Object Security.Cryptography.Pkcs.EnvelopedCms
    $env.Decode($encodedBytes)
    $env.Decrypt($cert)
    $enc = New-Object System.Text.ASCIIEncoding
    
    $enc.GetString($env.ContentInfo.Content)    
}

Decrypt "MIIBlQYJKoZIhvcNAQcDoIIBhjCCAYICAQAxggFOMIIBSgIBADAyMB4xHDAaBgNVBAMME1dpbmRvd3MgQXp1cmUgVG9vbHMCEEhhySv6Is+gScyGZX4f2rMwDQYJKoZIhvcNAQEBBQAEggEAqIj8y6NpoV0sYhfncisY9e7iCPMA0Ya4yaWZDwQtZ1Mq3wiVe/an7h4WzxwZb+yhMbjJ6ibp//5NAyVSJwLT4x9Fz7kibEPn8CpBhwHuZwobRNdQ4XTPP9qvnO853CRFRrq75bA8jfq1rLhyymm+H1FhMFIpaZp/jPCSY+j6QTJSLC5fgDhjB2f8494Pf02XcPj+FKOYsvG0zGRCUlK+nGxblNVQ9ck3pMTRAGTTr+6xKxPQjO7pLrHIMgBe8QaNf8mruBMNcdCcwI4rTkgA5sAAh7W+D/SYJTcZJNtpORbmKN6DyMMc/J3Nbb8UGffp3bv3VFwwrk7I0vODq7GbujArBgkqhkiG9w0BBwEwFAYIKoZIhvcNAwcECBMYp+bJTz/XgAg2Jp81vSbBTA==" -thumb 11A6E5107743EB7030536DC2B616E8692767BD0E