# TOTP Generator for PowerShell
# Usage: .\totp_generator.ps1 "YOUR_SECRET_KEY"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Secret
)

function Get-TOTPToken {
    param([string]$Secret)
    
    $Secret = $Secret.Replace(" ", "").ToUpper()
    
    # Base32 decode
    $base32Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    $bits = ""
    
    foreach ($char in $Secret.ToCharArray()) {
        $index = $base32Chars.IndexOf($char)
        if ($index -ge 0) {
            $bits += [Convert]::ToString($index, 2).PadLeft(5, '0')
        }
    }
    
    $byteArray = @()
    for ($i = 0; $i -lt $bits.Length; $i += 8) {
        if ($i + 8 -le $bits.Length) {
            $byteArray += [Convert]::ToByte($bits.Substring($i, 8), 2)
        }
    }
    
    # Get current time step
    $unixTime = [int64]([DateTime]::UtcNow - [DateTime]::new(1970, 1, 1)).TotalSeconds
    $timeStep = [Math]::Floor($unixTime / 30)
    
    # Convert time to bytes
    $timeBytes = [BitConverter]::GetBytes($timeStep)
    [Array]::Reverse($timeBytes)
    
    # HMAC-SHA1
    $hmac = New-Object System.Security.Cryptography.HMACSHA1
    $hmac.Key = $byteArray
    $hash = $hmac.ComputeHash($timeBytes)
    
    # Dynamic truncation
    $offset = $hash[$hash.Length - 1] -band 0x0F
    $binary = (($hash[$offset] -band 0x7F) -shl 24) -bor
              (($hash[$offset + 1] -band 0xFF) -shl 16) -bor
              (($hash[$offset + 2] -band 0xFF) -shl 8) -bor
              ($hash[$offset + 3] -band 0xFF)
    
    $otp = $binary % 1000000
    return $otp.ToString("D6")
}

function Get-TimeRemaining {
    $unixTime = [int64]([DateTime]::UtcNow - [DateTime]::new(1970, 1, 1)).TotalSeconds
    return 30 - ($unixTime % 30)
}

Clear-Host
Write-Host "TOTP Generator - Press Ctrl+C to exit`n" -ForegroundColor Cyan

$lastToken = ""
$iteration = 0

# Infinite loop - only exits on Ctrl+C
while ($true) {
    $iteration++
    
    $token = Get-TOTPToken -Secret $Secret
    $timeRemaining = Get-TimeRemaining
    
    # When we get a new token, clear screen and redraw header
    if ($token -ne $lastToken) {
        Clear-Host
        Write-Host "TOTP Generator - Press Ctrl+C to exit`n" -ForegroundColor Cyan
        Write-Host "========================================`n"
        $lastToken = $token
    }
    
    # Create progress bar
    $barLength = 30
    $filled = [Math]::Floor(($timeRemaining / 30) * $barLength)
    if ($filled -lt 0) { $filled = 0 }
    if ($filled -gt 30) { $filled = 30 }
    $bar = "#" * $filled + "-" * ($barLength - $filled)
    
    # Write current status (this will scroll, but that's okay)
    Write-Host "Code: $($token.Substring(0,3)) $($token.Substring(3)) | Time left: $($timeRemaining)s | [$bar]`r" -NoNewline -ForegroundColor Green
    
    Start-Sleep -Milliseconds 1000
}
