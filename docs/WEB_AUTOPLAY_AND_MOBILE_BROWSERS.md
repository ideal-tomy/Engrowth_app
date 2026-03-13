# Web オートプレイ制限とモバイルブラウザ対応

**目的**: iPhone Safari 等で「1回目は再生されるが2回目以降が再生されない」問題の原因と対処法をまとめる。

---

## 0. 設計方針（ボタンタップの最小化）

- **Speak風UX** に従い、**ユーザーへの行動要請は極力減らす**。`docs/SPEAK_STYLE_UX_PRINCIPLES.md` の「行動要請の最小化」を参照。
- **ネイティブ環境でのデプロイ後**（iOS/Android アプリ）では、ブラウザのオートプレイ制限がなく、**音声が連続再生される**。パターンスプリント等の練習フローは、その前提で設計する。
- **Web版** では現状、2回目以降の音声が iOS Safari 等でブロックされる可能性があるが、「タップで続ける」を挟むことは採用しない。ネイティブデプロイ後の最適な体験（ボタンタップなしで連続再生）を優先する。

---

## 1. 問題の原因

### ブラウザのオートプレイポリシー

- **iOS Safari** および **Chrome on iOS** は、ユーザージェスチャ（タップ・クリック）に**直接**紐づかない音声再生をブロックする。
- 「直接」とは、`play()` 呼び出しがユーザーのタップから同期的に（または同一イベントループ内で）発生していること。
- `await`、`Timer`、`Future.delayed`、`addPostFrameCallback` などを挟むと、ジェスチャの紐づきが切れる。

### パターンスプリントでの発生箇所

| 再生 | トリガー | ユーザージェスチャ |
|------|----------|-------------------|
| 1回目（phase1） | ユーザーが選択→セッション開始→`_runLoop`→`_playOnce` | 選択タップから連鎖。**成功しやすい** |
| 2回目（phase2） | phase1 完了→`_waitAfterPlay`→Timer→`_playOnce` | Timer 経由のため**ブロック** |
| 3回目（phase3） | 同様 | **ブロック** |
| 次フレーズ | `_advance`→`_runPhase`→`_playOnce` | **ブロック** |

---

## 2. 対処法（参考）

### 方針: 各再生をユーザータップに紐づける（現状は未採用）

**解決策の一例**: 2回目以降の再生の直前に「タップで続ける」を挟む。タップをユーザージェスチャとして、その直後に `play()` を呼ぶ。  
→ **採用していない**。上記「設計方針」の通り、ボタンタップを極力減らし、ネイティブデプロイ後の連続再生を優先する。

### 代替案（将来的な検討）

- **1本の音声にまとめる**: 全フレーズを1つの音声ファイルに結合し、1回の `play()` で再生。ユーザージェスチャ1回で済む。
- **ネイティブアプリ**: iOS/Android ネイティブビルドではオートプレイ制限がなく、連続再生が可能。

---

## 3. 参照実装

- `lib/screens/pattern_sprint_session_dialog.dart` — `_waitAfterPlay` はタイマーで自動進行（Web/ネイティブ共通）
- `lib/services/openai_tts_playback_web.dart` — `play()` で `NotAllowedError` 時に `TtsPlaybackBlockedException` をスロー
- `lib/services/tts_service.dart` — `onWebPlaybackBlocked` コールバックで再試行 UI

---

## 4. 関連ドキュメント

- [MDN: Autoplay guide](https://developer.mozilla.org/en-US/docs/Web/Media/Autoplay_guide)
- [WebKit: Auto-Play Policy Changes](https://webkit.org/blog/7734/auto-play-policy-changes-for-macos/)
- `docs/TTS_FLOW.md` — TTS 再生フロー
- `docs/TTS_DEBUG_CHECKLIST.md` — `not_allowed` 時の切り分け
