# TTS 音声再生の全体フロー

**目的**: アプリから音声が鳴るまでの経路を1枚で把握する。

---

## 1. 全体フロー図

**DB のみモード**（Edge/flutter_tts フォールバックなし）:

```
[UI] speakEnglish / speakJapanese
        │
        ▼
[TtsService] (lib/services/tts_service.dart)
        │  useOpenAiTts == true かつ Supabase 利用可
        ▼
[OpenAiTtsService] (lib/services/openai_tts_service.dart)
        │
        ├─ 1. DB 直参照 (_tryFetchUrlFromDb)
        │     tts_assets から storage_path 取得
        │     → Public URL 構築: {supabaseUrl}/storage/v1/object/public/tts-audio/{path}
        │
        ├─ DB HIT → playFromUrl(url) ──────────────────────────────┐
        │                                                          │
        └─ DB MISS → Exception をスロー（Edge は呼ばない）        │
                      │                                            │
                      ▼                                            │
               （呼び出し元で catch。flutter_tts フォールバックなし）│
                                                                    │
                                                                    ▼
[openai_tts_playback_web.dart] (Web) / openai_tts_playback_io.dart (iOS/Android)
        │
        │  playFromUrl(url)
        │    - AudioElement.src = url
        │    - await onCanPlay.first.timeout(10秒)  ← ★ 10秒タイムアウトの場所
        │    - await play()
        │    - await onEnded (再生完了まで最大60秒)
        │
        ▼
[例外発生時] → TtsService が catch
        │
        └─ flutter_tts へフォールバック（デバイス TTS）
```

---

## 2. 10秒タイムアウトは「何を待っているか」

**場所**: `lib/services/openai_tts_playback_web.dart` 106行目・179行目

```dart
await _current!.onCanPlay.first.timeout(const Duration(seconds: 10));
```

**意味**:
- `onCanPlay` / `onLoadedData`: HTML5 の `AudioElement` が「再生可能なデータ量に達した」ときに発火
- いずれかが発火するまで最大 20 秒待機（遅いネットワーク対策）
- 直接 URL でタイムアウトした場合は fetch→blob でリトライ

**タイムアウトする主な原因**:

| 原因 | 説明 |
|------|------|
| **403 Forbidden** | `tts-audio` バケットが Private のまま。Public URL ではアクセス不可 |
| **404 Not Found** | `storage_path` が DB と Storage で食い違っている、またはファイル未アップロード |
| **CORS** | Storage の CORS 設定が不足（Supabase デフォルトでは通常問題なし） |
| **ネットワーク遅延** | 回線が遅く、20秒以内にデータが届かない |
| **URL 誤り** | `supabaseUrl` や `storage_path` の組み合わせが不正 |

**結果**: 発火しない → 20秒後に `TimeoutException` → fetch→blob でリトライ → それでも失敗なら例外

---

## 3. ファイル別の役割

| ファイル | 役割 |
|----------|------|
| `tts_service.dart` | 入口。DB 保存音声のみ。失敗時はフォールバックなし |
| `openai_tts_service.dart` | DB 直参照のみ。ミス時は例外。URL 取得 → playFromUrl |
| `openai_tts_playback_web.dart` | Web: AudioElement で URL/Blob 再生。20秒ロード・90秒再生。タイムアウト時は fetch→blob でリトライ |
| `openai_tts_playback_io.dart` | iOS/Android: ネイティブ再生 |
| `tts_debug_collector.dart` | DB ミス・エラー時のデバッグ情報収集 |
| Edge `tts_synthesize` | DB 参照 → ミス時 OpenAI 合成 → Storage 保存 → Public URL 返却 |

---

## 4. DB のみモード（現行）

**DB にないテキストは Edge を呼ばず例外をスロー**。flutter_tts へのフォールバックもなし。

- 事前に `dart run scripts/prefill_tts_assets.dart` または `prefill_story_tts.dart` で DB に投入しておく

---

## 5. 関連ドキュメント

- `TTS_かんたん確認手順.md` - 初心者向けチェックリスト
- `TTS_DEBUG_CHECKLIST.md` - 5秒壁・direct_db 低下時の診断
- `TTS_CACHE_FULL_RUNBOOK.md` - prefill 手順
