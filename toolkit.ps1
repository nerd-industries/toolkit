<#
.SYNOPSIS
    Nerdy Neighbor / Nerd Industries — script launcher menu ("easy button").
.DESCRIPTION
    Run in an ELEVATED (admin) PowerShell console:

        irm toolkit.nerdyneighbor.net | iex

    Shows a numbered menu of every shop script. Pick a number and it runs the
    matching `irm <url> | iex` for you — no typing long URLs.
.NOTES
    - Most Windows targets #Requires -RunAsAdministrator, so run from an admin console.
    - This launcher itself needs no elevation; it just delegates.
    - macOS entries are bash (`curl ... | bash`) run ON the Mac — the menu prints the
      command to paste there rather than trying to run it here.
    - The menu is the ONLY source of truth for what's deployed — edit this table to
      add/remove entries, push to GitHub, and it's live (GitHub Contents API proxy).
#>

# Force TLS 1.2 (matches every individual script)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ---------------------------------------------------------------
# The menu.  Number = what the user types.
#   Kind = 'ps'   -> irm <Url> | iex   (Windows PowerShell)
#   Kind = 'bash' -> curl -fsSL <Url> | bash   (run ON a Mac)
# Keep this table in sync with live deployments.
# ---------------------------------------------------------------
$Scripts = [ordered]@{
    '1'  = @{ Name = 'OpenSSH — install (LAN-locked, our key)';     Kind = 'ps';   Url = 'https://openssh.nerdyneighbor.net' }
    '2'  = @{ Name = 'OpenSSH — uninstall (clean removal)';          Kind = 'ps';   Url = 'https://openssh-uninstall.nerdyneighbor.net' }
    '3'  = @{ Name = 'Malwarebytes — install';                        Kind = 'ps';   Url = 'https://mbam.nerdyneighbor.net' }
    '4'  = @{ Name = 'Malwarebytes — uninstall';                      Kind = 'ps';   Url = 'https://mbam-uninstall.nerdyneighbor.net' }
    '5'  = @{ Name = 'Windows System Repair (live progress)';        Kind = 'ps';   Url = 'https://repair.nerdyneighbor.net' }
    '6'  = @{ Name = 'Edge — lock search to Google/DuckDuckGo';      Kind = 'ps';   Url = 'https://edge.nerdyneighbor.net' }
    '7'  = @{ Name = 'MTR — packet-loss monitor';                     Kind = 'ps';   Url = 'https://mtr.nerdyneighbor.net/mtr.ps1' }
    '8'  = @{ Name = 'RustDesk — customer install';                   Kind = 'ps';   Url = 'https://rustdesk.nerdyneighbor.net' }
    '9'  = @{ Name = 'RustDesk — shop/tech install (perm password)'; Kind = 'ps';   Url = 'https://rustdesk-shop.nerdyneighbor.net' }
    '10' = @{ Name = 'RustDesk — uninstall';                           Kind = 'ps';   Url = 'https://rustdesk-uninstall.nerdyneighbor.net' }
    '11' = @{ Name = 'Remote Access Audit';                            Kind = 'ps';   Url = 'https://audit.nerdyneighbor.net' }
    '12' = @{ Name = 'RustDesk — macOS install';                       Kind = 'bash'; Url = 'https://rustdesk-macos.nerdyneighbor.net' }
    '13' = @{ Name = 'RustDesk — macOS shop install';                  Kind = 'bash'; Url = 'https://rustdesk-macos-shop.nerdyneighbor.net' }
    '14' = @{ Name = 'RustDesk — macOS uninstall';                     Kind = 'bash'; Url = 'https://rustdesk-macos-uninstall.nerdyneighbor.net' }
}

function Show-Menu {
    Write-Host ''
    Write-Host '  ============================================' -ForegroundColor Cyan
    Write-Host '    NERD TOOLKIT  —  pick a script to run'    -ForegroundColor Cyan
    Write-Host '  ============================================' -ForegroundColor Cyan
    Write-Host ''
    foreach ($k in $Scripts.Keys) {
        $item = $Scripts[$k]
        $tag  = if ($item.Kind -eq 'bash') { '  (macOS)' } else { '' }
        Write-Host ('    {0,2}. {1}{2}' -f $k, $item.Name, $tag)
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
        if ($Scripts.ContainsKey($pick)) {
            $item = $Scripts[$pick]
            Write-Host ''
            if ($item.Kind -eq 'bash') {
                Write-Host ('  >>> {0}  (macOS)' -f $item.Name) -ForegroundColor Green
                Write-Host '  Run this ON the Mac (paste into Terminal):' -ForegroundColor Yellow
                Write-Host ('      curl -fsSL {0} | bash' -f $item.Url) -ForegroundColor Green
                Write-Host ''
                break
            }
            Write-Host ('  >>> {0}' -f $item.Name) -ForegroundColor Green
            Write-Host ('  >>> irm {0} | iex' -f $item.Url) -ForegroundColor Green
            Write-Host ''
            irm $item.Url | iex
            break
        }
        Write-Host ('  "{0}" is not a valid option.' -f $pick) -ForegroundColor Yellow
    }
}
else {
    Show-Menu
    Write-Host '  Non-interactive input detected — run this interactively to pick a script.' -ForegroundColor Yellow
}
