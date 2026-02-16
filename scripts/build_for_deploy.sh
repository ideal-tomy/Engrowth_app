#!/bin/bash
# Firebase Hosting デプロイ用ビルドスクリプト
# .env から環境変数を読み込み、dart-define でビルドに埋め込む

set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "エラー: SUPABASE_URL と SUPABASE_ANON_KEY が必要です。"
  echo "  .env に設定するか、環境変数として設定してください。"
  exit 1
fi

echo "flutter build web を実行中..."
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=ENABLE_GROUP_IMAGE_URLS="${ENABLE_GROUP_IMAGE_URLS:-false}"

echo "ビルド成功。build/web を Firebase にデプロイしてください:"
echo "  firebase deploy"
