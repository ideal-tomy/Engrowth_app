# Firebase Hosting へのデプロイスクリプト（PowerShell）
# ローカルで flutter build web を実行し、build/web を Firebase にデプロイします。
#
# 使い方:
#   .\scripts\deploy_firebase.ps1

$ErrorActionPreference = "Stop"

# .env があれば読み込み
if (Test-Path .env) {
    Get-Content .env -Encoding UTF8 | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim().Trim('"').Trim("'")
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

$SUPABASE_URL = $env:SUPABASE_URL
$SUPABASE_ANON_KEY = $env:SUPABASE_ANON_KEY
$ENABLE_GROUP_IMAGE_URLS = if ($env:ENABLE_GROUP_IMAGE_URLS) { $env:ENABLE_GROUP_IMAGE_URLS } else { "false" }

if (-not $SUPABASE_URL -or -not $SUPABASE_ANON_KEY) {
    Write-Host "❌ .env に SUPABASE_URL と SUPABASE_ANON_KEY を設定してください" -ForegroundColor Red
    Write-Host "   または環境変数として渡してください"
    exit 1
}

Write-Host "📦 Flutter Web をビルド中..." -ForegroundColor Cyan
flutter pub get
flutter build web --release `
    --dart-define=SUPABASE_URL="$SUPABASE_URL" `
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" `
    --dart-define=ENABLE_GROUP_IMAGE_URLS="$ENABLE_GROUP_IMAGE_URLS"

Write-Host ""
Write-Host "🚀 Firebase Hosting にデプロイ中..." -ForegroundColor Cyan
firebase deploy --only hosting

Write-Host ""
Write-Host "✅ デプロイ完了！" -ForegroundColor Green
