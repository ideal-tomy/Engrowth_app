# Google Cloud Text-to-Speech セットアップ

英語の発音と会話の流れをより自然に再現するため、Google Cloud Text-to-Speech API（Wavenet 音声）への移行をサポートしています。

## セットアップ手順

1. **Google Cloud Console** でプロジェクトを作成または選択
2. **Cloud Text-to-Speech API** を有効化
   - [API ライブラリ](https://console.cloud.google.com/apis/library) で「Cloud Text-to-Speech API」を検索して有効化
3. **API キーを作成**
   - 認証情報 → 認証情報を作成 → API キー
   - 必要に応じて「アプリケーションの制限」で API を制限（Cloud Text-to-Speech API のみ許可推奨）
4. **`.env` に設定**
   ```
   GOOGLE_TTS_API_KEY=あなたのAPIキー
   ```

## 動作

- **API キー設定時**: Google Cloud TTS（en-US-Wavenet-D）で自然な英語発音
- **未設定時**: デバイス組み込みの TTS（flutter_tts）にフォールバック

## 料金

Google Cloud TTS には無料枠があります（月 100 万文字相当の Premium 音声まで無料）。会話学習アプリの一般的な利用では無料枠内で収まることが多いです。
