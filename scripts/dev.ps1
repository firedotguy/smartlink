# dev.ps1
$ErrorActionPreference = "Stop"

# .env в корне проекта (на уровень выше scripts/)
$envPath = Join-Path $PSScriptRoot "..\.env"
if (-Not (Test-Path $envPath)) {
    Write-Error ".env file not found at $envPath"
    exit 1
}

# Загружаем переменные из .env
Get-Content $envPath | ForEach-Object {
    $line = $_

    # пропускаем пустые и комментированные строки
    if ($line -match '^\s*$' -or $line -match '^\s*#') { return }

    # поддерживаем: KEY=VAL, KEY = VAL, export KEY=VAL, кавычки и инлайн-комменты
    if ($line -match '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
        $key = $matches[1]
        $val = $matches[2]

        # срезаем инлайн-комментарий: value # comment
        $val = ($val -replace '\s+#.*$', '')

        # убираем обрамляющие кавычки и пробелы
        $val = $val.Trim()                         # пробелы по краям
        $val = $val.Trim("'`"")                    # одинарные/двойные кавычки

        Set-Item -Path "env:$key" -Value $val
    }
}

if (-Not $env:API_KEY)  { Write-Error "API_KEY not found in .env";  exit 1 }
if (-Not $env:API_BASE) { Write-Error "API_BASE not found in .env"; exit 1 }

Write-Host "Running Flutter Web with dart-defines (values hidden)…"

flutter run -d chrome `
  --dart-define=API_KEY="$($env:API_KEY)" `
  --dart-define=API_BASE="$($env:API_BASE)"
