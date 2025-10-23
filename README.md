# TOTP Generator for Windows PowerShell

A simple command-line TOTP (Time-based One-Time Password) generator that displays authentication codes live in your terminal.

## What is TOTP?

TOTP is used for two-factor authentication (2FA). When you set up 2FA on a service, you receive a secret key - this tool uses that key to generate the same codes that apps like Google Authenticator or Authy would show.

## Requirements

- Windows PowerShell (comes pre-installed on Windows)
- Your TOTP secret key (the base32-encoded string from your 2FA setup)

## Setup

### 1. Allow PowerShell Scripts to Run

Open PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Type `Y` and press Enter to confirm.

### 2. Get Your TOTP Secret Key

When setting up 2FA on an app, you'll see either:
- A QR code with a "Can't scan?" link - click it to reveal the secret key
- A text string labeled "Secret Key" or "Manual Entry Key"

Example secret key: `JBSWY3DPEHPK3PXP` or `L6PNXQUFIQOR357BQKYETVXWC3I77UPI`

## Usage

### Basic Usage

```powershell
.\totp_generator_ascii.ps1 "YOUR_SECRET_KEY_HERE"
```

## What You'll See

```
TOTP Generator - Press Ctrl+C to exit

========================================

Code: 318 079 | Time left: 12s | [############------------------]
```

- **Code**: Your current 6-digit authentication code
- **Time left**: Seconds until the next code generates
- **Progress bar**: Visual representation of time remaining

## How It Works

1. The script runs continuously
2. Every 30 seconds, a new code is automatically generated
3. The countdown updates every second
4. Press **Ctrl+C** to exit

## Alternative: Run Without Changing Execution Policy

```powershell
powershell -ExecutionPolicy Bypass -File .\totp_generator_ascii.ps1 "YOUR_KEY"
```

## Security Notes

⚠️ **Important Security Information:**

- Your secret key is sensitive - treat it like a password
- Don't share your secret key with anyone
- The key will be visible in your PowerShell command history
- Anyone with access to your secret key can generate your 2FA codes
- For maximum security, delete your PowerShell history after use with:
  ```powershell
  Clear-History
  ```

## Support

If you encounter issues:
1. Make sure you're using the latest version of the script
2. Verify your secret key is correct
3. Try running PowerShell as Administrator
4. Check that your system time is accurate (TOTP depends on correct time)

---

**Note**: This tool generates the same codes as Google Authenticator, Authy, and other TOTP apps. It's useful for accessing your codes from the command line or when you don't have access to your usual authenticator device.