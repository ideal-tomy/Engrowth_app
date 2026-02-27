# OpenAI TTS 運用 Runbook

導入は [OPENAI_TTS_SETUP.md](OPENAI_TTS_SETUP.md)（導入編）を参照。本ドキュメントは運用・切替・監視手順を扱います。

---

## 1. 正式運用への切替手順

### Step 1: Edge Function のデプロイとシークレット

| 環境 | 設定方法 | 備考 |
|------|----------|------|
| Supabase プロジェクト | `supabase secrets set OPENAI_API_KEY=...` | Dashboard からも設定可能 |
| デプロイ | `supabase functions deploy tts_synthesize` | 既存 functions と同様 |

アプリは `Supabase.instance.client` が利用可能な場合に `OpenAiTtsService` を使用し、失敗時は `FlutterTts` にフォールバックします。

### Step 2: 再生失敗率・レイテンシの計測（推奨）

以下を追加することを推奨します。

- OpenAI TTS 利用率: `TtsService.useOpenAiTts` が true の割合
- フォールバック発生回数: `OpenAI TTS fallback to device` ログの件数
- Edge Function のログで失敗率と原因内訳を取得

### Step 3: 音声品質プリセットの統一

| プリセット | 用途 | speakingRate | 備考 |
|------------|------|--------------|------|
| 通常 | 会話学習・例文 | 1.0（設定画面の再生速度で変更可） | `TtsService.setDefaultSpeechRate` |
| ゆっくり | 聞き取り練習 | 0.6 | `speakEnglishSlow` |

### Step 4: コスト監視

- [OpenAI Pricing](https://openai.com/pricing) で TTS の料金を確認
- Supabase Edge Function のログで呼び出し回数を把握
- テキスト長制限（4096 文字）とタイムアウト（25 秒）で暴走を防止

---

## 2. 切替時の確認チェックリスト

- [ ] Edge Function `tts_synthesize` をデプロイ済み
- [ ] `OPENAI_API_KEY` を Supabase シークレットに設定済み
- [ ] アプリ起動後、会話学習画面で英語再生が動作することを確認
- [ ] 再生速度設定が反映されることを確認
- [ ] Edge Function 失敗時にフォールバック（デバイス TTS）が動作することを確認
- [ ] 日本語再生が動作することを確認

---

## 3. トラブルシューティング

[OPENAI_TTS_TROUBLESHOOTING.md](OPENAI_TTS_TROUBLESHOOTING.md) を参照。

---

## 4. 参照

- 導入編: [OPENAI_TTS_SETUP.md](OPENAI_TTS_SETUP.md)
- 契約: [OPENAI_TTS_EDGE_CONTRACT.md](OPENAI_TTS_EDGE_CONTRACT.md)
- 実装: `lib/services/tts_service.dart`, `lib/services/openai_tts_service.dart`
