# 起動リファクタとターミナル挙動

## リファクタで変わったこと

起動遅延対策で以下を変更している。

1. **main.dart（runApp 前）**
   - **削除**: `await AuthService().ensureSignedIn()` と `await PlaybackSpeedService.getSpeed()` / `TtsService.setDefaultSpeechRate(speed)`
   - **残したもの**: `EnvConfig.load()` → `Supabase.initialize()` → `cleanAuthParamsFromUrl()` のみ
   - 初回表示までの同期的なブロックは減っている。

2. **app.dart（初回フレーム後）**
   - `addPostFrameCallback` 内で以下を実行（すべて非同期で待ち合わせなし）:
     - 起動計測イベント送信（`app_boot_started`, `first_frame_rendered`）
     - `themeModeProvider.load()`
     - `AuthService().ensureSignedIn()`（`.catchError` で握りつぶし）
     - `PlaybackSpeedService.getSpeed().then(...)` で再生速度を適用
   - これらは **同期的にはブロックしない**（`await` していない）。
   - 念のため、上記処理は `Future.microtask` 内で実行し、フレーム描画完了後に明示的に「次のタスク」として動かすようにしている。

3. **DashboardScreen**
   - `ref.listen(userStatsProvider, ...)` で `home_full_ready` を 1 回だけ送信。
   - `ref.listen` は build 内で呼ぶ Riverpod の想定用法。コールバック内では `setState` は呼んでおらず、非同期の `logEvent` も await していない。

## ターミナルが固まる件について

- 上記の変更だけでは、**メイン isolate を同期的にブロックする処理は増えていない**。  
  匿名サインイン・再生速度読み込みは runApp 後に「投げっぱなし」で実行しているため、従来よりブロックは減っている。
- ターミナルが固まるように見える場合、考えられる要因は例えば次のようなもの:
  - **Hot Reload / Hot Restart の不整合**: 状態の再初期化やプロバイダの再実行が重なると、まれにフレームワーク側でハングすることがある。
  - **Flutter Web + Chrome**: ブラウザとの接続やデバッグ接続が不安定だと、`flutter run` のプロセスが応答しなくなることがある。
  - **デバッグ時のネットワーク**: Supabase や analytics の非同期処理が長時間ブロックすると、VM の挙動が重く見える場合がある（ターミナル自体の「固まり」の直接原因とは限らない）。

**実施した対策**

- `app.dart` の post-frame 処理を `Future.microtask` でラップし、フレーム描画完了後に明示的に次タスクとして実行するようにした。
- `mounted` チェックを追加し、ウィジェット破棄後の実行を避けている。

それでもターミナルが固まる場合は、以下を試すと切り分けしやすい:

- `flutter run` をやめて一度ターミナルを閉じ、新規ターミナルで `flutter run` をやり直す（現状の運用で問題が減るか確認）。
- Hot Restart（`R`）ではなく、プロセスごと再起動（`flutter run` の再実行）で再現するか確認。
- `--no-sound-null-safety` など、別のフラグなしの通常の `flutter run` で再現するか確認。

## 会話コンテンツについて

「どのコンテンツかに関わらず、何か一つの会話コンテンツ」の続きの要件（例: 再生が遅い・落ちる・一つの会話だけ選んでテストしたいなど）が分かれば、その前提で調査・対策案を出せる。必要なら具体的な症状や操作手順を追記してください。
