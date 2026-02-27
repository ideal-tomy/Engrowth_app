# OpenAI TTS Edge Function 契約

## 概要

クライアントは `Supabase.functions.invoke('tts_synthesize', body: {...})` で音声合成を依頼する。  
APIキーはクライアントに持たず、Edge Function 内で `OPENAI_API_KEY` を使用する。

## リクエスト

**メソッド**: POST  
**Content-Type**: application/json

| フィールド | 型 | 必須 | 説明 |
|------------|-----|------|------|
| text | string | ○ | 合成するテキスト（最大 4096 文字） |
| language | string | △ | `en-US` / `ja-JP`。省略時 `en-US` |
| speakingRate | number | △ | 0.25〜4.0。省略時 1.0 |
| voice | string | △ | alloy, nova, echo 等。省略時 `nova`（英語）, `alloy`（日本語） |

## レスポンス（成功）

**Content-Type**: application/octet-stream（Supabase クライアントがバイナリとして扱うため）  
**Body**: MP3 バイナリ

## レスポンス（失敗）

**Content-Type**: application/json  
**Status**: 400 / 502 / 504

```json
{
  "code": "validation_error" | "timeout" | "upstream_error",
  "message": "詳細メッセージ"
}
```

| code | 意味 |
|------|------|
| validation_error | リクエスト不正（text 空、長さ超過等） |
| timeout | OpenAI API がタイムアウト |
| upstream_error | OpenAI API がエラーを返した |

## 使用モデル

- `tts-1-hd`（品質重視）または `tts-1`（低遅延）
- 出力形式: `mp3`
