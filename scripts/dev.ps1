# dev.ps1
$ErrorActionPreference = "Stop"

$envPath = Join-Path $PSScriptRoot "..\.env"
if (-Not (Test-Path $envPath)) {
    Write-Error ".env file not found at $envPath"
    exit 1
}

Get-Content $envPath | ForEach-Object {
    $line = $_

    if ($line -match '^\s*$' -or $line -match '^\s*#') { return }

    if ($line -match '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
        $key = $matches[1]
        $val = $matches[2]

        $val = ($val -replace '\s+#.*$', '')

        $val = $val.Trim()
        $val = $val.Trim("'`"")

        Set-Item -Path "env:$key" -Value $val
    }
}

if (-Not $env:API_KEY)  { Write-Error "API_KEY not found in .env";  exit 1 }
if (-Not $env:API_BASE) { Write-Error "API_BASE not found in .env"; exit 1 }

Write-Host "Running Flutter Web with dart-defines (values hidden)…"

flutter run -d chrome `
  --dart-define=API_KEY="$($env:API_KEY)" `
  --dart-define=API_BASE="$($env:API_BASE)"
