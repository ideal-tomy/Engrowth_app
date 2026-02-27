# OpenAI TTS セットアップ（導入編）

英語の発音と会話の流れをより自然に再現するため、OpenAI Text-to-Speech API を Supabase Edge Function 経由で利用します。

運用・切替・監視手順は [OPENAI_TTS_RUNBOOK.md](OPENAI_TTS_RUNBOOK.md) を参照してください。  
**Web で音声が鳴らない場合**は [OPENAI_TTS_TROUBLESHOOTING.md](OPENAI_TTS_TROUBLESHOOTING.md) を参照してください。

## アーキテクチャ

- **クライアント**: `TtsService` が Supabase Edge Function `tts_synthesize` を呼び出し
- **Edge Function**: OpenAI Audio API でテキストを MP3 に合成（API キーはサーバー側に保持）
- **フォールバック**: Edge Function 失敗時はデバイス TTS（flutter_tts）を使用

## セットアップ手順

### 1. Supabase に Edge Function をデプロイ

```bash
supabase functions deploy tts_synthesize
```

### 2. シークレットの設定

Supabase Dashboard → Edge Functions → tts_synthesize → Secrets で `OPENAI_API_KEY` を設定。

または CLI:

```bash
supabase secrets set OPENAI_API_KEY=sk-...
```

### 3. クライアント側

クライアントには API キーを設定しません。Supabase の URL と Anon Key が設定されていれば、Edge Function 経由で音声合成が利用可能です。

- **Supabase 設定済み**: OpenAI TTS を優先（失敗時はデバイス TTS）
- **Supabase 未設定**: デバイス TTS のみ

## 動作

- **Edge Function 利用可能時**: OpenAI TTS（tts-1-hd）で高品質音声
- **失敗時**: デバイス組み込みの TTS（flutter_tts）にフォールバック

## 料金

OpenAI TTS は従量課金です。[OpenAI Pricing](https://openai.com/pricing) で最新の料金を確認してください。会話学習の典型的な利用では、月額コストは抑えられることが多いです。
