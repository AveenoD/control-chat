param(
  [string]$DatabaseUrl = $env:DATABASE_URL
)

if (-not $DatabaseUrl) {
  Write-Error "DATABASE_URL is required"
  exit 1
}

$ErrorActionPreference = "Stop"

$migrationsDir = Join-Path $PSScriptRoot "migrations"
$files = Get-ChildItem -Path $migrationsDir -Filter "*.sql" | Sort-Object Name

foreach ($f in $files) {
  Write-Host "Applying $($f.Name)..."
  psql $DatabaseUrl -v ON_ERROR_STOP=1 -f $f.FullName | Out-Host
}

Write-Host "Migrations applied."

