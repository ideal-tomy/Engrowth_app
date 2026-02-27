# OpenAI TTS トラブルシューティング

音声が鳴らない・フォールバックが頻発する場合の原因と対処です。

## Web でのオートプレイ制限

**ブラウザでは、ユーザー操作に紐づかない音声再生がブロックされる場合があります。**

- 「会話全体を聞く」タップ → Edge Function 呼び出し（非同期）→ 取得後に `play()` → その間でユーザー操作の文脈が切れるとブロックされることがある。
- **フレーズごとにスピーカーアイコンをタップして再生する**と、各タップがユーザージェスチャになるため、OpenAI TTS で鳴りやすい。
- 連続再生で最初から最後まで OpenAI TTS にしたい場合は、**iOS/Android アプリ**で利用する（ネイティブではこの制限がかかりにくい）。

## 想定される原因と対処

### 1. Edge Function がデプロイされていない / シークレット未設定

- `supabase functions deploy tts_synthesize` でデプロイ済みか確認
- Supabase Dashboard → Edge Functions で `OPENAI_API_KEY` が設定されているか確認
- 未設定時は 502 が返り、デバイス TTS にフォールバックする

### 2. Supabase 接続エラー

- `SUPABASE_URL` と `SUPABASE_ANON_KEY` が正しく設定されているか確認
- ネットワーク接続を確認

### 3. OpenAI API のタイムアウト・レート制限

- Edge Function は 25 秒でタイムアウト。長いテキストは 4096 文字以内に制限
- レート制限に達している場合はフォールバックが発生。OpenAI ダッシュボードで使用量を確認

### 4. Web で .env が読まれない

- Flutter Web では `.env` が正しく配信されない場合がある
- デプロイ時は `--dart-define` で `SUPABASE_URL` と `SUPABASE_ANON_KEY` を渡す

### 5. 再生エラー（Web）

- コンソールに「OpenAI TTS (Web) playback error」や「再生がブロックされました」が出る場合:
  - **NotAllowedError**: オートプレイ制限。再生ボタンをタップした直後に再生されているか確認
  - **code=3** (MEDIA_ERR_DECODE): 形式・コーデックの問題の可能性

## 関連ファイル

| 役割 | ファイル |
|------|----------|
| TTS 選択・フォールバック | `lib/services/tts_service.dart` |
| OpenAI TTS（Edge Function 呼び出し） | `lib/services/openai_tts_service.dart` |
| Web 用再生 | `lib/services/openai_tts_playback_web.dart` |
| IO 用再生 | `lib/services/openai_tts_playback_io.dart` |
| 契約 | `docs/OPENAI_TTS_EDGE_CONTRACT.md` |

## チェックリスト

- [ ] Edge Function `tts_synthesize` がデプロイ済み
- [ ] `OPENAI_API_KEY` が Supabase シークレットに設定済み
- [ ] 「再生」やスピーカーアイコンを**タップしたあと**に再生している
- [ ] フォールバック時にデバイス TTS で音声が出ること
