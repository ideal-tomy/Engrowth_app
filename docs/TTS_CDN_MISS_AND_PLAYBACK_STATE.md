# TTS CDN ミスと再生状態バグ（調査・修正メモ）

## 現象

1. **① 音声が存在しない**: 特定発話の音声が `audio_index.json` / CDN に未登録のとき、「TTS: 音声がCDNにありません」の例外が発生する。
2. **② 1本目再生後に他が鳴らない**: 会話やストーリーで 1 本再生したあと、別コンテンツを再生してもプログレスバーだけ動き音声が出ない。

## 原因（調査結果）

- **①**  
  CDN に未登録のテキストで `OpenAiTtsService._synthesizeAndPlay` が例外をスローしている。  
  登録側は `audio_index.json` への登録、または該当テキストの確認が必要。

- **②**  
  **単発再生**（`ConversationStudyScreen._playUtterance`）で TTS 例外を catch していなかった。  
  - 1 本目で CDN ミスなどで例外 → `await _ttsService.speakEnglish(...)` が throw  
  - `_isPlaying = true` のまま `setState(() => _isPlaying = false)` が実行されない  
  - 以降、`_playAllConversation` / `_playUtterance` 先頭の `if (_isPlaying) return` で即 return  
  - その結果「再生が始まらない／プログレスだけ動く」ように見える。  
  加えて、未処理の Future 例外が **Uncaught (in promise) DartError** となり、デバッグ時にターミナルが固まったように見える要因にもなっていた。

## 修正内容

1. **`lib/screens/conversation_study_screen.dart` の `_playUtterance`**
   - `speakEnglish` を try / on TtsPlaybackBlockedException / on Object catch / finally でラップ。
   - TTS の「音声がCDNにありません」系メッセージのときは SnackBar 表示・`_ttsService.stop()` のうえ return（再生記録は行わない）。
   - **finally** で必ず `_progressController.value = 1.0` と `setState(() => _isPlaying = false)` を実行し、2 本目以降も再生可能に。

2. **`lib/screens/story_study_screen.dart` の `_playAllUtterances`**
   - 同様の TTS 例外を on Object catch で捕捉。
   - CDN ミス時は `_ttsService.stop()` して SnackBar を出し、`continue` で次の発話へ進む。

3. **`lib/app.dart` の初回 postFrameCallback**
   - 計測・テーマ読込を try-catch でラップ。  
   - 再生速度取得の `.then(...).catchError(...)` を追加。  
   → 初回フレームでの未処理例外がターミナル／UI に影響しにくくする。

4. **`lib/services/openai_tts_service.dart`**
   - CDN ミスでスローする箇所に、「呼び出し側で必ず catch すること」「未処理だと Uncaught と _isPlaying 残留の原因になること」をコメントで明記。

## 運用上の注意

- **① を減らすには**: 会話／ストーリーで使う全発話テキストが `audio_index.json`（および CDN）に含まれるようにする。  
  不足分は `build_audio_index.dart` や R2 アップロード手順（`docs/TTS_R2_アップロード手順_やさしい版.md`）で追加する。
- **② を防ぐには**: `speakEnglish` / `speakJapanese` を await するすべての呼び出しで、TTS 例外を catch し、少なくとも `_isPlaying` とプログレスをリセットすること。

## 参照

- `MASTER_PLAN.md`（TTS 配信原則: CDN + JSON インデックス）
- `docs/TTS_FLOW.md`・`docs/TTS_CDN_R2_ARCHITECTURE.md`
- `lib/services/openai_tts_service.dart`（CDN ミス時の throw）
- `lib/screens/conversation_study_screen.dart`（`_playUtterance` / `_playAllConversation` の catch）
