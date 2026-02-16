# Firebase Hosting deploy build script
# Reads .env and passes values via dart-define for Supabase connection
# Run from engrowth_app: .\scripts\build_for_deploy.ps1

$ErrorActionPreference = "Stop"

$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$projectRoot = Split-Path -Parent $scriptDir
$envPath = Join-Path $projectRoot ".env"

Set-Location $projectRoot | Out-Null

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host ".env path: $envPath" -ForegroundColor Gray

if (Test-Path -LiteralPath $envPath -PathType Leaf) {
    Get-Content -LiteralPath $envPath -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line -match '^([^=]+)=(.*)$') {
            $k = $matches[1].Trim()
            $v = $matches[2].Trim().Trim('"').Trim("'")
            if ($k -and $v) {
                [Environment]::SetEnvironmentVariable($k, $v, "Process")
            }
        }
    }
    Write-Host ".env loaded" -ForegroundColor Green
} else {
    Write-Host "Warning: .env not found at $envPath" -ForegroundColor Yellow
}

$url = [Environment]::GetEnvironmentVariable("SUPABASE_URL", "Process")
$key = [Environment]::GetEnvironmentVariable("SUPABASE_ANON_KEY", "Process")
$enableGroup = [Environment]::GetEnvironmentVariable("ENABLE_GROUP_IMAGE_URLS", "Process")
if ([string]::IsNullOrEmpty($enableGroup)) { $enableGroup = "false" }

if ([string]::IsNullOrEmpty($url) -or [string]::IsNullOrEmpty($key)) {
    Write-Host ""
    Write-Host "Error: SUPABASE_URL and SUPABASE_ANON_KEY required" -ForegroundColor Red
    Write-Host "  Create .env from .env.example and set values" -ForegroundColor Red
    Write-Host "  Run from engrowth_app: .\scripts\build_for_deploy.ps1" -ForegroundColor Red
    exit 1
}

Write-Host "Supabase URL: $($url.Substring(0, [Math]::Min(50, $url.Length)))..." -ForegroundColor Green
Write-Host "Building flutter web..." -ForegroundColor Cyan

$process = Start-Process -FilePath "flutter" -ArgumentList "build","web","--release","--dart-define=SUPABASE_URL=$url","--dart-define=SUPABASE_ANON_KEY=$key","--dart-define=ENABLE_GROUP_IMAGE_URLS=$enableGroup" -NoNewWindow -Wait -PassThru
if ($process.ExitCode -ne 0) { exit $process.ExitCode }

Write-Host ""
Write-Host "Build OK. Deploy with: firebase deploy" -ForegroundColor Green
