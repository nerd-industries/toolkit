<#
.SYNOPSIS
    Nerdy Neighbor / Nerd Industries — script launcher menu ("easy button").
.DESCRIPTION
    Run in an ELEVATED (admin) PowerShell console:

        irm toolkit.nerdyneighbor.net | iex

    Shows a numbered menu of every shop script. Pick a number and it runs the
    matching `irm <url> | iex` for you — no typing long URLs.
.NOTES
    - Most targets #Requires -RunAsAdministrator, so run from an admin console.
    - This launcher itself needs no elevation; it just delegates.
    - The menu is the ONLY source of truth for what's deployed — edit this table to
      add/remove entries, push to GitHub, and it's live (GitHub Contents API proxy).
#>

# Force TLS 1.2 (matches every individual script)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------------------------------------------------------------
# The menu.  Number = what the user types.  Url = the irm target.
# Keep this table in sync with live deployments.
# ---------------------------------------------------------------
$Scripts = [ordered]@{
    '1'  = @{ Name = 'OpenSSH — install (LAN-locked, our key)';     Url = 'https://openssh.nerdyneighbor.net' }
    '2'  = @{ Name = 'OpenSSH — uninstall (clean removal)';          Url = 'https://openssh-uninstall.nerdyneighbor.net' }
    '3'  = @{ Name = 'Malwarebytes — install';                        Url = 'https://mbam.nerdyneighbor.net' }
    '4'  = @{ Name = 'Malwarebytes — uninstall';                      Url = 'https://mbam-uninstall.nerdyneighbor.net' }
    '5'  = @{ Name = 'Windows System Repair (live progress)';        Url = 'https://repair.nerdyneighbor.net' }
    '6'  = @{ Name = 'Edge — lock search to Google/DuckDuckGo';      Url = 'https://edge.nerdyneighbor.net' }
    '7'  = @{ Name = 'MTR — packet-loss monitor';                     Url = 'https://mtr.nerdyneighbor.net/mtr.ps1' }
    '8'  = @{ Name = 'RustDesk — customer install';                   Url = 'https://rustdesk.nerdyneighbor.net' }
    '9'  = @{ Name = 'RustDesk — shop/tech install (perm password)'; Url = 'https://rustdesk-shop.nerdyneighbor.net' }
    '10' = @{ Name = 'RustDesk — uninstall';                           Url = 'https://rustdesk-uninstall.nerdyneighbor.net' }
    '11' = @{ Name = 'RustDesk — convert shop to customer';             Url = 'https://rustdesk-convert.nerdyneighbor.net' }
    '12' = @{ Name = 'Remote Access Audit — check for remote-access software'; Url = 'https://audit.nerdyneighbor.net' }
    '13' = @{ Name = 'Clear PowerShell history';                      Cmd = 'Clear-History; Remove-Item (Get-PSReadLineOption).HistorySavePath -Force -ErrorAction SilentlyContinue' }
}

function Show-Menu {
    Write-Host ''
    Write-Host '  ============================================' -ForegroundColor Cyan
    Write-Host '    NERD TOOLKIT  —  pick a script to run'    -ForegroundColor Cyan
    Write-Host '  ============================================' -ForegroundColor Cyan
    Write-Host ''
    foreach ($k in $Scripts.Keys) {
        Write-Host ('    {0,2}. {1}' -f $k, $Scripts[$k].Name)
    }
    Write-Host ''
    Write-Host '     q. Quit' -ForegroundColor DarkGray
    Write-Host ''
}

# --- interactive? -----------------------------------------------
if (-not [Console]::IsInputRedirected) {
    while ($true) {
        Show-Menu
        $pick = Read-Host '  Enter a number (or q)'
        if ($pick -match '^[qQ]$' -or [string]::IsNullOrWhiteSpace($pick)) {
            Write-Host '  Exiting.' -ForegroundColor DarkGray
            break
        }
        if ($Scripts.Contains($pick)) {
            $item = $Scripts[$pick]
            Write-Host ''
            Write-Host ('  >>> {0}' -f $item.Name) -ForegroundColor Green
            if ($item.Cmd) {
                Write-Host ('  >>> {0}' -f $item.Cmd) -ForegroundColor Green
                Write-Host ''
                Invoke-Expression $item.Cmd
            }
            else {
                Write-Host ('  >>> irm {0} | iex' -f $item.Url) -ForegroundColor Green
                Write-Host ''
                irm $item.Url | iex
            }
            break
        }
        Write-Host ('  "{0}" is not a valid option.' -f $pick) -ForegroundColor Yellow
    }
}
else {
    Show-Menu
    Write-Host '  Non-interactive input detected — run this interactively to pick a script.' -ForegroundColor Yellow
}
