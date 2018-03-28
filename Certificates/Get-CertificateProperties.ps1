function Get-RemoteTLSCertificate
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Hostname = "www.microsoft.com",
    
        [int]
        $Port = 443
    )
    
    $Certificate = $null
    $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
    try {
    
        $TcpClient.Connect($Hostname, $Port)
        $TcpStream = $TcpClient.GetStream()
    
        $Callback = { param($sender, $cert, $chain, $errors) return $true }
    
        $TlsStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
        try {
    
            $TlsStream.AuthenticateAsClient('')
            $Certificate = $TlsStream.RemoteCertificate
    
        } finally {
            $TlsStream.Dispose()
        }
    
    } finally {
        $TcpClient.Dispose()
    }
    
    if ($Certificate) {
        if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
            $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
        }
    
        return $Certificate
    }
}

$c = Get-RemoteTLSCertificate -Hostname "www.microsoft.com"
foreach ($ext in $c.Extensions) {
    $ext.Format($false);
}