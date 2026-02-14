#!/bin/bash
# Firebase Hosting へのデプロイスクリプト
# ローカルで flutter build web を実行し、build/web を Firebase にデプロイします。
#
# 使い方:
#   ./scripts/deploy_firebase.sh
# または .env を読み込んで:
#   set -a && source .env && set +a && ./scripts/deploy_firebase.sh

set -e

# .env があれば読み込み（SUPABASE_URL, SUPABASE_ANON_KEY など）
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
ENABLE_GROUP_IMAGE_URLS="${ENABLE_GROUP_IMAGE_URLS:-false}"

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "❌ .env に SUPABASE_URL と SUPABASE_ANON_KEY を設定してください"
  echo "   または環境変数として渡してください"
  exit 1
fi

echo "📦 Flutter Web をビルド中..."
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=ENABLE_GROUP_IMAGE_URLS="$ENABLE_GROUP_IMAGE_URLS"

echo ""
echo "🚀 Firebase Hosting にデプロイ中..."
firebase deploy --only hosting

echo ""
echo "✅ デプロイ完了！"
