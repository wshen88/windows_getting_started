## Enable PowerShell Remote protocol 
Enable-PSRemoting -Force

$certParams = @{
    DnsName           = $env:COMPUTERNAME
    CertStoreLocation = "Cert:\LocalMachine\My"
}
$cert = New-SelfSignedCertificate @certParams

## Configure HTTPS transport 
$wsmanParams = @{
    ResourceURI = "winrm/config/Listener"
    SelectorSet = @{
        Transport = "HTTPS"
        Address = "*"
    }
    ValueSet    = @{
        CertificateThumbprint = $cert.Thumbprint
        Enabled               = $true
    }
}
New-WSManInstance @wsmanParams

## Configure Firewall Rules
$firewallParams = @{
    DisplayName = "Windows Remote Management (HTTPS-In)"
    Direction   = "Inbound"
    LocalPort   = 5986
    Protocol    = "TCP"
    Action      = "Allow"
}
New-NetFirewallRule @firewallParams

## Regedit to filter access tokens
$regInfo = @{
    Path         = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Name         = "LocalAccountTokenFilterPolicy"
    Value        = 1
    PropertyType = "DWord"
    Force        = $true
}
New-ItemProperty @regInfo
