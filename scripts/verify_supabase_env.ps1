# Supabase 接続先の確認スクリプト
# prefill・verify・アプリが同じプロジェクトを参照しているか確認する
# 使い方: .\scripts\verify_supabase_env.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$envPath = Join-Path $projectRoot ".env"

Write-Host ""
Write-Host "=== Supabase 接続先の確認 ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $envPath -PathType Leaf)) {
    Write-Host "❌ .env が見つかりません: $envPath" -ForegroundColor Red
    exit 1
}

# .env を読み込み
Get-Content -LiteralPath $envPath -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line -match '^([^=]+)=(.*)$') {
        $k = $matches[1].Trim()
        $v = $matches[2].Trim().Trim('"').Trim("'")
        if ($k -eq "SUPABASE_URL") {
            Write-Host "📋 .env の SUPABASE_URL:" -ForegroundColor Yellow
            Write-Host "   $v" -ForegroundColor White
            Write-Host ""
            $ref = if ($v -match '([a-z0-9]{20})\.supabase\.co') { $Matches[1] } else { "" }
            if ($ref) {
                Write-Host "   プロジェクトREF: $ref" -ForegroundColor Gray
                Write-Host ""
            }
        }
    }
}

Write-Host "--- 確認ポイント ---" -ForegroundColor Cyan
Write-Host "1. 上記の URL が prefill / verify で使われています"
Write-Host "2. デプロイ時: build_for_deploy.ps1 または deploy_firebase.ps1 を実行すると、"
Write-Host "   ビルド開始時に「Supabase URL: https://...」が表示されます"
Write-Host "3. その URL が上記と一致していれば、同じプロジェクトです"
Write-Host ""
Write-Host "期待値: https://munemrzmgaitfeejrtns.supabase.co" -ForegroundColor Green
Write-Host ""
